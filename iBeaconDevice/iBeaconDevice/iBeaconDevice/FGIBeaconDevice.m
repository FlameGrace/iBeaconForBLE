//
//  FGIBeaconDevice.m
//  DemoProject
//
//  Created by leapmotor on 2020/4/27.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGIBeaconDevice.h"
#import "DispatchTimer.h"

static NSString * const LocalNameKey =  @"myPeripheral";

@interface FGIBeaconDevice()<CBPeripheralManagerDelegate>

@property (strong,nonatomic) CBMutableCharacteristic *myCharacteristic;
@property (strong,nonatomic) NSString *serviceUUID;
@property (strong,nonatomic) NSString *characteristicUUID;
@property (strong,nonatomic) DispatchTimer *timer;
@property (assign,nonatomic) BOOL isAdvertisingIBeacon;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) FGIBeaconDeviceRegion *region;
@property (strong, nonatomic) NSMutableArray *centrals;
@end

@implementation FGIBeaconDevice

- (instancetype)initWithServiceUUID:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID region:(FGIBeaconDeviceRegion *)region{
    if(self = [super init]){
        self.centrals = [[NSMutableArray alloc]init];
        self.region = region;
        self.serviceUUID = serviceUUID;
        self.characteristicUUID = characteristicUUID;
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        __weak typeof(self) weakself = self;
        self.timer = [[DispatchTimer alloc]initWithDuration:2 handleBlock:^{
            [weakself startAdvertising];
        }];
    }
    return self;
}

//配置bluetooch的
-(void)setUp{
    if(!self.serviceUUID||!self.characteristicUUID){
        return;
    }
    //设置可读写可订阅特征值
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:self.characteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    self.myCharacteristic = readwriteCharacteristic;
    //设置description
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"my service"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:self.serviceUUID] primary:YES];
    
    [service1 setCharacteristics:@[readwriteCharacteristic]];
    [self.peripheralManager addService:service1];
}


#pragma  mark -- CBPeripheralManagerDelegate

//peripheralManager状态改变
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"powered :%@",@(peripheral.state));
    switch (peripheral.state) {
            //在这里判断蓝牙设别的状态  当开启了则可调用  setUp方法(自定义)
        case CBManagerStatePoweredOn:
            NSLog(@"powered on");
            NSLog(@"设备名%@已经打开，可以使用center进行连接",LocalNameKey);
            [self setUp];
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"powered off");
            break;
            
        default:
            break;
    }
}


/// iBeacon广播包不能和普通ServiceID广播包一起发送，否则iBeacon功能将失效
- (void)startAdvertisingCombind{
    NSDictionary *dic = @{
    CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:self.serviceUUID]],
                                     CBAdvertisementDataLocalNameKey : LocalNameKey
    };
    if(self.region){
        NSMutableDictionary *pr = [self.region peripheralData];
        [pr addEntriesFromDictionary:dic];
        dic = [NSDictionary dictionaryWithDictionary:pr];
    }
    [self.peripheralManager stopAdvertising];
    [self.peripheralManager startAdvertising:dic];
    return;
}


- (void)startAdvertising{
    if(!self.region){
        [self.timer endTimer];
        self.isAdvertisingIBeacon = NO;
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager startAdvertising:@{
        CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:self.serviceUUID]],
                                         CBAdvertisementDataLocalNameKey : LocalNameKey
        }];
        return;
    }
    if(self.isAdvertisingIBeacon){
        self.isAdvertisingIBeacon = NO;
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager startAdvertising:@{
            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:self.serviceUUID]],
                                             CBAdvertisementDataLocalNameKey : LocalNameKey
        }];
    }else{
        self.isAdvertisingIBeacon = YES;
        [self.peripheralManager stopAdvertising];
        [self.peripheralManager startAdvertising:[self.region peripheralData]];
    }
}


//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"已经添加完服务");
    [self.timer startTimer];
//    [self startAdvertisingCombind];
    
}

//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
//    NSLog(@"开始广播：%@",error);
}

//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyHigh forCentral:central];
    [self.centrals addObject:central];
    [self sendData];
    NSLog(@"%@订阅了 %@的数据",central,characteristic.UUID);
}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    [self.centrals removeObject:central];
    NSLog(@"%@取消订阅 %@的数据",central,characteristic.UUID);

}

//发送数据，发送当前时间的秒数
-(BOOL)sendData {
    CBMutableCharacteristic *characteristic = self.myCharacteristic;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"ss"];
    NSLog(@"%@",[dft stringFromDate:[NSDate date]]);
    //执行回应Central通知数据
    NSArray *ar = nil;
    if(self.centrals){
        ar = [NSArray arrayWithArray:self.centrals];
    }
    return  [self.peripheralManager updateValue:[[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:ar];
    
}


//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"收到请求：%@",peripheral);
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}


//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"收到写请求。count:%ld",requests.count);
    CBATTRequest *request = requests.firstObject;
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

//
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    NSLog(@"设备已经准备好通知订阅者");
    
}


@end
