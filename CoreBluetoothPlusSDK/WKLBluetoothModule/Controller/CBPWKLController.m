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
    self.baseDevice = nil;
    [self.baseClient connectPeripheral: nil options: nil];
}

#pragma mark---设备开始工作
- (void)deviceStartWorkWith:(CBPBasePeripheralModel *)peripheralModel {
    
    if (self.baseDevice == nil) {
        self.baseDevice = [[CBPBaseDevice alloc] init];
        [self.baseDevice addObserver: self forKeyPath: @"isChracteristicReady" options:NSKeyValueObservingOptionNew context: nil];
    }
    
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
        if (!actionDataModel.actionData) {
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
        
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
    
    // 写数据回调
    [weakSelf.baseDevice setWriteDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        if (!actionDataModel.actionData) {
            return;
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
        
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
}


@end
