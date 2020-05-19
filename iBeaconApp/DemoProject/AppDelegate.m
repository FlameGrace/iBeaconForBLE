//
//  AppDelegate.m
//  DemoProject
//
//  Created by Mac on 2019/12/20.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "AppDelegate.h"
#import "FGIBeaconHandle.h"
#import "FGPrintLogViewController.h"
#import "FGLog.h"

@interface AppDelegate ()

@property (strong, nonatomic) FGIBeaconHandle *handle;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    FGLog(FGLog_Home, FGLogLevel_MustShow,@"进入首页");
    self.handle = [[FGIBeaconHandle alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *rootNaviCon = [[UINavigationController alloc]initWithRootViewController:[[FGPrintLogViewController alloc]init]];
    //禁用左滑返回手势，防止页面卡死
    rootNaviCon.interactivePopGestureRecognizer.enabled = NO;
    rootNaviCon.navigationBar.hidden = YES;
    rootNaviCon.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = rootNaviCon;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
