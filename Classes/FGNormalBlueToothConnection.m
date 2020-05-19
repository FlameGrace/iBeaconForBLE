//
//  FGNormalBlueToothConnection.m
//  DemoProject
//
//  Created by Mac on 2020/1/20.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGNormalBlueToothConnection.h"
//延时运行
#define DispatchDelayRunBlock(seconds,voidBlock){dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));dispatch_after(delayTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), voidBlock);}
#define WeakObj(o)                    __weak typeof(o) weak##o = o;      // 获取弱引用对象

@interface FGNormalBlueToothConnection()
<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *peripherals;

@end

@implementation FGNormalBlueToothConnection

- (instancetype)initWithStoreUUID:(NSString *)storeUUID
{
    if(self = [super initWithStoreUUID:storeUUID]){
        self.peripherals = [[NSMutableArray alloc]init];
        NSDictionary *dic = nil;
        if(storeUUID){
            dic = @{CBCentralManagerOptionRestoreIdentifierKey:storeUUID};
        }
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:dic];
    }
    return self;
}

- (void)connect{
    [super connect];
    [self.peripherals removeAllObjects];
    [self scan];
}

- (void)scan{
    NSArray *uuids = nil;
    if(self.serviceUUID){
        CBUUID *uuid = [CBUUID UUIDWithString:self.serviceUUID];
        uuids = @[uuid];
    }
    [self.centralManager scanForPeripheralsWithServices:uuids options:nil];
}

- (void)didUpdateBlueToothState:(CBCentralManagerState)bluetoothState{
    [super didUpdateBlueToothState:bluetoothState];
    if(bluetoothState == CBCentralManagerStatePoweredOn){
        [self scan];
    }
}

/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param central      The central manager providing this information.
 *  @param dict            A dictionary containing information about <i>central</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion            For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *                        the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *                        Bluetooth system.
 *
 *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
 *
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"111哈哈哈：%@",dict);
    [self connect];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [self didUpdateBlueToothState:(CBCentralManagerState)(central.state)];
}

//扫描到Peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    BOOL filt = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetooth:filterForDiscoverPeripheralName:advertisementData:)]){
        filt = [self.delegate bluetooth:self filterForDiscoverPeripheralName:peripheral.name advertisementData:advertisementData];
    }
    if(filt){
        [self.peripherals addObject:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
        //实测刘海屏手机升级到iOS13.3后必须再调用一次才能连接上
        WeakObj(self)
        DispatchDelayRunBlock(1, ^{
            [weakself.centralManager connectPeripheral:peripheral options:nil];
        })
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //设置委托
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"已经连接上设备:%@，开始扫描服务", peripheral.name);
    if(self.serviceUUID){
        [peripheral setDelegate:self];
        CBUUID *uuid = [CBUUID UUIDWithString:self.serviceUUID];
        [peripheral discoverServices:@[uuid]];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"连接设备:%@失败，error:%@", peripheral.name,error);
    [self didFailToConnectWithError:error];
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(self.myPeripheral && [self.myPeripheral isEqual:peripheral])
    {
        FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"1111收到值：断开链接");
        [self didDisconnectedError:error];
    }
}

//扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@">>>didDiscoverServices for %@ with error: %@", peripheral.services, [error localizedDescription]);
    if(!self.serviceUUID || !self.characteristicUUID){
        return;
    }
    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqual:self.serviceUUID])
        {
            CBUUID *uuid = [CBUUID UUIDWithString:self.characteristicUUID];
            [peripheral discoverCharacteristics:@[uuid] forService:service];
        }
    }
}

//发现服务的Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"error didDiscoverCharacteristicsForService for %@ with error: %@", service.UUID, [error localizedDescription]);
    if(error){
        return;
    }
    if(!self.serviceUUID || !self.characteristicUUID){
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if([[characteristic UUID].UUIDString isEqualToString:self.characteristicUUID])
        {
            if(!self.myCharacteristic&&([characteristic.UUID.UUIDString isEqualToString:self.characteristicUUID]))
            {
                self.myPeripheral = peripheral;
                self.myCharacteristic = characteristic;
                [self.centralManager stopScan];
                [self.peripherals removeAllObjects];
                //开始订阅特征值
                [self.myPeripheral setNotifyValue:YES forCharacteristic:self.myCharacteristic];
            }
        }
    }
}

//characteristic.isNotifying 状态改变
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(characteristic && self.myCharacteristic && [characteristic isEqual:self.myCharacteristic]){
        [self didCompleteNoticyCharacteristicWithError:error];
        if(!error && characteristic.isNotifying){
            FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"1111收到值：订阅成功");
            [self didConnected];
            [self didRecieveData:characteristic.value error:nil];
        }
    }
    
}

//读取Characteristics的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"1111收到值：%@",data);
    if(characteristic && self.myCharacteristic && [characteristic isEqual:self.myCharacteristic]){
        [self didConnected];
        [self didRecieveData:characteristic.value error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"1111收到值：写入成功");
    [self.buffer sendNextPacket];
    [self didSendDataError:error];
    if(error){
        [self didDisconnectedError:error];
    }
}

@end
