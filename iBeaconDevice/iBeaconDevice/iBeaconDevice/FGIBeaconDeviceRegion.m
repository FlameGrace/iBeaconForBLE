//
//  FGIBeaconDeviceRegion.m
//  DemoProject
//
//  Created by leapmotor on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGIBeaconDeviceRegion.h"

@interface FGIBeaconDeviceRegion()

@end

@implementation FGIBeaconDeviceRegion

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSInteger)major minor:(NSInteger)minor measuredPower:(NSNumber *)measuredPower {
    self = [super init];
    if (self) {
        self.proximityUUID = proximityUUID;
        self.major = @(major);
        self.minor = @(minor);
        self.measuredPower = measuredPower;
    }
    return self;
}

- (NSMutableDictionary *)peripheralData {
    NSString *beaconKey = @"kCBAdvDataAppleBeaconKey";
    unsigned char advBytes[21] = {0};
    if (!self.measuredPower) {
        self.measuredPower = @-59;
    }
    [self.proximityUUID getUUIDBytes:(unsigned char *)&advBytes];
    advBytes[16] = (unsigned char)(self.major.shortValue >> 8);
    advBytes[17] = (unsigned char)(self.major.shortValue & 255);
    advBytes[18] = (unsigned char)(self.minor.shortValue >> 8);
    advBytes[19] = (unsigned char)(self.minor.shortValue & 255);
    advBytes[20] = self.measuredPower.shortValue;
    NSMutableData *AdvData = [NSMutableData dataWithBytes:advBytes length:21];
    return [@{beaconKey:AdvData} mutableCopy];
}


@end
