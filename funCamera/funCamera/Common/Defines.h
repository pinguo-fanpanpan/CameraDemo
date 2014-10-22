//
//  Defines.h
//  CameraDemo
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#ifndef CameraDemo_Defines_h
#define CameraDemo_Defines_h

/**
 *  相机：camera needs four frameworks:
 *  1. CoreMedia.framework
 *  2. QuartzCore.framework
 *  3. AVFoundation.framework
 *  4. ImageIO.framework
 *
 */


//cort text里的空格要转一下
#define REPLACE_SPACE_STR(content) [content stringByReplacingOccurrencesOfString:@" " withString:@" "]

//color
#define rgba_Color(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//frame and size
#define DEVICE_BOUNDS    [[UIScreen mainScreen] bounds]
#define DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define APP_FRAME        [[UIScreen mainScreen] applicationFrame]
#define APP_SIZE         [[UIScreen mainScreen] applicationFrame].size

#define SELF_CON_FRAME      self.view.frame
#define SELF_CON_SIZE       self.view.frame.size
#define SELF_VIEW_FRAME     self.frame
#define SELF_VIEW_SIZE      self.frame.size

//设备判断
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //设备类型改为Universal才能生效

#define isPad_AllTargetMode  ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound )  //设备类型为任何类型都能生效


//iOS版本适配
#if __IPHONE_6_0 //iOS6 and later

#   define TextAlignmentCenter    NSTextAlignmentCenter
#   define TextAlignmentLeft      NSTextAlignmentLeft
#   define TextAlignmentRight     NSTextAlignmentRight

#   define kTextLineBreakByWordWrapping_SC      NSLineBreakByWordWrapping
#   define kTextLineBreakByCharWrapping_SC      NSLineBreakByCharWrapping
#   define kTextLineBreakByClipping_SC          NSLineBreakByClipping
#   define kTextLineBreakByTruncatingHead_SC    NSLineBreakByTruncatingHead
#   define kTextLineBreakByTruncatingTail_SC    NSLineBreakByTruncatingTail
#   define kTextLineBreakByTruncatingMiddle_SC  NSLineBreakByTruncatingMiddle

#else   //older versions

#   define kTextAlignmentCenter_SC    UITextAlignmentCenter
#   define kTextAlignmentLeft_SC      UITextAlignmentLeft
#   define kTextAlignmentRight_SC     UITextAlignmentRight

#   define kTextLineBreakByWordWrapping_SC       UILineBreakModeWordWrap
#   define kTextLineBreakByCharWrapping_SC       UILineBreakModeCharacterWrap
#   define kTextLineBreakByClipping_SC           UILineBreakModeClip
#   define kTextLineBreakByTruncatingHead_SC     UILineBreakModeHeadTruncation
#   define kTextLineBreakByTruncatingTail_SC     UILineBreakModeTailTruncation
#   define kTextLineBreakByTruncatingMiddle_SC   UILineBreakModeMiddleTruncation


#endif

#endif
