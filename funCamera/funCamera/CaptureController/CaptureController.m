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

@interface CaptureController ()
{
    CGPoint currTouchPoint;
}

@property (nonatomic,strong) CaptrueSessionManager *sessionManager;

@property (nonatomic,strong) UIView *topContainView;
@property (nonatomic,strong) UIView *bottomContainView;
@property (nonatomic,strong) NSMutableSet *cameraBtnSet;
@property (nonatomic,strong) UIView *settingVeiw;

//对焦图片
@property (nonatomic,strong) UIImageView * focusImageView;

//segment
@property (nonatomic,strong) UISegmentedControl *segControl;


//设置镜头拉升的slider
@property (nonatomic,strong) Slider *slider;

- (void)addTopContainView;
- (void)addBottomContainView;
- (void)addSliderView;
- (void)addFocusImageView;

- (void)buttonPressed:(UIButton *)sender;
- (void)controlPressed:(UIButton *)sender;

@end

@implementation CaptureController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
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
    
    self.view.backgroundColor = BOTTOM_COLOR;
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //配置相机预览框
    if (CGRectEqualToRect(_previewRect, CGRectZero))
    {
        self.previewRect = CGRectMake(0, CAMERA_TOPVIEW_HEIGHT, DEVICE_SIZE.width, DEVICE_SIZE.height - CAMERA_TOPVIEW_HEIGHT - CAMERA_BOTTOMVIEW_HEIGHT);
        
    }
    
    //session manager
    CaptrueSessionManager *manager = [[CaptrueSessionManager alloc] init];
    manager.delegate = self;
    [manager configureWithParentLayer:self.view preViewRect:_previewRect];
    self.sessionManager = manager;
    
    //添加顶部底部视图
    [self addTopContainView];
    [self addBottomContainView];
    [self addSliderView];
    [self addFocusImageView];
    [self addSettingVeiw];
    
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
    
    self.topContainView = topView;
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
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(35, 30, 50, 50);
    albumBtn.backgroundColor = [UIColor clearColor];
    albumBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    albumBtn.layer.borderWidth = 2;
    albumBtn.layer.borderColor = [rgba_Color(147, 151, 156, 1.0) CGColor];
    [albumBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    albumBtn.tag = 24;
    [bottomView addSubview:albumBtn];
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(CGRectGetMaxX(shotBtn.frame) + 10, 15, 100, 100);
    [setBtn setImage:[UIImage imageNamed:@"setting_service_agreement_01@2x.png"] forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    setBtn.tag = 25;
    [bottomView addSubview:setBtn];
    
    self.bottomContainView = bottomView;
}

- (void)addSliderView
{
    Slider *slider = [[Slider alloc] initWithFrame:CGRectMake(280, 146, 40, 200) direction:SCSliderDirectionVertical];
    slider.backgroundColor = [UIColor clearColor];
     [slider fillLineColor:[UIColor whiteColor] slidedLineColor:rgba_Color(120, 174, 0, 2.f) circleColor:[UIColor whiteColor] shouldShowHalf:YES lineWidth:1.f circleRadius:10.f isFullFillCircle:NO];
    slider.maxValue = 3.f;
    slider.minValue = 1.f;
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [_sessionManager pinchCameraWithScaleNum:value];
    }];
    [self.view addSubview:slider];
    
    self.slider = slider;
}

- (void)addFocusImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 80, 80)];
    imageView.alpha = 0;
    imageView.image = [UIImage imageNamed:@"touch_focus_x@2x.png"];
    [self.view addSubview:imageView];
    
    self.focusImageView = imageView;
}

- (void)addSettingVeiw
{
    UIView *setView = [[UIView alloc] initWithFrame:CGRectMake((DEVICE_SIZE.width - 240)/2 - 10, CGRectGetMinY(_bottomContainView.frame) - 250, 240, 240)];
    setView.backgroundColor = [UIColor blackColor];
    setView.alpha = .0f;
    setView.layer.cornerRadius = 5;
    [self.view addSubview:setView];
    
    self.settingVeiw = setView;
    
    NSArray *labText = @[@"分辨率:",@"曝    光:",@"白平衡:",@"帧    率:",@"I  S  O :"];
    for (int i = 0; i < 5; i ++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30 + 40 * i, 70, 25)];
        label.text = labText[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:18];
        [_settingVeiw addSubview:label];
    }
    
    //分辨率
    UISegmentedControl *segMentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1 : 1",@"9 : 16",@"3 : 4"]];
    segMentedControl.tintColor = [UIColor whiteColor];
    segMentedControl.frame = CGRectMake(90, 30, 130, 25);
    [segMentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
    [_settingVeiw addSubview:segMentedControl];
    
    self.segControl = segMentedControl;
    
    //曝光率和白平衡
    for (int i = 0; i < 4; i ++)
    {
        Slider *slider = [[Slider alloc] initWithFrame:CGRectMake(90, 70 + 40 * i, 135, 25) direction:SCSliderDirectionHorizonal] ;
        [slider fillLineColor:[UIColor whiteColor] slidedLineColor:rgba_Color(120, 174, 0, 2.f) circleColor:[UIColor whiteColor] shouldShowHalf:YES lineWidth:1.f circleRadius:10.f isFullFillCircle:NO];
        [_settingVeiw addSubview:slider];
    }
}

- (void)buttonPressed:(UIButton *)sender
{
    NSInteger index = sender.tag - 20;
    if (index == 1)
    {
        [_sessionManager swithCamera:sender.selected];
        sender.selected = !sender.selected;
    }else if (index == 2)
    {
        [_sessionManager switchFlashMode:sender];
    }else if (index == 3)
    {
        [_sessionManager saveImageToAlbum:nil];
    }else if (index == 5)
    {
        sender.selected = !sender.selected;
        if (sender.selected)
        {
            _settingVeiw.alpha = .5f;
        }else
        {
            _settingVeiw.alpha = .0f;
        }
    }
}

- (void)controlPressed:(UIButton *)sender
{
    NSInteger selIndex = _segControl.selectedSegmentIndex;
    [_sessionManager changeResolutionRatioWithIndex:selIndex];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    CGRect managerBounds = _sessionManager.previewLayer.bounds;
    CGRect rect = CGRectMake(managerBounds.origin.x, managerBounds.origin.y + 44, managerBounds.size.width, managerBounds.size.height);
    if (CGRectContainsPoint(rect, currTouchPoint) == NO)
    {
        return;
    }
    
    //相机聚焦
    [_sessionManager focusInPoint:currTouchPoint];
    
    if (_settingVeiw.alpha == .0f) {
        [_focusImageView setCenter:currTouchPoint];
        _focusImageView.alpha = 1.f;
        [UIView animateWithDuration:1.f animations:^
         {
             _focusImageView.alpha = 0;
         }];
    }
}

- (void)setButtonImageWithImage:(UIImage *)image
{
    UIView *subView = [_bottomContainView viewWithTag:24];
    if (![subView isKindOfClass:[UIButton class]])
    {
        return;
    }
    UIButton *button = (UIButton *)subView;
    [button setImage:image forState:UIControlStateNormal];
}
@end
