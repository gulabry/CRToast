//
//  MainViewController.m
//  CRNotificationDemo
//
//  Created by Cezary Wojcik on 11/15/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "MainViewController.h"
#import "CRToast.h"

@interface MainViewController ()

@property (weak, readonly) NSDictionary *options;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segFromDirection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segToDirection;
@property (weak, nonatomic) IBOutlet UISegmentedControl *animationTypeSegmentedControl;

@property (weak, nonatomic) IBOutlet UISlider *sliderDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;

@property (weak, nonatomic) IBOutlet UISwitch *showImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coverNavBarSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *springPhysicsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *slideOverSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segAlignment;

@property (weak, nonatomic) IBOutlet UITextField *txtNotificationMessage;
@property (weak, nonatomic) IBOutlet UIButton *showNotificationButton;

@property (assign, nonatomic) NSTextAlignment textAlignment;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame),
                                             CGRectGetMaxY(self.showNotificationButton.frame));

    self.title = @"CRToast";
    [self updateDurationLabel];
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    [self.segFromDirection setTitleTextAttributes:@{NSFontAttributeName : font}
                                     forState:UIControlStateNormal];
    [self.segToDirection setTitleTextAttributes:@{NSFontAttributeName : font}
                                   forState:UIControlStateNormal];
    [self.animationTypeSegmentedControl setTitleTextAttributes:@{NSFontAttributeName : font}
                                                      forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    [_scrollView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length],
                                                    0,
                                                    [self.bottomLayoutGuide length],
                                                    0);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame),
                                             CGRectGetMaxY(self.showNotificationButton.frame));
}

- (void)updateDurationLabel {
    self.lblDuration.text = [NSString stringWithFormat:@"%f seconds", self.sliderDuration.value];
}

- (IBAction)sliderDurationChanged:(UISlider *)sender {
    [self updateDurationLabel];
}

# pragma mark - Show Notification

- (IBAction)btnShowNotificationPressed:(UIButton *)sender {
    [CRToastManager showNotificationWithOptions:[self options]
                                                completionBlock:^{
                                                    NSLog(@"Completed");
                                                }];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    self.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length],
                                                    0,
                                                    CGRectGetHeight([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]),
                                                    0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame),
                                             CGRectGetMaxY(self.showNotificationButton.frame));
}

#pragma mark - Overrides

CRToastAnimationType toastAnimationTypeFromSegmentedControl(UISegmentedControl *segmentedControl) {
    return segmentedControl.selectedSegmentIndex == 0 ? CRToastAnimationTypeLinear :
           segmentedControl.selectedSegmentIndex == 1 ? CRToastAnimationTypeSpring :
           CRToastAnimationTypeGravity;
}

- (NSDictionary*)options {
    NSMutableDictionary *options = [@{kCRToastNotificationTypeKey               : self.coverNavBarSwitch.on ? @(CRToastTypeNavigationBar) : @(CRToastTypeStatusBar),
                                      kCRToastNotificationPresentationTypeKey   : self.slideOverSwitch.on ? @(CRToastPresentationTypeCover) : @(CRToastPresentationTypePush),
                                      kCRToastTextKey                           : self.txtNotificationMessage.text,
                                      kCRToastTimeIntervalKey                   : @(self.sliderDuration.value),
                                      kCRToastTextAlignmentKey                  : @(self.textAlignment),
                                      kCRToastTimeIntervalKey                   : @(self.sliderDuration.value),
                                      kCRToastAnimationInTypeKey                : @(toastAnimationTypeFromSegmentedControl(_animationTypeSegmentedControl)),
                                      kCRToastAnimationOutTypeKey               : @(toastAnimationTypeFromSegmentedControl(_animationTypeSegmentedControl)),
                                      kCRToastAnimationInDirectionKey               : @(self.segFromDirection.selectedSegmentIndex),
                                      kCRToastAnimationOutDirectionKey              : @(self.segToDirection.selectedSegmentIndex)} mutableCopy];
    if (self.showImageSwitch.on) {
        options[kCRToastImageKey] = [UIImage imageNamed:@"alert_icon.png"];
    }
    
    return [NSDictionary dictionaryWithDictionary:options];
}

- (NSTextAlignment)textAlignment {
    NSInteger selectedSegment = self.segAlignment.selectedSegmentIndex;
    return selectedSegment == 0 ? NSTextAlignmentLeft :
    selectedSegment == 1 ? NSTextAlignmentCenter :
    NSTextAlignmentRight;
}

#pragma mark - Gesture Recognizer Selectors

- (void)scrollViewTapped:(UITapGestureRecognizer*)tapGestureRecognizer {
    [_txtNotificationMessage resignFirstResponder];
}

@end