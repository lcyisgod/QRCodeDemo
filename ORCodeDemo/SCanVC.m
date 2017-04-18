//
//  SCanVC.m
//  ORCodeDemo
//
//  Created by 小龙虾 on 2017/4/18.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "SCanVC.h"
#import <AVFoundation/AVFoundation.h>
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface SCanVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic, strong)AVCaptureDevice *device;
@property(nonatomic, strong)AVCaptureInput *input;
@property(nonatomic, strong)AVCaptureMetadataOutput *outPut;
@property(nonatomic, strong)AVCaptureSession *session;
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong)UIView *bgview;
@end

@implementation SCanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"扫一扫"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createDevice];
}

-(void)createDevice
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    _outPut = [[AVCaptureMetadataOutput alloc] init];
    //设置扫描的实际区域
    //注意该区域的frmae是一个比例尺,默认为(0,0,1,1)
    //该比例尺是一个镜像尺度，即(y/heigt,x/width,h/height,w/width)
    [_outPut setRectOfInterest:CGRectMake((ScreenHeight/2-100)/ScreenHeight, (ScreenWidth/2-100)/ScreenWidth, 200/ScreenWidth, 200/ScreenHeight)];
    [_outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.outPut]) {
        [_session addOutput:self.outPut];
    }
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:_previewLayer above:0];
    
    //设置扫描的位置
    self.bgview = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-100, 200, 200)];
    self.bgview.layer.borderColor = [UIColor redColor].CGColor;
    self.bgview.layer.borderWidth = 2;
    [self.view addSubview:self.bgview];
    
    _outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [_session startRunning];

}

#pragma mark - delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count]>0) {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *metadaObject = [metadataObjects objectAtIndex:0];
        stringValue = metadaObject.stringValue;
        NSLog(@"%@",stringValue);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
