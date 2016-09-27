//
//  CBPBaseClient.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseClient.h"
#import "CBPBasePeripheralModel.h"
/**
 *  扫描回调
 */
typedef void(^scanReadyBlock)(CBManagerState ready);

/**
 *  找到最佳外设回调
 */
typedef void(^basePeripheralBlock)(CBPBasePeripheralModel *peripheral);


@interface CBPBaseClient ()

/**
 *  中心角色管理器
 */
@property (nonatomic, strong) CBCentralManager *centralManager;

/**
 *  扫描服务的数组
 */
@property (nonatomic, strong) NSMutableArray<CBUUID *> *serviceUUIDs;

/**
 *  超时定时器
 */
@property (nonatomic, strong) NSTimer *timeOutTimer;

/**
 *  超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeOutInterval;

/**
 *  外设
 */
@property (nonatomic, strong) CBPBasePeripheralModel *peripheralModel;

@end

@implementation CBPBaseClient {
    /**
     *  可以开始扫描的回调
     */
    scanReadyBlock _scanReadyBlock;
    
    /**
     *  外设信号量强度
     */
    NSInteger _peripheralSingalValue;
    
    /**
     *  已找到外设回调
     */
    basePeripheralBlock _searchedPeripheralBlock;
    
    /**
     *  已连接回调
     */
    basePeripheralBlock _connectionPeripheralBlock;
}

#pragma mark---保护性判断, 之后在重写, .........
+ (instancetype)shareBaseClient {
    CBPBaseClient *shareBaseClient = [[CBPBaseClient alloc] init];
    
    if (shareBaseClient) {
        shareBaseClient.centralManager = [[CBCentralManager alloc] initWithDelegate: shareBaseClient queue: nil];
        shareBaseClient->_peripheralSingalValue = -90;
    }
    return shareBaseClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


#pragma mark---完全单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static CBPBaseClient *baseClient = nil;
    
    if (baseClient == nil) {
        // 只执行一次
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseClient = [super allocWithZone:zone];
            baseClient->_serviceUUIDs = nil;
        });
        return baseClient;
    }
    else {
        return baseClient;
    }
    
}


#pragma mark---添加扫描外设服务的 UUID
- (void)addPeripheralScanService:(CBUUID *)serviceUUID {
    
    // 首先判断 serviceUUID 不为空且真的是 CBUUID 类型
    if (serviceUUID && [serviceUUID isKindOfClass: [CBUUID class]]) {
        if (self.serviceUUIDs == nil) {
            self.serviceUUIDs = [[NSMutableArray alloc] init];
        }
        
        // 添加到数组中
        [self.serviceUUIDs addObject: serviceUUID];
    }
    
}

#pragma mark---通过数组添加
- (void)addPeripheralScanServices:(NSArray<CBUUID *> *)serviceUUIDs {
    // 判断数组是否为空且真的是数组的实例
    if (serviceUUIDs && [serviceUUIDs isKindOfClass: [NSArray class]]) {
        [self.serviceUUIDs addObjectsFromArray: serviceUUIDs];
    }
}

#pragma mark---设置可以扫描的回调
- (void)setScanReadyBlock:(void (^)(CBManagerState))scanReadyBlock {
    self->_scanReadyBlock = scanReadyBlock;
}

#pragma mark---找到外设
- (void)setSearchedPeripheralBlock:(void (^)(CBPBasePeripheralModel *))searchedPeripheralBlock{
    
    self->_searchedPeripheralBlock = searchedPeripheralBlock;
    
}

- (void) setConnectionPeripheralBlock: (void(^)(CBPBasePeripheralModel *peripheral)) connectionPeripheralBlock {
    self->_connectionPeripheralBlock = connectionPeripheralBlock;
}

#pragma mark---设置扫描超时
- (void)setScanTimeOut:(NSTimeInterval)interval {
    self.timeOutInterval = interval;
}


#pragma mark---开始扫描服务
- (void)startScanPeripheralWithOptions:(NSDictionary<NSString *,id> *)options {
    
#ifdef CBPLOG_FLAG
//    CBPDEBUG;
    NSLog(@"开始搜索");
#endif
    // 开始搜索
    [self.centralManager scanForPeripheralsWithServices: self.serviceUUIDs options: options];
    
    // 重置定时器
    [self.timeOutTimer invalidate];
    
    // 设置信号量
    self->_peripheralSingalValue = -90;
    // 重新定时
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval: self.timeOutInterval target: self selector: @selector(scanTimeOut) userInfo: nil repeats: NO];
}

#pragma mark---超时处理方法
- (void)scanTimeOut {
    
#ifdef CBPLOG_FLAG
//    CBPDEBUG;
    NSLog(@"回传外设");
#endif
    return;
    if (self->_searchedPeripheralBlock) {
        CBPBasePeripheralModel *model = [[CBPBasePeripheralModel alloc] init];
        model = self.peripheralModel;
        
        if (!self.peripheralModel) {

            model.error = [NSError errorWithDomain: @"com.new_life" code: 1024 userInfo: nil];
        }
        
        self->_searchedPeripheralBlock(model);
    }
    
}

#pragma mark---停止扫描
- (void) stopScan {
    [self.centralManager stopScan];
}

#pragma mark---连接外设
- (void)connectPeripheral:(CBPBasePeripheralModel *)peripheralModel options:(nullable NSDictionary<NSString *, id> *)options {
    
    // 连接外设
    [self stopScan];
    self.peripheralModel = peripheralModel;
    [self.centralManager connectPeripheral: peripheralModel.peripheral options: options];
}

#pragma mark--停止连接
- (void) cancelPeripheralConnection {
    
    if (self.peripheralModel == nil) {
        return;
    }
    
    for (CBService *service in self.peripheralModel.peripheral.services) {
        
        if (service) {
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                if (characteristic.isNotifying) {
                    // 取消预订通知
                    [self.peripheralModel.peripheral setNotifyValue: NO forCharacteristic: characteristic];
                }
            }
            
        }
    }
    // 取消连接
    [self.centralManager cancelPeripheralConnection: self.peripheralModel.peripheral];
    self.peripheralModel = nil;
    self->_peripheralSingalValue = -90;
}

#pragma mark--- CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (self->_scanReadyBlock) {
        self->_scanReadyBlock(central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // 过滤条件
    if (RSSI.integerValue < -90 || RSSI.integerValue > 90) {
        return;
    }
    
//    CBPDEBUG;
    //    peripheral.identifier.UUIDString
    NSLog(@"发现外设: %@ ====> 广播数据: %@ ====> 信号强度: %@", peripheral, advertisementData, RSSI);

    CBPBasePeripheralModel *model = [[CBPBasePeripheralModel alloc] init];
    model.peripheral = peripheral;
    model.singalValue = RSSI.integerValue;
    _searchedPeripheralBlock(model);
    // 取信号量最大的外设, 等待设备超时, 将外设回传给设备
//    if (RSSI.integerValue > self->_peripheralSingalValue) {
//        self->_peripheralSingalValue = RSSI.integerValue;
//        self.peripheral = peripheral;
//    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
//#ifdef CBPLOG_FLAG
//    CBPDEBUG;
    //    peripheral.identifier.UUIDString
    NSLog(@"已连接: %@  ====> UUID: %@", peripheral, peripheral.identifier.UUIDString);
//#endif
    
    if (self->_connectionPeripheralBlock) {
        CBPBasePeripheralModel *model = [[CBPBasePeripheralModel alloc] init];
        model.peripheral = peripheral;
        model.error = nil;
        self->_connectionPeripheralBlock(model);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
//    CBPDEBUG;
    if (self->_connectionPeripheralBlock) {
        CBPBasePeripheralModel *model = [[CBPBasePeripheralModel alloc] init];
        model.peripheral = peripheral;
  
        model.error = error;
        self->_connectionPeripheralBlock(model);
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    
    if (self->_connectionPeripheralBlock) {
        CBPBasePeripheralModel *model = [[CBPBasePeripheralModel alloc] init];
        model.peripheral = peripheral;
        model.error = error;
        self->_connectionPeripheralBlock(model);
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    
}


@end
