//
//  FGBluetoothConnectionProtocol.h
//  DemoProject
//
//  Created by Mac on 2020/1/20.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FGLog.h"

typedef NS_ENUM(NSInteger,FGLogForBlueTooth) {
    FGLog_BlueTooth,
};

@protocol FGBluetoothConnectionProtocol;

@protocol FGBluetoothConnectionDelegate <NSObject>

- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth didDisconnectedError:(NSError *)error;
- (void)bluetoothDidConnect:(id<FGBluetoothConnectionProtocol>)bluetooth;
- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
didUpdateBlueToothState:(CBCentralManagerState)bluetoothState;
- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
   didRecieveData:(NSData *)data error:(NSError *)error;
- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
 didSendDataError:(NSError *)error;
//过滤
@optional
- (BOOL)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
filterForDiscoverPeripheralName:(NSString *)peripheralName
advertisementData:(NSDictionary *)advertisementData;

- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
didCompleteNoticyCharacteristicWithError:(NSError *)error;

- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
didFailToConnectWithError:(NSError *)error;

@end

@protocol FGBluetoothConnectionProtocol <NSObject>

@property (weak, nonatomic) id<FGBluetoothConnectionDelegate> delegate;
@property (readonly, assign, nonatomic) BOOL isConnected;
@property (strong, nonatomic) NSString *characteristicUUID;
@property (strong, nonatomic) NSString *serviceUUID;
@property (strong, nonatomic) NSString *storeUUID;

//保存当前连接
@property (strong, nonatomic) CBPeripheral *myPeripheral;
@property (strong, nonatomic) CBCharacteristic *myCharacteristic;

- (instancetype)initWithStoreUUID:(NSString *)storeUUID;
- (void)connect;
- (void)sendData:(NSData *)data;
- (void)sendData:(NSData *)data highPriority:(BOOL)high;

- (void)releaseResource;

@end
