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

#import "PNLiteDemoPNLiteMRectViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteMRectViewController () <PNLiteAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet PNLiteMRectAdView *mRectAdView;

@end

@implementation PNLiteDemoPNLiteMRectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"PNLite MRect";
    [self.mRectLoaderIndicator stopAnimating];
}

- (IBAction)requestMRectTouchUpInside:(id)sender
{
    self.mRectAdView.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    [self.mRectAdView loadWithZoneID:[PNLiteDemoSettings sharedInstance].zoneID andWithDelegate:self];
}

#pragma mark - PNLiteAdViewDelegate

-(void)adViewDidLoad
{
    NSLog(@"MRect Ad View did load:");
    self.mRectAdView.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
}

- (void)adViewDidFailWithError:(NSError *)error
{
    NSLog(@"MRect Ad View did fail with error: %@",error.localizedDescription);
    [self.mRectLoaderIndicator stopAnimating];
}

- (void)adViewDidTrackClick
{
    NSLog(@"MRect Ad View did track click:");
}

- (void)adViewDidTrackImpression
{
    NSLog(@"MRect Ad View did track impression:");
}

@end
