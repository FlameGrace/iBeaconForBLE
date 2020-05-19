//
//  LMSocketFileContext.h
//  p2p
//
//  Created by Flame Grace on 16/11/3.
//  Copyright © 2016年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@interface FGFileContext : NSObject


@property (nonatomic,strong)  NSString *fileType;//image  or  movie

@property (nonatomic,strong)  NSString* filePath;//文件在app中路径
@property (nonatomic,strong)  NSString* fileName;//文件名
@property (nonatomic,assign)  unsigned long long fileSize;//文件大小

@property (nonatomic,strong)  NSDate* fileCreateDate;
@property (nonatomic,strong)  UIImage* fileThumbImage;//文件缩略图

+ (instancetype)context;

- (void)setFileInfo:(NSDictionary <NSFileAttributeKey, id> *)fileInfo;

//将以字节为单位的文件长度根据大小转换为1.1G/400.1M/200.1k的形式
+ (NSString *)fileSizeDescription:(NSUInteger)fileSize;

//从start开始读，读取length长的文件流
-(NSData *)readDataStart:(NSUInteger)start length:(NSUInteger)length;

+ (float)folderSizeAtPath:(NSString*)folderPath;



@end
