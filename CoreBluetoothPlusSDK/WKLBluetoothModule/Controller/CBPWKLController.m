//
//  CBPWKLController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLController.h"
#import "CBPWKLBindDeviceAction.h"
#import "CBPBaseWorkingManager.h"
#import "CBPBaseCharacteristicModel.h"
#import "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"

static NSString* braceletScanService1 = @"0xCC01";
static NSString* braceletScanService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* braceletScanService3 = @"00001802-0000-1000-8000-00805f9b34fb";
static NSString* braceletScanService4 = @"0x6666";
static NSString* braceletScanService5 = @"0xFCFA";
static NSString* braceletScanService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* braceletScanService7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 32手表
static NSString* braceletScanService8 = @"000056ef-0000-1000-8000-00805f9b34fb";//006F
static NSString* braceletScanService9 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F

//读写服务UUID
static NSString* braceletDiscoveredService1 = @"0xCC01";
static NSString* braceletDiscoveredService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* braceletDiscoveredService3 = @"000056ef-0000-1000-8000-00805f9b34fb";
static NSString* braceletDiscoveredService4 = @"0x6666";
static NSString* braceletDiscoveredService5 = @"0xFCFA";
static NSString* braceletDiscoveredService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* braceletDiscoveredService7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletDiscoveredService8 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F

//写数据UUID
static NSString* braceletWriteCBCharacteristice1 = @"0xCD20";
static NSString* braceletWriteCBCharacteristice2 = @"D44BC439-ABFD-45A2-B575-925416129600";
static NSString* braceletWriteCBCharacteristice3 = @"000034e1-0000-1000-8000-00805f9b34fb";
static NSString* braceletWriteCBCharacteristice4 = @"0x8877";
static NSString* braceletWriteCBCharacteristice5 = @"0x00D4";
static NSString* braceletWriteCBCharacteristice6 = @"A44BC439-ABFD-45A2-B575-925416129600";
static NSString* braceletWriteCBCharacteristice7 = @"0x6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletWriteCBCharacteristice8 = @"0x8888";
static NSString* braceletWriteCBCharacteristice9 = @"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F
//Notify数据UUID,读数据UUID
static NSString* braceletReadCBCharacteristic1 = @"0xCD01";
static NSString* braceletReadCBCharacteristic2 = @"D44BC439-ABFD-45A2-B575-925416129601";
static NSString* braceletReadCBCharacteristic3 = @"000034e2-0000-1000-8000-00805f9b34fb";
static NSString* braceletReadCBCharacteristic4 = @"0x8888";
static NSString* braceletReadCBCharacteristic5 = @"0x01D4";
static NSString* braceletReadCBCharacteristic6 = @"0xA44BC439-ABFD-45A2-B575-925416129601";
static NSString* braceletReadCBCharacteristic7 = @"0x6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletReadCBCharacteristic8 = @"0x8877";
static NSString* braceletReadCBCharacteristic9 =@"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F

static NSString * Cypress_OTA_SERVICE_UUID = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";
static NSString * SPOTA_SERVICE_UUID     = @"0000fef5-0000-1000-8000-00805f9b34fb";
static NSString * SPOTA_MEM_DEV_UUID     = @"8082caa8-41a6-4021-91c6-56f9b954cc34";
static NSString * SPOTA_GPIO_MAP_UUID    = @"724249f0-5ec3-4b5f-8804-42345af08651";
static NSString * SPOTA_MEM_INFO_UUID    = @"6c53db25-47a1-45fe-a022-7c92fb334fd4";
static NSString * SPOTA_PATCH_LEN_UUID   = @"9d84b9a3-000c-49d8-9183-855b673fda31";
static NSString * SPOTA_PATCH_DATA_UUID  = @"457871e8-d516-4ca1-9116-57d0b17b9cb2";
static NSString * SPOTA_SERV_STATUS_UUID = @"5f78df94-798c-46f5-990a-b3eb6a065c88";

@interface CBPWKLController ()

/**
 *  扫描服务 UUIDs
 */
@property (nonatomic, strong) NSArray<NSString *> *scanServiceUUIDs;

/**
 *  发现特征的服务 UUIDs
 */
@property (nonatomic, strong) NSArray<NSString *> *discoverSeriveUUIDs;

/**
 *  读特征
 */
@property (nonatomic, strong) NSArray<NSString *> *readChracteristicUUIDs;

/**
 *  写特征
 */
@property (nonatomic, strong) NSArray<NSString *> *writeChracteristicUUIDs;

/**
 *  是否具备读特征
 */
@property (nonatomic, assign) BOOL isReadCharacterstic;

/**
 *  是否具备写特征
 */
@property (nonatomic, assign) BOOL isWriteCharacteristic;


@property (nonatomic, weak) NSDictionary *serviceDictionary;

@property (nonatomic, strong) void(^block)(id result);



@end


@implementation CBPWKLController

+ (void)load {
    
    // 注册控制器
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method: @"registerController:", self, nil];
}

+ (NSString *)controllerKey {
    return @"com.wkl.controller";
}

#pragma mark---初始化方法
- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"CBPBluetooth" ofType: @"plist"];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
        
        _serviceDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"" ofType: @"plist"]];
        
        self->_scanServiceUUIDs = dictionary[@"BraceletScanServices"];
        self->_discoverSeriveUUIDs = dictionary[@"BraceletDiscoveredServices"];
        self->_readChracteristicUUIDs = dictionary[@"BraceletReadCBCharacteristics"];
        
        self->_writeChracteristicUUIDs = dictionary[@"BraceletWriteCBCharacteristics"];

        self->_isReadCharacterstic = NO;
        self->_isWriteCharacteristic = NO;
    }
    
    return self;
}

#pragma mark---观察者监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // 监听 Device 的特征, 如果读特征都准备好了, 立即绑定
    if ([keyPath isEqualToString: @"isChracteristicReady"]) {
        
        if (self.baseDevice.isChracteristicReady == YES) {
            
            if (_block) {
                NSDictionary *dict = @{@"code" : @"1", @"type": @"0"};
                _block(dict);
            }
            NSLog(@"已链接");
        }
    }
}

#pragma mark---控制器开始工作
- (void)startWorkWithBlock:(void (^)(id))block {
    
    __weak CBPWKLController *weakSelf = self;
    
//    CBPDEBUG;
    weakSelf.baseClient = [CBPBaseClient shareBaseClient];
    
    for (NSString *UUIDString in self->_scanServiceUUIDs) {
        [weakSelf.baseClient addPeripheralScanService: [CBUUID UUIDWithString: UUIDString.uppercaseString]];
    }
    
    // 设置扫描超时时间
    [weakSelf.baseClient setScanTimeOut: 3.0];
    // 设置回调
    weakSelf.block = block;
    
    // 已经准备开始扫描回调
    [weakSelf.baseClient setScanReadyBlock:^(CBManagerState ready) {
        switch (ready) {
            case CBCentralManagerStatePoweredOn: {
                
                // 开始扫描
                [weakSelf.baseClient startScanPeripheralWithOptions: nil];
                break;
            }
                
            default:
                break;
        }
    }];
    
    
    // 已找到
    [weakSelf.baseClient setSearchedPeripheralBlock:^(CBPBasePeripheralModel *peripheral) {
        
        _block(peripheral);
        return ;
        if (peripheral != nil) {
            [weakSelf.baseClient stopScan];
            [weakSelf.baseClient  connectPeripheral: peripheral options: nil];
#ifdef CBPLOG_FLAG
            CBPDEBUG;
            NSLog(@"发现外设: %@ ====>", peripheral);
#endif
        }
        else {
            
            [weakSelf cleanup];
            [weakSelf.baseClient startScanPeripheralWithOptions: nil];
        }
    }];
    
    [weakSelf.baseClient setConnectionPeripheralBlock:^(CBPBasePeripheralModel *peripheral) {
        
        if (peripheral.error == nil) {
            [weakSelf deviceStartWorkWith: peripheral];
        }
        else {
            NSLog(@"断开链接");
            _isWriteCharacteristic = NO;
            _isReadCharacterstic = NO;
            self.baseDevice.isChracteristicReady = NO;
            [weakSelf.baseClient cancelPeripheralConnection];
        }
    }];
}

#pragma mark---清理
- (void) cleanup {
    _isWriteCharacteristic = NO;
    _isReadCharacterstic = NO;
    self.baseDevice.isChracteristicReady = NO;
}

#pragma mark---设备开始工作
- (void)deviceStartWorkWith:(CBPBasePeripheralModel *)peripheralModel {
    
    if (self.baseDevice == nil) {
        self.baseDevice = [[CBPBaseDevice alloc] init];
        [self.baseDevice addObserver: self forKeyPath: @"isChracteristicReady" options:NSKeyValueObservingOptionNew context: nil];
    }
    [self cleanup];
    // 添加发现服务
    for (NSString *UUIDString in self->_discoverSeriveUUIDs) {
        [self.baseDevice addServiceUUIDWithUUIDString: [UUIDString uppercaseString]];
    }
    
    // 添加读特征
    for (NSString *UUIDString in self->_readChracteristicUUIDs) {
        [self.baseDevice addCharacteristicUUIDWithUUIDString: [UUIDString uppercaseString]];
    }
    
    // 添加写特征
    for (NSString *UUIDString in self->_writeChracteristicUUIDs) {
        [self.baseDevice addCharacteristicUUIDWithUUIDString: [UUIDString uppercaseString]];
    }
    // 开始工作
    [self.baseDevice startWorkWith: peripheralModel];
    
    // 超时定时器回调
    [self.baseDevice discoverCharacteristicTimerTimeOutBlock:^(NSError *error) {
        NSLog(@"%@", error);
//        CBPDEBUG;
        
        // 说明外设查找失败, 这里为了方便才继续
        [self.baseClient startScanPeripheralWithOptions: nil];
    }];
    
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *readArray = [self->_readChracteristicUUIDs valueForKeyPath:@"uppercaseString"];
    
    NSArray *writeArray = [self->_writeChracteristicUUIDs valueForKeyPath: @"uppercaseString"];
    
    __weak CBPBaseDevice *device = self.baseDevice;
    
    
    // 发现特征服务回调
    [self.baseDevice setDiscoverServiceBlock:^(CBPBaseServiceModel *discoverServiceModel) {
        
        for (CBCharacteristic *characteristic in discoverServiceModel.service.characteristics) {
            
            NSLog(@"%@", characteristic);
            
            // 读特征
            if ([readArray containsObject: [characteristic.UUID.UUIDString uppercaseString]]) {
                
                // 预定特征
                [peripheralModel.peripheral setNotifyValue: YES forCharacteristic: characteristic];
                [peripheralModel.peripheral readValueForCharacteristic: characteristic];
                
                NSDictionary *dicton = @{@"chracteristic":characteristic, @"flag":@"1"};
                CBPBaseCharacteristicModel *model = [CBPBaseCharacteristicModel modelWithDictionary:dicton];
                
                [device addCharacteristic: model];
                _isReadCharacterstic = YES;
                
                if (_isWriteCharacteristic == YES && _isReadCharacterstic == YES) {
                    device.isChracteristicReady = YES;
                }
            }
            
            // 写特征
            if ([writeArray containsObject: [characteristic.UUID.UUIDString uppercaseString]]) {
                
                _isWriteCharacteristic = YES;
                weakSelf.writeCharacteristicUUIDString = [characteristic.UUID.UUIDString lowercaseString];
                
                NSDictionary *dicton = @{@"chracteristic":characteristic, @"flag":@"2"};
                CBPBaseCharacteristicModel *model = [CBPBaseCharacteristicModel modelWithDictionary:dicton];
                
                // 添加
                [device addCharacteristic: model];
                
                if (_isWriteCharacteristic == YES && _isReadCharacterstic == YES) {
                    device.isChracteristicReady = YES;
                }
                
            }
            
        }
        
    }];
    
    [self deviceDeliverData];
//    // 调用父类私有 API
//    struct objc_super superObj;
//    superObj.receiver = self;
//    superObj.super_class = [self superclass];
//    SEL selector = NSSelectorFromString(@"deviceDeliverData");
//    objc_msgSendSuper(&superObj, selector);
}

- (void) deviceDeliverData {
    
    __weak CBPBaseController *weakSelf = self;
    // 更新数据回调
    [weakSelf.baseDevice setUpdateDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        // 空数据丢弃
        if (!actionDataModel.actionData || (actionDataModel.actionData.length < 2)) {
            return;
        }
        
        Byte *bytes = (Byte *)actionDataModel.actionData.bytes;
        
        // 取得标识字节内容
        NSString *hex = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[1] length: 1];
        
        if (![hex hasPrefix: @"0x"]) {
            hex = [@"0x" stringByAppendingString: hex];
        }
        
        // 添加表示关键字, 小写
        actionDataModel.keyword = [hex lowercaseString];
        
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        
        if ([action respondsToSelector: @selector(receiveUpdateData:)]) {
            // 投送消息
            // 关闭超时定时器
            [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"stopTimer", nil];
            [action receiveUpdateData: actionDataModel];
            
        }
    }];
    
    // 写数据回调
    [weakSelf.baseDevice setWriteDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        if (!actionDataModel.actionData) {
            return ;
        }
        
        Byte *bytes = (Byte *)actionDataModel.actionData.bytes;
        
        // 取得标识字节内容
        NSString *hex = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[1] length: 1];
        
        if (![hex hasPrefix: @"0x"]) {
            hex = [hex stringByAppendingString: @"0x"];
        }
        
        // 添加关键字
        actionDataModel.keyword = [hex lowercaseString];
        
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        
        if ([action respondsToSelector: @selector(receiveUpdateData:)]) {
            
            // 关闭超时定时器
            [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"stopTimer", nil];
            // 投送消息
            [action receiveUpdateData: actionDataModel];
            
        }
        
    }];
}


@end
