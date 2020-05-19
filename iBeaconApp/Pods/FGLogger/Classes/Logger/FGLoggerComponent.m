//
//  FGLoggerComponent.m
//  DemoProject
//
//  Created by leapmotor on 2020/5/6.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGLoggerComponent.h"

@implementation FGLoggerComponent

static NSString *fg_pravite_logPath_LoggerComponent;

+ (NSString *)logPath{
    if(!fg_pravite_logPath_LoggerComponent){
        NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Logs"];
        BOOL isDir = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:logPath isDirectory:&isDir];
        if(!isExist || !isDir) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:&error];
            if(error){
                NSLog(@"创建日志目录失败");
            }
        }
        fg_pravite_logPath_LoggerComponent = logPath;
    }
    return fg_pravite_logPath_LoggerComponent;
}

+ (void)setLogPath:(NSString *)logPath{
    fg_pravite_logPath_LoggerComponent = logPath;
}

@end
