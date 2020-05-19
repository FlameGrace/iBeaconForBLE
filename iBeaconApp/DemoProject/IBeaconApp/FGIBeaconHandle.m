//
//  FGIBeaconHandle.m
//  DemoProject
//
//  Created by leapmotor on 2020/4/29.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "FGIBeaconHandle.h"
#import "FGNormalBlueToothConnection.h"

static NSString *const ServiceUUID1 =  @"FFFE";
static NSString *const readwriteCharacteristicUUID =  @"FFFA";
static NSString *const StoreUUID =  @"2DAB592C-2643-4F5F-8A75-4A5F19A9D7B2";

@interface FGIBeaconHandle() <CLLocationManagerDelegate,FGBluetoothConnectionDelegate>

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CLLocationManager *locMgr; /**< 位置管理者 */
@property (strong, nonatomic) FGNormalBlueToothConnection *connection;
@property (assign, nonatomic) CLProximity proximity;

@end

@implementation FGIBeaconHandle

- (instancetype)init{
    if(self = [super init]){
        [self.locMgr requestAlwaysAuthorization];
    }
    return self;
}

// 懒加载iBeacon区域
- (CLBeaconRegion *)beaconRegion
{
    if (!_beaconRegion) {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:StoreUUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                major:0
                                                                minor:0
                                                           identifier:StoreUUID];
        /**
         *  一个App为了在特定商场提⾼高⽤用户体验,可⽤用使⽤用相同的proximity UUID来监听商场的所有商铺。当⽤用户进⼊入⼀一个商店时,App检测商铺的iBeacon设备并使⽤用major和 minor值来获取额外的信息,如⽤用户进⼊入哪家商店或⽤用户在商店的哪个区域(注意:虽然每个iBeacon都必须有⼀一个proximity UUID,但 major和minor的值是可选的)。
         */
    }
    return _beaconRegion;
}

// 懒加载创建地域管理者
- (CLLocationManager *)locMgr
{
    if (!_locMgr) {
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.delegate = self;
    }
    return _locMgr;
}

- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth didDisconnectedError:(NSError *)error{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"断开链接：%@",error);
    [self.connection didConnected];
}

- (void)bluetoothDidConnect:(id<FGBluetoothConnectionProtocol>)bluetooth{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"111连接上了");
}
- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth
didCompleteNoticyCharacteristicWithError:(NSError *)error{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"111订阅成功：%@",error);
    [bluetooth sendData:[@"哈哈哈哈" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth didRecieveData:(NSData *)data error:(NSError *)error {
    
}


- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth didSendDataError:(NSError *)error {
    
}


- (void)bluetooth:(id<FGBluetoothConnectionProtocol>)bluetooth didUpdateBlueToothState:(CBCentralManagerState)bluetoothState {
    
}



- (void)connect{
    if(!self.connection){
        self.connection = [[FGNormalBlueToothConnection alloc]initWithStoreUUID:StoreUUID];
        self.connection.delegate = self;
        self.connection.serviceUUID = ServiceUUID1;
        self.connection.characteristicUUID = readwriteCharacteristicUUID;
        [self.connection connect];
    }
}

- (void)enter{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow, @"进入区域");
    [self connect];
}

- (void)exit{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"离开区域");
}

#pragma mark - CLLocationManagerDelegate

// 开始监听
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"开始监听");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locMgr startMonitoringForRegion:self.beaconRegion];//开始MonitoringiBeacon
//        [self.locMgr startRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    if ([region isEqual:self.beaconRegion]) {
        [self enter];
    }

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    if([region isEqual:self.beaconRegion]){
        [self exit];
    }
}

//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region{
////    FGLog(FGLog_BlueTooth, FGLogLevel_MustShow,@"开始计算距离：%@",beacons);
//    CLProximity proximity = CLProximityFar;
//    for (CLBeacon *beacon in beacons) {
//        if(beacon && [beacon.proximityUUID isEqual:self.beaconRegion.proximityUUID]){
//            proximity = CLProximityNear;
//        }
//    }
//    self.proximity = proximity;
//}
//
//
//- (void)setProximity:(CLProximity)proximity{
//    if(_proximity == proximity){
//        return;
//    }
//    CLProximity old = _proximity;
//    _proximity = proximity;
//    if(old == CLProximityNear && proximity == CLProximityFar){
//        [self exit];
//    }
//    if(proximity == CLProximityNear){
//        [self enter];
//    }
//}


@end
