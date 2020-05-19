//
//  ViewController.m
//  iBeaconDevice
//
//  Created by leapmotor on 2020/4/28.
//  Copyright © 2020 leapmotor. All rights reserved.
//

#import "ViewController.h"
#import "FGIBeaconDevice.h"

static NSString *const ServiceUUID1 =  @"FFFE";
static NSString *const readwriteCharacteristicUUID =  @"FFFA";
static NSString *const StoreUUID =  @"2DAB592C-2643-4F5F-8A75-4A5F19A9D7B2";

@interface ViewController()

@property (strong, nonatomic) FGIBeaconDevice *device;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSButton *btn = [[NSButton alloc]initWithFrame:CGRectMake(50, 100, 100, 44)];
    btn.title = @"发送数据";
    btn.target = self;
    btn.action = @selector(sendData);
//    [btn setTitle:@"发送数据" forState:UIControlStateNormal];
//    btn.backgroundColor = [UIColor blueColor];
//    [btn addTarget:self action:@selector(changeAllowRotation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"2DAB592C-2643-4F5F-8A75-4A5F19A9D7B2"];
    FGIBeaconDeviceRegion *region = [[FGIBeaconDeviceRegion alloc]initWithProximityUUID:uuid major:0 minor:0 measuredPower:nil];
    self.device = [[FGIBeaconDevice alloc]initWithServiceUUID:ServiceUUID1 characteristicUUID:readwriteCharacteristicUUID region:region];
//    [self connect];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)sendData{
    [self.device sendData];
}


@end
