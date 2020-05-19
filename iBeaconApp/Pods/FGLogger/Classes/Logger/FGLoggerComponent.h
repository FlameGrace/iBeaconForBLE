//
//  FGLoggerComponent.h
//  DemoProject
//
//  Created by leapmotor on 2020/5/6.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGLoggerComponent : NSObject

+ (NSString *)logPath;
+ (void)setLogPath:(NSString *)logPath;

@end
