//
//  ScanFrame.h
//  ORCodeDemo
//
//  Created by 小龙虾 on 2017/5/3.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ScanFrame : NSObject
+(CGRect)rectFromeX:(CGFloat)x
               andY:(CGFloat)y
           andWidth:(CGFloat)width
          andHeight:(CGFloat)height;
@end
