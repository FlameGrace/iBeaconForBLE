//
//  LMFileLogger.m
//  Pods
//
//  Created by Flame Grace on 2017/8/30.
//
//

#import "FGLogger.h"

@interface FGLogger()

@property (copy, nonatomic) NSString *logsDirectory;
@property (readwrite ,copy, nonatomic) NSString *logPath;
@property (copy, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSMutableArray *sortFiles;



@end

@implementation FGLogger

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name
{
    return [self initWithLogsDirectory:logsDirectory fileName:name withQueue:nil];
}

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory fileName:(NSString *)name withQueue:(dispatch_queue_t)queue
{
    //logsDirectory日志自定义路径
    if (self = [super init])
    {
        [self createQueueWithQueue:queue];
        self.maximumFileSize = 10*1024*1024;
        self.rollingFrequency = 7*24*60*60;
        self.maximumNumberOfLogFiles = 100;
        self.fileName = name;
        self.logsDirectory = logsDirectory;
        [self checkRollFiles];
    }
    return self;
}

- (NSDateFormatter *)dateFormat{
    if(!_dateFormat){
        _dateFormat =[[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        //设置东8区
        [_dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    }
    return _dateFormat;
}

- (NSString *)fileName
{
    return _fileName;
}


- (void)createQueueWithQueue:(dispatch_queue_t)queue
{
    if(!queue)
    {
        NSString *queueIdentifer = [NSString stringWithFormat:@"%@-%f",NSStringFromClass([self class]),[NSDate date].timeIntervalSince1970];
        queue = dispatch_queue_create([queueIdentifer UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    self.queue = queue;
}

//获取新日志文件的名称
- (NSString *)newLogFileName
{
    //重写文件名称
    NSString *formattedDate = [self.dateFormat stringFromDate:[NSDate date]];
    NSString *newLogFileName = [NSString stringWithFormat:@"%@%@.log", self.fileName, formattedDate];
    return newLogFileName;
}

//检查回滚操作
- (void)checkRollFiles
{
    NSMutableArray *files = [[NSMutableArray alloc]init];
    NSFileManager *fileManger=[NSFileManager defaultManager];
    NSArray *directory = [fileManger contentsOfDirectoryAtPath:self.logsDirectory error:nil];
    
    for (NSString *path in directory) {
        if([path isEqualToString:@".DS_Store"])
        {
            continue;
        }
        BOOL isdic = NO;
        NSString *fullPath = [self.logsDirectory stringByAppendingPathComponent:path];
        [fileManger fileExistsAtPath:fullPath isDirectory:&isdic];
        if(isdic)
        {
            continue;
        }
        //检查是否达到回滚条件
        NSString *dateString = [path stringByReplacingOccurrencesOfString:self.fileName withString:@""];
        dateString = [dateString stringByReplacingOccurrencesOfString:@".log" withString:@""];
        
        NSDate *rollDate = [NSDate dateWithTimeIntervalSinceNow:-self.rollingFrequency];
        NSString *rollDateString = [self.dateFormat stringFromDate:rollDate];
        //时间早于最晚回滚期限
        if([dateString compare:rollDateString] == NSOrderedAscending)
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
        NSString *fullPath = [self.logsDirectory stringByAppendingPathComponent:path];
        [fileManger removeItemAtPath:fullPath error:nil];
        [files removeObjectAtIndex:0];
    }
}


//创建新的日志文件
- (void)createNewLogFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:self.logsDirectory isDirectory:&isDir];
    if ( !(isDir ==YES && existed == YES) ){//如果没有文件夹则创建
        [fileManager createDirectoryAtPath:self.logsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.logPath = [self.logsDirectory stringByAppendingPathComponent:[self newLogFileName]];
    [[NSFileManager defaultManager]createFileAtPath:self.logPath contents:nil attributes:nil];
    return;
}

- (void)writeLogData:(NSData *)data
{
    dispatch_async(self.queue, ^{
        if(!data || data.length== 0)
        {
            return;
        }
        if(!self.logPath||![[NSFileManager defaultManager]fileExistsAtPath:self.logPath])
        {
            [self createNewLogFile];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logPath];
        @try
        {
            [fileHandle seekToEndOfFile];
            if(fileHandle.offsetInFile < self.maximumFileSize)
            {
                [fileHandle writeData:data];
            }
            [fileHandle closeFile];
        }
        @catch(NSException *exception)
        {
            [fileHandle closeFile];
        }
    });
}

//将内容写入日志文件
- (void)writeLog:(NSString *)log
{
    [self writeLog:log addDateTime:YES];
}


- (void)writeLog:(NSString *)log addDateTime:(BOOL)add
{
    if(!log || log.length < 1)
    {
        return;
    }
    if(add)
    {
        NSString *logTime = [self.dateFormat stringFromDate:[NSDate date]];
        log = [NSString stringWithFormat:@"%@:  %@\n",logTime,log];
    }
    NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];
    [self writeLogData:data];
}


@end
