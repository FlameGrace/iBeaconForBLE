//
//  FGPrintLogViewController.m
//  leapmotor
//
//  Created by Flame Grace on 2017/8/4.
//  Copyright © 2017年 Leapmotor. All rights reserved.
//

#import "FGPrintLogViewController.h"
#import "FGLoggerComponent.h"

@interface FGPrintLogViewController ()
@end

@implementation FGPrintLogViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.subject = @"ios 测试日志";
    [self printPath:[FGLoggerComponent logPath]];
}

@end
