//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteVASTParser.h"
#import "PNLiteVASTXMLUtil.h"
#import "PNLiteVASTModel.h"
#import "PNLiteVASTSchema.h"

NSInteger const kPNLiteVASTModel_MaxRecursiveDepth = 5;
BOOL const kPNLiteVASTModel_ValidateWithSchema = NO;

@interface PNLiteVASTModel (private)

- (void)addVASTDocument:(NSData *)vastDocument;

@end

@interface PNLiteVASTParser ()

@property (nonatomic, strong) PNLiteVASTModel *vastModel;

- (PNLiteVASTParserError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth;

@end

@implementation PNLiteVASTParser

- (id)init {
    self = [super init];
    if (self) {
        self.vastModel = [[PNLiteVASTModel alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.vastModel = nil;
}

#pragma mark - "public" methods

- (void)parseWithUrl:(NSURL *)url completion:(vastParserCompletionBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *vastData = [NSData dataWithContentsOfURL:url];
        PNLiteVASTParserError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

- (void)parseWithData:(NSData *)vastData completion:(vastParserCompletionBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PNLiteVASTParserError vastError = [self parseRecursivelyWithData:vastData depth:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(self.vastModel, vastError);
        });
    });
}

#pragma mark - "private" method

- (PNLiteVASTParserError)parseRecursivelyWithData:(NSData *)vastData depth:(int)depth {
    if (depth >= kPNLiteVASTModel_MaxRecursiveDepth) {
        self.vastModel = nil;
        return PNLiteVASTParserError_TooManyWrappers;
    }
    
    // sanity check
    __unused NSString *content = [[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding];

    // Validate the basic XML syntax of the VAST document.
    BOOL isValid;
    isValid = validateXMLDocSyntax(vastData);
    if (!isValid) {
        self.vastModel = nil;
        return PNLiteVASTParserError_XMLParse;
    }

    if (kPNLiteVASTModel_ValidateWithSchema) {
        
        // Using header data
        NSData *PNLiteVASTSchemaData = [NSData dataWithBytesNoCopy:pubnative_lite_vast_2_0_1_xsd
                                                        length:pubnative_lite_vast_2_0_1_xsd_len
                                                freeWhenDone:NO];
        isValid = validateXMLDocAgainstSchema(vastData, PNLiteVASTSchemaData);
        if (!isValid) {
            self.vastModel = nil;
            return PNLiteVASTParserError_SchemaValidation;
        }
    }

    [self.vastModel addVASTDocument:vastData];
    
    // Check to see whether this is a wrapper ad. If so, process it.
    NSString *query = @"//VASTAdTagURI";
    NSArray *results = performXMLXPathQuery(vastData, query);
    if ([results count] > 0) {
        NSString *url;
        NSDictionary *node = results[0];
        if ([node[@"nodeContent"] length] > 0) {
            // this is for string data
            url =  node[@"nodeContent"];
        } else {
            // this is for CDATA
            NSArray *childArray = node[@"nodeChildArray"];
            if ([childArray count] > 0) {
                // we assume that there's only one element in the array
                url = ((NSDictionary *)childArray[0])[@"nodeContent"];
            }
        }
        vastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        return [self parseRecursivelyWithData:vastData depth:(depth + 1)];
    }
    
    return PNLiteVASTParserError_None;
}

- (NSString *)content:(NSDictionary *)node {
    // this is for string data
    if ([node[@"nodeContent"] length] > 0) {
        return node[@"nodeContent"];
    }
    
    // this is for CDATA
    NSArray *childArray = node[@"nodeChildArray"];
    if ([childArray count] > 0) {
        // we assume that there's only one element in the array
        return ((NSDictionary *)childArray[0])[@"nodeContent"];
    }
    
    return nil;
}

@end
