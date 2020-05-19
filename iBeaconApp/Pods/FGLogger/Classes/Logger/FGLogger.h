//
//  LMFileLogger.h
//  Pods
//
//  Created by Flame Grace on 2017/8/30.
//
//

#import <Foundation/Foundation.h>
#import "FGLoggerComponent.h"

@interface FGLogger : NSObject

@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (readonly ,copy, nonatomic) NSString *logPath;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) NSInteger maximumNumberOfLogFiles; //文件最大数量,0无限制，默认100
@property (assign, nonatomic) NSInteger rollingFrequency;  //回滚周期,单位：分钟，默认7*24*60*60
@property (assign, nonatomic) NSInteger maximumFileSize;  //单个文件最大容量,单位：字节，默认10*1024*1024


- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name;
- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name withQueue:(dispatch_queue_t)queue;

- (NSString *)newLogFileName;
//创建新的日志文件
- (void)createNewLogFile;
//检查并回滚日志文件
- (void)checkRollFiles;

- (NSString *)fileName;

//将内容写入日志文件
- (void)writeLog:(NSString *)log;
//将内容写入日志文件，并是否自动在前面追加日期
- (void)writeLog:(NSString *)log addDateTime:(BOOL)add;

- (void)writeLogData:(NSData *)data;


@end
