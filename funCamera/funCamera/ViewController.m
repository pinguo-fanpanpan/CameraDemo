//
//  ViewController.m
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationController *nav = [[NavigationController alloc] init];
    nav.navigationDelegate = self;
    [self configureNotification:YES];
    
    [nav showCameraWithParentController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNotification:(BOOL)toAdd {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notificationTakePicture" object:nil];
    if (toAdd) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackNotificationForFilter:) name:@"notificationTakePicture" object:nil];
    }
}

- (void)callbackNotificationForFilter:(NSNotification*)noti {
//    UIViewController *cameraCon = noti.object;
//    if (!cameraCon) {
//        return;
//    }
//    UIImage *finalImage = [noti.userInfo objectForKey:kImage];
//    if (!finalImage) {
//        return;
//    }
//    PostViewController *con = [[PostViewController alloc] init];
//    con.postImage = finalImage;
//    
//    if (cameraCon.navigationController) {
//        [cameraCon.navigationController pushViewController:con animated:YES];
//    } else {
//        [cameraCon presentModalViewController:con animated:YES];
//    }
}

@end
