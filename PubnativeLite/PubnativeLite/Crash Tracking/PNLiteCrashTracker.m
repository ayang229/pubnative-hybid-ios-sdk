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

#import "PNLiteCrashTracker.h"
#import "PNLite_KSCrash.h"
#import "PNLiteCrashLogger.h"
#import "PNLiteNotifier.h"
#import "PNLiteKeys.h"

static PNLiteNotifier *pnlite_g_notifier = NULL;

@interface PNLiteCrashTracker ()
+ (PNLiteNotifier *)notifier;
+ (BOOL)pnliteStarted;
@end

@interface NSDictionary (PNLiteKSMerge)
- (NSDictionary *)PNLite_mergedInto:(NSDictionary *)dest;
@end

@implementation PNLiteCrashTracker

+ (void)startPNLiteCrashTrackerWithApiKey:(NSString *)apiKey {
    PNLiteConfiguration *configuration = [PNLiteConfiguration new];
    configuration.apiKey = apiKey;
    [self startPNLiteCrashTrackerWithConfiguration:configuration];
}

+ (void)startPNLiteCrashTrackerWithConfiguration:(PNLiteConfiguration *)configuration {
    @synchronized(self) {
        pnlite_g_notifier =
        [[PNLiteNotifier alloc] initWithConfiguration:configuration];
        [pnlite_g_notifier start];
    }
}

+ (PNLiteConfiguration *)configuration {
    if ([self pnliteStarted]) {
        return self.notifier.configuration;
    }
    return nil;
}

+ (PNLiteConfiguration *)instance {
    return [self configuration];
}

+ (PNLiteNotifier *)notifier {
    return pnlite_g_notifier;
}

+ (void)notify:(NSException *)exception {
    [self.notifier notifyException:exception
                             block:^(PNLiteCrashReport *_Nonnull report) {
                               report.depth += 2;
                             }];
}

+ (void)notify:(NSException *)exception block:(PNLiteNotifyBlock)block {
    [[self notifier] notifyException:exception
                               block:^(PNLiteCrashReport *_Nonnull report) {
                                 report.depth += 2;

                                 if (block) {
                                     block(report);
                                 }
                               }];
}

+ (void)notifyError:(NSError *)error {
    [self.notifier notifyError:error
                         block:^(PNLiteCrashReport *_Nonnull report) {
                           report.depth += 2;
                         }];
}

+ (void)notifyError:(NSError *)error block:(PNLiteNotifyBlock)block {
    [[self notifier] notifyError:error
                           block:^(PNLiteCrashReport *_Nonnull report) {
                             report.depth += 2;

                             if (block) {
                                 block(report);
                             }
                           }];
}

+ (void)notify:(NSException *)exception withData:(NSDictionary *)metaData {

    [[self notifier]
        notifyException:exception
                  block:^(PNLiteCrashReport *_Nonnull report) {
                    report.depth += 2;
                    report.metaData = [metaData
                        PNLite_mergedInto:[self.notifier.configuration
                                               .metaData toDictionary]];
                  }];
}

+ (void)notify:(NSException *)exception
      withData:(NSDictionary *)metaData
    atSeverity:(NSString *)severity {

    [[self notifier]
        notifyException:exception
             atSeverity:PNLiteParseSeverity(severity)
                  block:^(PNLiteCrashReport *_Nonnull report) {
                    report.depth += 2;
                    report.metaData = [metaData
                        PNLite_mergedInto:[self.notifier.configuration
                                               .metaData toDictionary]];
                    report.severity = PNLiteParseSeverity(severity);
                  }];
}

+ (void)internalClientNotify:(NSException *_Nonnull)exception
                    withData:(NSDictionary *_Nullable)metaData
                       block:(PNLiteNotifyBlock _Nullable)block {
    [self.notifier internalClientNotify:exception
                               withData:metaData
                                  block:block];
}

+ (void)addAttribute:(NSString *)attributeName
           withValue:(id)value
       toTabWithName:(NSString *)tabName {
    if ([self pnliteStarted]) {
        [self.notifier.configuration.metaData addAttribute:attributeName
                                                 withValue:value
                                             toTabWithName:tabName];
    }
}

+ (void)clearTabWithName:(NSString *)tabName {
    if ([self pnliteStarted]) {
        [self.notifier.configuration.metaData clearTab:tabName];
    }
}

+ (BOOL)pnliteStarted {
    if (self.notifier == nil) {
        pnlite_log_err(@"Ensure you have started PNLiteCrashTracker with startWithApiKey: "
                    @"before calling any other PNLiteCrashTracker functions.");

        return NO;
    }
    return YES;
}

+ (void)leaveBreadcrumbWithMessage:(NSString *)message {
    [self leaveBreadcrumbWithBlock:^(PNLiteBreadcrumb *_Nonnull crumbs) {
      crumbs.metadata = @{PNLiteKeyMessage : message};
    }];
}

+ (void)leaveBreadcrumbWithBlock:
    (void (^_Nonnull)(PNLiteBreadcrumb *_Nonnull))block {
    [self.notifier addBreadcrumbWithBlock:block];
}

+ (void)leaveBreadcrumbForNotificationName:
    (NSString *_Nonnull)notificationName {
    [self.notifier crumbleNotification:notificationName];
}

+ (void)setBreadcrumbCapacity:(NSUInteger)capacity {
    self.notifier.configuration.breadcrumbs.capacity = capacity;
}

+ (void)clearBreadcrumbs {
    [self.notifier clearBreadcrumbs];
}

+ (void)startSession {
    [self.notifier startSession];
}

+ (NSDateFormatter *)payloadDateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      formatter = [NSDateFormatter new];
      formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ";
    });
    return formatter;
}

+ (void)setSuspendThreadsForUserReported:(BOOL)suspendThreadsForUserReported {
    [[PNLite_KSCrash sharedInstance]
        setSuspendThreadsForUserReported:suspendThreadsForUserReported];
}

+ (void)setReportWhenDebuggerIsAttached:(BOOL)reportWhenDebuggerIsAttached {
    [[PNLite_KSCrash sharedInstance]
        setReportWhenDebuggerIsAttached:reportWhenDebuggerIsAttached];
}

+ (void)setThreadTracingEnabled:(BOOL)threadTracingEnabled {
    [[PNLite_KSCrash sharedInstance] setThreadTracingEnabled:threadTracingEnabled];
}

+ (void)setWriteBinaryImagesForUserReported:
    (BOOL)writeBinaryImagesForUserReported {
    [[PNLite_KSCrash sharedInstance]
        setWriteBinaryImagesForUserReported:writeBinaryImagesForUserReported];
}

@end

//
//  NSDictionary+Merge.m
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

@implementation NSDictionary (PNLiteKSMerge)

- (NSDictionary *)PNLite_mergedInto:(NSDictionary *)dest {
    if ([dest count] == 0) {
        return self;
    }
    if ([self count] == 0) {
        return dest;
    }

    NSMutableDictionary *dict = [dest mutableCopy];
    for (id key in [self allKeys]) {
        id srcEntry = self[key];
        id dstEntry = dest[key];
        if ([dstEntry isKindOfClass:[NSDictionary class]] &&
            [srcEntry isKindOfClass:[NSDictionary class]]) {
            srcEntry = [srcEntry PNLite_mergedInto:dstEntry];
        }
        dict[key] = srcEntry;
    }
    return dict;
}

@end
