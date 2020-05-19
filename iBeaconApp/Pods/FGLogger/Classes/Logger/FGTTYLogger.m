//
//  LMDDLog.m
//  leapmotor
//
//  Created by Flame Grace on 2017/8/4.
//  Copyright © 2017年 Leapmotor. All rights reserved.
//

#import "FGTTYLogger.h"

@interface FGTTYLogger()

@property (strong, nonatomic) NSMutableDictionary *loggers;

@end

@implementation FGTTYLogger

static FGTTYLogger *shareLogger = nil;

+ (id)shareLogger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareLogger = [[self alloc]initWithLogsDirectory:nil fileName:[self fileName]];
    });
    return shareLogger;
}

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name
{
    if(self = [super initWithLogsDirectory:logsDirectory fileName:name])
    {
        self.loggers = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)writeLog:(NSString *)log moduleName:(NSString *)moduleName
{
    [self writeLog:log];
    if(moduleName)
    {
        FGSingleRunLogger *logger = [self loggerForModuleName:moduleName];
        [logger writeLog:log];
    }
}

- (FGSingleRunLogger *)loggerForModuleName:(NSString *)moduleName
{
    @synchronized(self)
    {
        FGSingleRunLogger *logger = [self.loggers objectForKey:moduleName];
        if(!logger)
        {
            logger = [[FGSingleRunLogger alloc]initWithLogsDirectory:nil fileName:moduleName withQueue:self.queue];
            [self.loggers setObject:logger forKey:moduleName];
        }
        return logger;
    }
}

+ (NSString *)fileName
{
    return @"TTY";
}



@end
