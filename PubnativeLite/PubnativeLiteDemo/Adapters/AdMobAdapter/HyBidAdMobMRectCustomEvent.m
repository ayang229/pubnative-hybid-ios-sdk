//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "HyBidAdMobMRectCustomEvent.h"
#import "HyBidAdMobUtils.h"

@interface HyBidAdMobMRectCustomEvent() <HyBidAdViewDelegate>

@property (nonatomic, strong) HyBidMRectAdView *mRectAdView;

@end

@implementation HyBidAdMobMRectCustomEvent

@synthesize delegate;

- (void)dealloc {
    self.mRectAdView = nil;
}

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString * _Nullable)serverParameter
                  label:(NSString * _Nullable)serverLabel
                request:(nonnull GADCustomEventRequest *)request {
    if ([HyBidAdMobUtils areExtrasValid:serverParameter]) {
        if (CGSizeEqualToSize(kGADAdSizeMediumRectangle.size, adSize.size)) {
            if ([HyBidAdMobUtils appToken:serverParameter] != nil || [[HyBidAdMobUtils appToken:serverParameter] isEqualToString:[HyBidSettings sharedInstance].appToken]) {
                self.mRectAdView = [[HyBidMRectAdView alloc] init];
                self.mRectAdView.isMediation = YES;
                [self.mRectAdView loadWithZoneID:[HyBidAdMobUtils zoneID:serverParameter] andWithDelegate:self];
            } else {
                [self invokeFailWithMessage:@"The provided app token doesn't match the one used to initialise HyBid."];
                return;
            }
        } else {
            [self invokeFailWithMessage:@"Wrong ad size."];
            return;
        }
    } else {
        [self invokeFailWithMessage:@"Failed mRect ad fetch. Missing required server extras."];
        return;
    }
}


- (void)invokeFailWithMessage:(NSString *)message {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:message];
    [self.delegate customEventBanner:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    [self invokeFailWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    [self.delegate customEventBannerWasClicked:self];
    [self.delegate customEventBannerWillLeaveApplication:self];
}

@end
