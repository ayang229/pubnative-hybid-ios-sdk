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

#import "PNLiteDemoMoPubMediationSettingsViewController.h"
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoMoPubMediationSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nativeAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *leaderboardAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *bannerAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mRectAdUnitIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAdUnitIDTextField;
@end

@implementation PNLiteDemoMoPubMediationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"MoPub Mediation Settings";
    self.nativeAdUnitIDTextField.text = [PNLiteDemoSettings sharedInstance].moPubMediationNativeAdUnitID;
    self.leaderboardAdUnitIDTextField.text = [PNLiteDemoSettings sharedInstance].moPubMediationLeaderboardAdUnitID;
    self.bannerAdUnitIDTextField.text = [PNLiteDemoSettings sharedInstance].moPubMediationBannerAdUnitID;
    self.mRectAdUnitIDTextField.text = [PNLiteDemoSettings sharedInstance].moPubMediationMRectAdUnitID;
    self.interstitialAdUnitIDTextField.text = [PNLiteDemoSettings sharedInstance].moPubMediationInterstitialAdUnitID;
}
- (IBAction)saveMoPubMediationSettingsTouchUpInside:(UIButton *)sender
{
    [PNLiteDemoSettings sharedInstance].moPubMediationNativeAdUnitID = self.nativeAdUnitIDTextField.text;
    [PNLiteDemoSettings sharedInstance].moPubMediationLeaderboardAdUnitID = self.leaderboardAdUnitIDTextField.text;
    [PNLiteDemoSettings sharedInstance].moPubMediationBannerAdUnitID = self.bannerAdUnitIDTextField.text;
    [PNLiteDemoSettings sharedInstance].moPubMediationMRectAdUnitID = self.mRectAdUnitIDTextField.text;
    [PNLiteDemoSettings sharedInstance].moPubMediationInterstitialAdUnitID = self.interstitialAdUnitIDTextField.text;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
