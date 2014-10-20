//
//  NavigationController.h
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@protocol NavigationControllerDelegate;

@interface NavigationController : UINavigationController

- (void)showCameraWithParentController:(UIViewController*)parentController;

@property (nonatomic,assign) BOOL isStatusBarHiddenBeforeShowCamera;
@property (nonatomic,assign) id <NavigationControllerDelegate>navigationDelegate;

@end

@protocol NavigationControllerDelegate <NSObject>

@optional

- (BOOL)willDismissNavigationController:(NavigationController*)navigationController;

- (BOOL)didTakePicture:(NavigationController*)navigationController;

@end
