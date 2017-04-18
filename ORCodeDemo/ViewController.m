//
//  ViewController.m
//  ORCodeDemo
//
//  Created by 小龙虾 on 2017/4/18.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "SCanVC.h"
#import "libqrencode/QRCodeGenerator.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageViews;
@property (nonatomic, strong) UIImageView *coverImg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"二维码生成"];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStyleDone target:self action:@selector(push:)];
    [self.navigationItem setRightBarButtonItem:bar];
    [self.view addSubview:self.imageViews];
}

-(void)push:(UIBarButtonItem *)sender
{
    SCanVC *vc = [[SCanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIImageView *)imageViews
{
    if (!_imageViews) {
        self.imageViews = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 125, self.view.center.y - 125, 250, 250)];
        UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:@"BEGIN:VCARD\n FN:黄而慧Kent\nORG:青橙科技\nADR;TYPE=WORK:;;北京朝阳区酒仙桥北路798艺术区706北三街\nTITLE:CEO\nTEL;CELL:18601155940\nTEL;WORK:01052089816\nEMAIL;TYPE=PREF,INTERNET:kent@qingcheng.it\nURL:http://www.qingchengfit.cn\nEND:VCARD"] withSize:250];
        
        UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:60 andGreen:74 andBlue:89];
        self.imageViews.image = customQrcode;
        //设置阴影
        self.imageViews.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageViews.layer.shadowRadius = 2.0;
        self.imageViews.layer.shadowOffset = CGSizeMake(0, 2);
        self.imageViews.layer.shadowOpacity = 0.5;
    }
    return _imageViews;
}

-(UIImageView *)coverImg
{
    if (!_coverImg) {
        self.coverImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test"]];
        float w = 80;
        float h = 80;
        float x = (self.imageViews.frame.size.width-w)/2;
        float y = (self.imageViews.frame.size.height-h)/2;
        self.coverImg.frame = CGRectMake(x, y, w, h);
    }
    return _coverImg;
}



#pragma mark - InterpolatedUIImage
//调整生成的二维码图片大小和位置
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    // 获取二维码图片的原始大小
    CGRect extent = CGRectIntegral(image.extent);
    // 缩放的比例
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator
//生成二维码图片
- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
//填充二维码颜色
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
