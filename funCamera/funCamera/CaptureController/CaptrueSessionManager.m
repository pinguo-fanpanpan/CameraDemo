//
//  CaptrueSessionManager.m
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import "CaptrueSessionManager.h"
#import <ImageIO/ImageIO.h>

@interface CaptrueSessionManager ()

@property (nonatomic,strong) UIView *preView;

@end

@implementation CaptrueSessionManager

//配置镜头拉升参数
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _preScaleNum = 1.f;
        _scaleNum = 1.f;
    }
    return self;
}

- (void)dealloc
{
    [_session stopRunning];
    self.previewLayer = nil;
    self.stillImageOutput = nil;
    self.inputDevice = nil;
    self.session = nil;
}

//配置相机参数
- (void)configureWithParentLayer:(UIView *)parentView preViewRect:(CGRect)preViewRect
{
    self.preView = parentView;
    
    //session
    [self addSession];
    
    //preview
    [self addVideoPreviewLayerWithRect:preViewRect];
    [parentView.layer addSublayer:_previewLayer];
    
    //input
    [self addVideoInputBackCamera:YES];
    
    //output
    [self addStillImageOutput];
    
}

- (void)addSession
{
    AVCaptureSession *sessiom = [[AVCaptureSession alloc] init];
    self.session = sessiom;
}

/**
 *  配置相机预览页面
 *
 *  @param previewRect 预览页面的大小
 */
- (void)addVideoPreviewLayerWithRect:(CGRect)previewRect
{
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
}

/**
 *  添加输入设备
 *
 *  @param backCamera 是否是后置摄像头
 */
- (void)addVideoInputBackCamera:(BOOL)isBackCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionFront)
            {
                frontCamera = device;
            }else
            {
                backCamera = device;
            }
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此设备不支持拍照功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
    NSError *error = nil;
    if (isBackCamera)
    {
        AVCaptureDeviceInput *backCametaInputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error];
        if (!error)
        {
            if ([_session canAddInput:backCametaInputDevice])
            {
                //添加后置摄像头输入设备
                [_session addInput:backCametaInputDevice];
                self.inputDevice  = backCametaInputDevice;
            }else
            {
                NSLog(@"can't add backCamera video input");
            }
        }

    }else
    {
        AVCaptureDeviceInput *frontCametaInputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:frontCamera error:&error];
        if (!error)
        {
            if ([_session canAddInput:frontCametaInputDevice])
            {
                //添加前置摄像头输入设备
                [_session addInput:frontCametaInputDevice];
                self.inputDevice  = frontCametaInputDevice;
            }else
            {
                NSLog(@"can't add frontCamera video input");
            }
        }

    }
}

/**
 *  添加输出设备
 */
- (void)addStillImageOutput
{
    AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];   //输出为jpeg图片
    output.outputSettings = outputSettings;
    self.stillImageOutput = output;
    //添加输出设备
    [_session addOutput:output];
}


/**
 *  前后摄像头切换
 *
 *  @param isBackCamera 是否是后置摄像头
 */
- (void)swithCamera:(BOOL)isBackCamera
{
    if (!_inputDevice)
    {
        return;
    }
    [_session beginConfiguration];
    [_session removeInput:_inputDevice];
    [self addVideoInputBackCamera:isBackCamera];
    [_session commitConfiguration];
}

/**
 *  镜头拉升
 *
 *  @param scaleNum 拉升倍数
 */
- (void)pinchCameraWithScaleNum:(CGFloat)scaleNum
{
    _scaleNum = scaleNum;
    if (_scaleNum < MIN_PINCH_SCALE_NUM)
    {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    }else if (_scaleNum > MAX_PINCH_SCALE_NUM)
    {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"take photo faild");
        return;
    }
    CGFloat maxScale = connection.videoMaxScaleAndCropFactor;
    if (_scaleNum > maxScale) {
        _scaleNum = maxScale;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_previewLayer setAffineTransform:CGAffineTransformMakeScale(_scaleNum, _scaleNum)];
    [CATransaction commit];
    
    _preScaleNum = scaleNum;
}

/**
 *  闪光灯切换
 *  （1.off  2.auto  3.on）
 *  @param sender 切换闪光灯的按钮
 */
- (void)switchFlashMode:(UIButton *)sender
{
    Class deviceClass = NSClassFromString(@"AVCaptureDevice");
    if (!deviceClass)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此设备不支持拍照功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    NSString *imageName = @"";
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    //判断相机是否具有拍照功能
    if ([device hasFlash])
    {
        if (device.flashMode == AVCaptureFlashModeOff)
        {
            device.flashMode = AVCaptureFlashModeAuto;
            imageName = @"flashing_auto@2x.png";
        }else if (device.flashMode == AVCaptureFlashModeAuto)
        {
            device.flashMode = AVCaptureFlashModeOn;
            imageName = @"flashing_on@2x.png";
        }else if (device.flashMode == AVCaptureFlashModeOn)
        {
            device.flashMode = AVCaptureFlashModeOff;
            imageName = @"flashing_off@2x.png";
        }
        if (sender)
        {
            [sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此设备不具备闪光功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [device unlockForConfiguration];
}

/**
 *  相机聚焦功能
 *
 *  @param touchPoint <#touchPoint description#>
 */
- (void)focusInPoint:(CGPoint)touchPoint
{
    CGPoint focusPoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:focusPoint monitorSubjectAreaChange:YES];
}

/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
//    dispatch_async(_sessionQueue, ^{
        AVCaptureDevice *device = [_inputDevice device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
//    });
}

/**
 *  改变屏幕分辨率
 *
 *  @param index 分辨率选择的下标
 */
- (void)changeResolutionRatioWithIndex:(NSInteger)index
{
    CGRect rect = _previewLayer.bounds;
    if (index == 0)
    {
        _previewLayer.frame = CGRectMake(0, 44, rect.size.width, 320);
    }else if (index == 1)
    {
        _previewLayer.frame = CGRectMake(0, 44, rect.size.width, 340);
    }else
    {
        _previewLayer.frame = CGRectMake(0, 44, rect.size.width, 414);
    }
    
}
/**
 *  保存照片到相册
 *
 *  @param stillImage 预览图片
 */
- (void)saveImageToAlbum:(UIImage *)stillImage
{
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection)
    {
        NSLog(@"take photo faild");
        return;
    }
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
        if (imageDataSampleBuffer == NULL)
        {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"存不了T_T" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else
    {
        [self.delegate setButtonImageWithImage:image];
    }
}

@end
