//
//  LMDDLog.h
//  leapmotor
//
//  Created by Flame Grace on 2017/8/4.
//  Copyright © 2017年 Leapmotor. All rights reserved.
//  将控制台输出的日志自动写入文件

#import <Foundation/Foundation.h>
#import "FGSingleRunLogger.h"

@interface FGTTYLogger : FGSingleRunLogger

+ (id)shareLogger;

- (void)writeLog:(NSString *)log moduleName:(NSString *)moduleName;

@end
