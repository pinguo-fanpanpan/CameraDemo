//
//  Common.m
//  CameraDemo
//
//  Created by camera360 on 14-10-20.
//  Copyright (c) 2014年 camera360. All rights reserved.
//

#import "Common.h"
#import "Defines.h"

@implementation Common

/**
 *  UIColor生成UIImage
 *
 *  @param color       生成的颜色
 *  @param imageSize   生成的图片大小
 *
 *  @return 生成后的图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)imageSize
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


/**
 *  画线
 *
 *  @param frame         线的大小
 *  @param color         线的颜色
 *  @param parentLayer   线的父图层
 */
+ (void)drawALineWithFrame:(CGRect)frame color:(UIColor *)color inLayer:(CALayer *)parentLayer
{
    CALayer *layer = [CALayer layer];
    layer.frame = frame;
    layer.backgroundColor = color.CGColor;
    [parentLayer addSublayer:layer];
}


/**
 *  保存图片
 *
 *  @param image   需要保存的图片
 */
+ (void)saveImageToPhotoAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"保存图片出错！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else
    {
        NSLog(@"保存图片成功");
    }
}
@end
