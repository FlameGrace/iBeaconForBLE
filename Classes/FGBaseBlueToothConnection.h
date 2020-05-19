//
//  FGBaseBlueToothConnection.h
//  DemoProject
//
//  Created by Mac on 2020/1/20.
//  Copyright © 2020 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGBluetoothConnectionProtocol.h"
#import "FGBlueToothBuffer.h"


@interface FGBaseBlueToothConnection : NSObject <FGBluetoothConnectionProtocol,FGBlueToothBufferDelegate>

@property (weak, nonatomic) id<FGBluetoothConnectionDelegate> delegate;
@property (readonly, assign, nonatomic) BOOL isConnected;
@property (strong, nonatomic) NSString *characteristicUUID;
@property (strong, nonatomic) NSString *serviceUUID;
@property (strong, nonatomic) NSString *storeUUID;

//保存当前连接
@property (strong, nonatomic) CBPeripheral *myPeripheral;
@property (strong, nonatomic) CBCharacteristic *myCharacteristic;

@property (strong, nonatomic) FGBlueToothBuffer *buffer;


- (void)didDisconnectedError:(NSError *)error;
- (void)didConnected;
- (void)didUpdateBlueToothState:(CBCentralManagerState)bluetoothState;
- (void)didRecieveData:(NSData *)data error:(NSError *)error;
- (void)didSendDataError:(NSError *)error;
- (void)didCompleteNoticyCharacteristicWithError:(NSError *)error;
- (void)didFailToConnectWithError:(NSError *)error;

@end
