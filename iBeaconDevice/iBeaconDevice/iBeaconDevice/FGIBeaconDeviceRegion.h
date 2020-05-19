//
//  FGIBeaconDeviceRegion.h
//  DemoProject
//
//  Created by leapmotor on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGIBeaconDeviceRegion : NSObject

@property (strong, nonatomic) NSUUID *proximityUUID;
@property (assign, nonatomic) NSNumber *major;
@property (assign, nonatomic) NSNumber *minor;
@property (assign, nonatomic) NSNumber *measuredPower;


- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSInteger)major minor:(NSInteger)minor measuredPower:(NSNumber *)measuredPower;
- (NSMutableDictionary *)peripheralData;

@end
