//
//  FGBlueToothBuffer.m
//  leapmotor
//
//  Created by MAC on 2018/6/25.
//  Copyright © 2018年 Leapmotor. All rights reserved.
//

#import "FGBlueToothBuffer.h"

#define BlueToothMaxLength (100)

@interface FGBlueToothBuffer()<FGBlueToothBufferDelegate>

@property (strong, nonatomic) NSMutableArray *priorityHighBufferAr;  //高优先级buffer数组
@property (strong, nonatomic) NSMutableArray *priorityLowBufferAr; //低优先级buffer数组
@property (strong, nonatomic) NSData *currentBuffer;  //当前传输的buffer
@property (assign, nonatomic) NSUInteger currentBufferOffset; //当前传输的buffer数据的偏移量

@end

@implementation FGBlueToothBuffer

- (instancetype)init
{
    if(self = [super init])
    {
        self.priorityLowBufferAr = [[NSMutableArray alloc]init];
        self.priorityHighBufferAr = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)blueToothBuffer:(FGBlueToothBuffer *)buffer needToSendPacket:(NSData *)data
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(blueToothBuffer:needToSendPacket:)])
    {
        [self.delegate blueToothBuffer:buffer needToSendPacket:data];
    }
}

- (void)addBuffer:(NSData *)data highPriority:(BOOL)high;
{
    if(!data)
    {
        return;
    }
    if(!high)
    {
        if(self.priorityLowBufferAr.count >= 100)
        {
            return;
        }
        [self.priorityLowBufferAr addObject:data];
    }
    else
    {
        if(self.priorityHighBufferAr.count >= 100)
        {
            return;
        }
        [self.priorityHighBufferAr addObject:data];
    }
    [self sendNextPacket];
}


- (void)sendNextPacket
{
    @synchronized (self) {
        [self send];
    }
}


- (void)send
{
    
    //先把当前buffer发送完
    if(self.currentBuffer)
    {
        if(self.currentBuffer.length > self.currentBufferOffset + BlueToothMaxLength)
        {
            NSData *data = [self.currentBuffer subdataWithRange:NSMakeRange(self.currentBufferOffset, BlueToothMaxLength)];
            self.currentBufferOffset += BlueToothMaxLength;
            [self blueToothBuffer:self needToSendPacket:data];
            return;
        }
        
        NSData *data = [self.currentBuffer subdataWithRange:NSMakeRange(self.currentBufferOffset, self.currentBuffer.length - self.currentBufferOffset)];
        self.currentBufferOffset = 0;
        self.currentBuffer = nil;
        [self blueToothBuffer:self needToSendPacket:data];
        return;
    }
    if(self.priorityHighBufferAr.count > 0)
    {
        self.currentBuffer = [self.priorityHighBufferAr firstObject];
        [self.priorityHighBufferAr removeObject:self.currentBuffer];
        [self send];
        return;
    }
    if(self.priorityLowBufferAr.count > 0)
    {
        self.currentBuffer = [self.priorityLowBufferAr firstObject];
        [self.priorityLowBufferAr removeObject:self.currentBuffer];
        [self send];
        return;
    }
}


@end
