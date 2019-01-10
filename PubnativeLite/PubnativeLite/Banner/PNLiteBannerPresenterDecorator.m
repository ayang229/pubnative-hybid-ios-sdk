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

#import "PNLiteBannerPresenterDecorator.h"

@interface PNLiteBannerPresenterDecorator ()

@property (nonatomic, strong) HyBidAdPresenter *adPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic, strong) NSObject<HyBidAdPresenterDelegate> *adPresenterDelegate;

@end

@implementation PNLiteBannerPresenterDecorator

- (void)dealloc
{
    self.adPresenter = nil;
    self.adTracker = nil;
    self.adPresenterDelegate = nil;
}

- (void)load
{
    [self.adPresenter load];
}

- (void)startTracking
{
    [self.adPresenter startTracking];
}

- (void)stopTracking
{
    [self.adPresenter stopTracking];
}

- (instancetype)initWithBannerPresenter:(HyBidAdPresenter *)bannerPresenter
                          withAdTracker:(HyBidAdTracker *)adTracker
                           withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.adPresenter = bannerPresenter;
        self.adTracker = adTracker;
        self.adPresenterDelegate = delegate;
    }
    return self;
}

#pragma mark HyBidAdPresenterDelegate

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didLoadWithAd:(UIView *)adView
{
    [self.adTracker trackImpression];
    [self.adPresenterDelegate adPresenter:adPresenter didLoadWithAd:adView];
}

- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter
{
    [self.adTracker trackClick];
    [self.adPresenterDelegate adPresenterDidClick:adPresenter];
}

- (void)adPresenter:(HyBidAdPresenter *)adPresenter didFailWithError:(NSError *)error
{
    [self.adPresenterDelegate adPresenter:adPresenter didFailWithError:error];
}

@end
