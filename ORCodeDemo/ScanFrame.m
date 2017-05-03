//
//  ScanFrame.m
//  ORCodeDemo
//
//  Created by 小龙虾 on 2017/5/3.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//


#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#import "ScanFrame.h"

@implementation ScanFrame
+(CGRect)rectFromeX:(CGFloat)x
               andY:(CGFloat)y
           andWidth:(CGFloat)width
          andHeight:(CGFloat)height
{
    return CGRectMake(y/ScreenHeight, x/ScreenWidth, height/ScreenHeight, width/ScreenWidth);
}
@end
