//
//  FGSingleRunLogger.m
//  LMToolsKit
//
//  Created by Flame Grace on 2017/9/1.
//  Copyright © 2017年 zhouhaoran. All rights reserved.
//

#import "FGSingleRunLogger.h"

@implementation FGSingleRunLogger

static NSString *runDirectory = nil;

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name withQueue:(dispatch_queue_t)queue
{
    if(self = [super initWithLogsDirectory:[self runDirectory] fileName:name withQueue:queue])
    {
        
    }
    return self;
}

- (NSString *)newLogFileName
{
    return [self.fileName stringByAppendingString:@".log"];
}

- (NSString *)runDirectory
{
    if(!runDirectory)
    {
        NSString *formattedDate = [self.dateFormat stringFromDate:[NSDate date]];
        runDirectory = [[FGLoggerComponent logPath]stringByAppendingPathComponent:formattedDate];
    }
    return runDirectory;
}

//检查回滚操作
- (void)checkRollFiles
{
    NSMutableArray *files = [[NSMutableArray alloc]init];
    NSFileManager *fileManger=[NSFileManager defaultManager];
    NSArray *directory = [fileManger contentsOfDirectoryAtPath:[FGLoggerComponent logPath] error:nil];
    
    for (NSString *path in directory) {
        BOOL isdic = NO;
        NSString *fullPath = [[FGLoggerComponent logPath] stringByAppendingPathComponent:path];
        [fileManger fileExistsAtPath:fullPath isDirectory:&isdic];
        if(!isdic)
        {
            continue;
        }
        
        NSDate *rollDate = [NSDate dateWithTimeIntervalSinceNow:-self.rollingFrequency];
        NSString *rollDateString = [self.dateFormat stringFromDate:rollDate];
        //时间早于最晚回滚期限
        if([path compare:rollDateString] == NSOrderedAscending)
        {
            [fileManger removeItemAtPath:fullPath error:nil];
        }
        else
        {
            [files addObject:path];
        }
    }
    
    [files sortUsingSelector:@selector(compare:)];
    
    if(self.maximumNumberOfLogFiles == 0)
    {
        return;
    }
    while (files.count > self.maximumNumberOfLogFiles) {
        
        if(files.count == 0)
        {
            break;
        }
        NSString *path = [files firstObject];
        NSString *fullPath = [[FGLoggerComponent logPath] stringByAppendingPathComponent:path];
        [fileManger removeItemAtPath:fullPath error:nil];
        [files removeObjectAtIndex:0];
    }
}


@end
