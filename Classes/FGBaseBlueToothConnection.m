//
//  FGBaseBlueToothConnection.m
//  DemoProject
//
//  Created by Mac on 2020/1/20.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGBaseBlueToothConnection.h"
#import "FGLog.h"

@interface FGBaseBlueToothConnection()

@property (assign, nonatomic) CBCentralManagerState bluetoothState;
@property (assign, nonatomic) BOOL didSendConnectMessage; //是否已发送连接回调,实测发现有时订阅主题返回值回调比较慢，而读取订阅值比较快，可以双重判断是否真正已连接

@end

@implementation FGBaseBlueToothConnection

- (instancetype)initWithStoreUUID:(NSString *)storeUUID
{
    if(self = [super init]){
        self.storeUUID = storeUUID;
    }
    return self;
}

- (void)connect{
    self.didSendConnectMessage = NO;
    self.myPeripheral = nil;
    self.myCharacteristic = nil;
    self.buffer = [[FGBlueToothBuffer alloc]init];
    self.buffer.delegate = self;
    [self didUpdateBlueToothState:self.bluetoothState];
}

- (BOOL)isConnected
{
    if(self.myPeripheral && self.myPeripheral.state == CBPeripheralStateConnected && self.myCharacteristic)
    {
        return YES;
    }
    return NO;
}

- (void)releaseResource{
    
}

- (void)sendData:(NSData *)data
{
    [self sendData:data highPriority:NO];
}

- (void)sendData:(NSData *)data highPriority:(BOOL)high
{
    [self.buffer addBuffer:data highPriority:high];
}

- (void)blueToothBuffer:(FGBlueToothBuffer *)buffer needToSendPacket:(NSData *)data
{
    if(self.isConnected)
    {
        FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"开始写入%@,长度：%ld",data,(long)data.length);
        [self.myPeripheral writeValue:data forCharacteristic:self.myCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"LeapmotorErrorDomain" code:1 userInfo:nil];
        [self didSendDataError:error];
        FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"未连接，写入失败");
    }
}

- (void)didCompleteNoticyCharacteristicWithError:(NSError *)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:didCompleteNoticyCharacteristicWithError:)])
    {
        [self.delegate bluetooth:self didCompleteNoticyCharacteristicWithError:error];
    }
}

- (void)didFailToConnectWithError:(NSError *)error{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:didFailToConnectWithError:)])
    {
        [self.delegate bluetooth:self didFailToConnectWithError:error];
    }
}

- (void)didDisconnectedError:(NSError *)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:didDisconnectedError:)])
    {
        [self.delegate bluetooth:self didDisconnectedError:error];
    }
}

- (void)didConnected
{
    if(self.didSendConnectMessage){
        return;
    }
    self.didSendConnectMessage = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothDidConnect:)])
    {
        [self.delegate bluetoothDidConnect:self];
    }
}

- (void)didUpdateBlueToothState:(CBCentralManagerState)bluetoothState
{
    
    self.bluetoothState = bluetoothState;
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:didUpdateBlueToothState:)]){
        [self.delegate bluetooth:self didUpdateBlueToothState:bluetoothState];
    }
    if(bluetoothState == CBCentralManagerStatePoweredOff)
    {
        NSError *error = [NSError errorWithDomain:@"LeapmotorErrorDomain" code:1 userInfo:@{@"reason":@"蓝牙关闭"}];
        //只有在已连接的情况下，才提示蓝牙已断开
        if(self.didSendConnectMessage)
        {
           [self didDisconnectedError:error];
        }
    }
}

- (void)didRecieveData:(NSData *)data error:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(bluetooth:didRecieveData:error:)]){
        [self.delegate bluetooth:self didRecieveData:data error:error];
    }
}

- (void)didSendDataError:(NSError *)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:didSendDataError:)])
    {
        [self.delegate bluetooth:self didSendDataError:error];
    }
}

@end
