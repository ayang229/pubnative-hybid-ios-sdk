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

#import "PNLiteMRectPresenterDecorator.h"

@interface PNLiteMRectPresenterDecorator ()

@property (nonatomic, strong) PNLiteMRectPresenter *mRectPresenter;
@property (nonatomic, strong) PNLiteAdTracker *adTracker;
@property (nonatomic, strong) NSObject<PNLiteMRectPresenterDelegate> *mRectPresenterDelegate;

@end

@implementation PNLiteMRectPresenterDecorator

- (void)dealloc
{
    self.mRectPresenter = nil;
    self.adTracker = nil;
    self.mRectPresenterDelegate = nil;
}

- (void)load
{
    [self.mRectPresenter load];
}

- (instancetype)initWithMRectPresenter:(PNLiteMRectPresenter *)mRectPresenter
                         withAdTracker:(PNLiteAdTracker *)adTracker
                          withDelegate:(NSObject<PNLiteMRectPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.mRectPresenter = mRectPresenter;
        self.adTracker = adTracker;
        self.mRectPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark PNLiteMRectPresenterDelegate

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didLoadWithMRect:(UIView *)mRect
{
    [self.adTracker trackImpression];
    [self.mRectPresenterDelegate mRectPresenter:mRectPresenter didLoadWithMRect:mRect];
}

- (void)mRectPresenterDidClick:(PNLiteMRectPresenter *)mRectPresenter
{
    [self.adTracker trackClick];
    [self.mRectPresenterDelegate mRectPresenterDidClick:mRectPresenter];
}

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didFailWithError:(NSError *)error
{
    [self.mRectPresenterDelegate mRectPresenter:mRectPresenter didFailWithError:error];
}

@end