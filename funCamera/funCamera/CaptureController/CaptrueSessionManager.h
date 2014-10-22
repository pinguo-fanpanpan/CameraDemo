//
//  CaptrueSessionManager.h
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Defines.h"

#define  MAX_PINCH_SCALE_NUM 3.f
#define  MIN_PINCH_SCALE_NUM 1.f

@protocol CaptureSessionMangeger;

@interface CaptrueSessionManager : NSObject

//AVCapture参数
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

//镜头拉升参数
@property (nonatomic,assign) CGFloat preScaleNum;
@property (nonatomic,assign) CGFloat scaleNum;

//相机代理
@property (nonatomic,assign) id <CaptureSessionMangeger> delegate;

//配置相机参数
- (void)configureWithParentLayer:(UIView*)parentView preViewRect:(CGRect)preViewRect;

//前后摄像头切换
- (void)swithCamera:(BOOL)isBackCamera;

//镜头拉升
- (void)pinchCameraWithScaleNum:(CGFloat)scaleNum;

//闪光灯配置
- (void)swithFlashMode:(UIButton *)sender;

//聚焦
- (void)focusInPoint:(CGPoint)touchPoint;

//拍照，将图片保存到相册
- (void)saveImageToAlbum:(UIImage *)stillImage;

@end

@protocol CaptureSessionMangeger <NSObject>

@optional


@end
