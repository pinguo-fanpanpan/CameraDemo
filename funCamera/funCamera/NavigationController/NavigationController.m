//
//  NavigationController.m
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import "NavigationController.h"
#import "CaptureController.h"

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
    
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}


- (void)showCameraWithParentController:(UIViewController *)parentController {
    CaptureController *capc = [[CaptureController alloc] init];
    [self setViewControllers:[NSArray arrayWithObjects:capc, nil]];
    [parentController presentViewController:self animated:NO completion:nil];
}
@end
