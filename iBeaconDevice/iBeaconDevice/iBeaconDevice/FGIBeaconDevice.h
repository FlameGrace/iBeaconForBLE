//
//  FGIBeaconDevice.h
//  DemoProject
//
//  Created by leapmotor on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FGIBeaconDeviceRegion.h"

@interface FGIBeaconDevice : NSObject

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID region:(FGIBeaconDeviceRegion *)region;

-(BOOL)sendData;

@end
