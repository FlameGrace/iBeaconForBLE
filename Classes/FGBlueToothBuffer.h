//
//  FGBlueToothBuffer.h
//  leapmotor
//
//  Created by MAC on 2018/6/25.
//  Copyright © 2018年 Leapmotor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FGBlueToothBuffer;

@protocol FGBlueToothBufferDelegate <NSObject>

- (void)blueToothBuffer:(FGBlueToothBuffer *)buffer needToSendPacket:(NSData *)data;

@end

@interface FGBlueToothBuffer : NSObject

@property (weak, nonatomic) id<FGBlueToothBufferDelegate> delegate;

- (void)addBuffer:(NSData *)data highPriority:(BOOL)high;
- (void)sendNextPacket;

@end
