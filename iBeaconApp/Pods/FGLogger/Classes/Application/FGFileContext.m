//
//  LMSocketFileContext.m
//  p2p
//
//  Created by Flame Grace on 16/11/3.
//  Copyright © 2016年 hello. All rights reserved.
//

#import "FGFileContext.h"
#import "FGLog.h"

@interface FGFileContext()


@end

@implementation FGFileContext





- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:self.filePath error:&error];
    if(error)
    {
        FGLog(FGLog_UnclearModule,FGLogLevel_MustShow,@"Path (%@) is invalid:%@.", self.filePath,error);
        return;
    }
    
    [self setFileInfo:fileAttributes];
    
}


- (void)setFileInfo:(NSDictionary <NSFileAttributeKey, id> *)fileInfo
{
    if (fileInfo != nil)
    {
        self.fileSize = [fileInfo fileSize];
        self.fileType = [fileInfo fileType];
        self.fileCreateDate = [fileInfo fileCreationDate];
    }
    else
    {
        FGLog(FGLog_UnclearModule,FGLogLevel_MustShow,@"Path (%@) is invalid.", self.filePath);
    }
}


+ (instancetype)context
{
    return [[[self class] alloc]init];
}

+ (float)folderSizeAtPath:(NSString*)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    float folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSize:fileAbsolutePath];
    }
    return folderSize;
}

+ (NSDictionary *)fileInfo:(NSString *)localFilePath error:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dic = [fileManager attributesOfItemAtPath:localFilePath error:error];
    
    return dic;
}
+ (float)fileSize:(NSString *)localFilePath
{
    NSDictionary *dic = [self fileInfo:localFilePath error:nil];
    NSNumber *fileSize = [dic objectForKey:NSFileSize];
    if(fileSize == nil)
    {
        return -1;
    }
    return fileSize.floatValue;
}


+ (NSString *)fileSizeDescription:(NSUInteger)fileSize
{
    NSString *sizeString = @"";
    
    CGFloat k = fileSize/(1024.0);
    CGFloat m = k/(1024.0);
    CGFloat g = m/(1024.0);
    if(m < 1)
    {
        sizeString = [NSString stringWithFormat:@"%.1fK",k];
    }
    else if(g < 1)
    {
        sizeString = [NSString stringWithFormat:@"%.1fM",m];
    }
    else
    {
        sizeString = [NSString stringWithFormat:@"%.2fG",g];
    }
    return sizeString;
}

//从start开始读，读取length长的文件流
-(NSData *)readDataStart:(NSUInteger)start length:(NSUInteger)length
{
    @synchronized (self) {
        NSData* data = nil;
        if(!self.fileName.length || self.fileSize <= 0  || !self.filePath.length || start >=self.fileSize)
        {
            return data;
        }
        
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
        
        [readHandle seekToFileOffset:start];
        
        data = [readHandle readDataOfLength:length];
        [readHandle closeFile];
        
        return data;
    }

}




@end
