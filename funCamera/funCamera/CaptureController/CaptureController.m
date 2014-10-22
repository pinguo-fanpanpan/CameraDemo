//
//  CaptureController.m
//  funCamera
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import "CaptureController.h"
#import "Common.h"
#import "Defines.h"
#import "Slider.h"

//height
#define CAMERA_TOPVIEW_HEIGHT 44
#define CAMERA_BOTTOMVIEW_HEIGHT 110

#define  BOTTOM_COLOR   [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f] //bottomView的背景色


//对焦
#define ADJUSTING_FOCUS @"adjustingfocus"

@interface CaptureController () {
    CGPoint currTouchPoint;
}

@property (nonatomic,strong) CaptrueSessionManager *sessionManager;

@property (nonatomic,strong) UIView *topContainView;
@property (nonatomic,strong) UIView *bottomContainView;
@property (nonatomic,strong) NSMutableSet *cameraBtnSet;

//对焦图片
@property (nonatomic,strong) UIImageView * focusImageView;

//设置镜头拉升的slider
@property (nonatomic,strong) UISlider *slider;

- (void)addTopContainView;
- (void)addBottomContainView;
- (void)addSliderView;
- (void)buttonPressed:(UIButton *)sender;

@end

@implementation CaptureController

- (instancetype)init {
    self = [super init];
    if (self) {
        currTouchPoint = CGPointZero;
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_sessionManager.session stopRunning];
    self.topContainView = nil;
    self.bottomContainView = nil;
    self.cameraBtnSet = nil;
    self.sessionManager = nil;
    self.focusImageView = nil;
    self.slider = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //配置相机预览框
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, CAMERA_TOPVIEW_HEIGHT, DEVICE_SIZE.width, DEVICE_SIZE.height - CAMERA_TOPVIEW_HEIGHT - CAMERA_BOTTOMVIEW_HEIGHT);
        
    }
    
    //session manager
    CaptrueSessionManager *manager = [[CaptrueSessionManager alloc] init];
    [manager configureWithParentLayer:self.view preViewRect:_previewRect];
    self.sessionManager = manager;
    
    //添加顶部底部视图
    [self addTopContainView];
    [self addBottomContainView];
    [self addSliderView];
    
    [_sessionManager.session startRunning];
}

- (void)addTopContainView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, CAMERA_TOPVIEW_HEIGHT)];
    topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topView];
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(220, 12, 24, 20);
    [switchBtn setBackgroundImage:[UIImage imageNamed:@"switch_camera@2x.png"] forState:UIControlStateNormal];
    [switchBtn setBackgroundImage:[UIImage imageNamed:@"switch_camera_h@2x.png"] forState:UIControlStateSelected];
    [switchBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    switchBtn.tag = 21;
    [topView addSubview:switchBtn];
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(CGRectGetMaxX(switchBtn.frame) + 20, 10, 24, 24);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"flashing_off@2x.png"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    flashBtn.tag = 22;
    [topView addSubview:flashBtn];
//    [topView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSMutableArray *tmpConstrains = [NSMutableArray array];
//    
//    NSString *format = [NSString stringWithFormat:@"|-0-[topView(==%d)]",(NSInteger)DEVICE_SIZE.width];
//    [tmpConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(topView)]];
//    
//    NSString *vFormat = [NSString stringWithFormat:@"V:|-0-[topView(==%d)]",CAMERA_TOPVIEW_HEIGHT];
//    [tmpConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(topView)]];
//    
//    [self.view addConstraints:tmpConstrains];
    self.topContainView = topView;
    
    
}

- (void)addSliderView
{
    Slider *slider = [[Slider alloc] initWithFrame:CGRectMake(280, 146, 40, 200) direction:SCSliderDirectionVertical];
    slider.backgroundColor = [UIColor clearColor];
    slider.maxValue = 3.f;
    slider.minValue = 1.f;
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [_sessionManager pinchCameraWithScaleNum:value];
    }];
    [self.view addSubview:slider];
}

- (void)buttonPressed:(UIButton *)sender
{
    NSInteger index = sender.tag - 20;
    if (index == 1) {
        [_sessionManager swithCamera:sender.selected];
        sender.selected = !sender.selected;
    }else if (index == 2) {
        [_sessionManager swithFlashMode:sender];
    }else if (index == 3) {
        [_sessionManager saveImageToAlbum:nil];
    }
}

- (void)addBottomContainView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_SIZE.height - CAMERA_BOTTOMVIEW_HEIGHT, DEVICE_SIZE.width, CAMERA_BOTTOMVIEW_HEIGHT)];
    bottomView.backgroundColor = BOTTOM_COLOR;
    [self.view addSubview:bottomView];
    
    UIButton *shotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shotBtn.frame = CGRectMake(120, 15, 80, 80);
    [shotBtn setBackgroundImage:[UIImage imageNamed:@"shot_h@2x.png"] forState:UIControlStateNormal];
    [shotBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    shotBtn.tag = 23;
    [bottomView addSubview:shotBtn];

//    [bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSMutableArray *tmpConstrains = [NSMutableArray array];
//    
//    NSString *format = [NSString stringWithFormat:@"|-0-[bottomView(==%d)]",(NSInteger)DEVICE_SIZE.width];
//    [tmpConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(bottomView)]];
//    
//    NSString *vFormat = [NSString stringWithFormat:@"V:|-%d-[bottomView(==%d)]",(NSInteger)DEVICE_SIZE.height - CAMERA_BOTTOMVIEW_HEIGHT,CAMERA_BOTTOMVIEW_HEIGHT];
//    [tmpConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(bottomView)]];
//    
//    [self.view addConstraints:tmpConstrains];
    
    
    self.bottomContainView = bottomView;
}



@end
