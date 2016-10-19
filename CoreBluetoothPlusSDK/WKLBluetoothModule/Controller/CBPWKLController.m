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
#import "CBPWKLServiceCharacteristicManager.h"
#import "CBPWKLServiceCharacteristicModel.h"

@interface CBPWKLController ()

/**
 *  扫描服务 UUIDs
 */
@property (nonatomic, strong) NSArray<CBUUID *> *scanServiceUUIDs;

/**
 *  发现特征的服务 UUIDs
 */
@property (nonatomic, strong) NSArray<CBUUID *> *discoverSeriveUUIDs;

/**
 *  读特征
 */
@property (nonatomic, strong) NSArray<NSString *> *readChracteristicUUIDs;

/**
 *  写特征
 */
@property (nonatomic, strong) NSArray<NSString *> *writeChracteristicUUIDs;

/**
 *  是否具备通知特征
 */
@property (nonatomic, assign) BOOL isNotifyCharacterstic;

/**
 *  是否具备写特征
 */
@property (nonatomic, assign) BOOL isWriteCharacteristic;


@property (nonatomic, strong) void(^block)(id result);


/**
 服务特征管理器
 */
@property (nonatomic, strong)CBPWKLServiceCharacteristicManager *serviceCharacteristicManager;
/**
 当前的服务特征模型
 */
@property (nonatomic, strong) CBPWKLServiceCharacteristicModel *currentServiceCharacteristicModel;


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
        self->_isNotifyCharacterstic = NO;
        self->_isWriteCharacteristic = NO;
        // 单例
        self.serviceCharacteristicManager =[CBPWKLServiceCharacteristicManager shareManager];
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
    
    // 有就添加, 空就扫描所以
    for (CBUUID *UUID in self.scanServiceUUIDs) {
        // 添加扫描的设备服务 UUID
        [weakSelf.baseClient addPeripheralScanService: UUID];
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
            _isNotifyCharacterstic = NO;
            self.baseDevice.isChracteristicReady = NO;
            [weakSelf.baseClient cancelPeripheralConnection];
        }
    }];
}

#pragma mark---清理
- (void) cleanup {
    _isWriteCharacteristic = NO;
    _isNotifyCharacterstic = NO;
    self.baseDevice.isChracteristicReady = NO;
}

#pragma mark---设备开始工作
- (void)deviceStartWorkWith:(CBPBasePeripheralModel *)peripheralModel {
    
    if (self.baseDevice == nil) {
        self.baseDevice = [[CBPBaseDevice alloc] init];
        [self.baseDevice addObserver: self forKeyPath: @"isChracteristicReady" options:NSKeyValueObservingOptionNew context: nil];
    }
    [self cleanup];
    
    // 发现服务
    self.discoverSeriveUUIDs = [self.serviceCharacteristicManager discoverServiceUUIDs];
    
    // 添加服务
    for (CBUUID *uuid in self.discoverSeriveUUIDs) {
        NSString *uuids = uuid.UUIDString;
        [self.baseDevice addServiceUUIDWithUUIDString: uuids];
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
    
    
    
    __weak CBPBaseDevice *device = self.baseDevice;
    
    // 发现特征回调
    [self discoverServiceCharacteristic];
    // 发现服务回调
    [self discoverService];
    // 传送数据
    [self deviceDeliverData];

}

- (void) discoverService {
    // 发现特征服务回调
    __weak CBPWKLController *weakSelf = self;
    [weakSelf.baseDevice setDiscoverServiceBlock:^NSArray<CBUUID *> *(CBPBaseServiceModel *discoverServiceModel) {
        
        CBService *service = discoverServiceModel.service;
        
        // 如果存在
        if ([[self.serviceCharacteristicManager discoverServiceUUIDs] containsObject: service.UUID]) {
            
            // 获得索引值
            NSInteger index = [[self.serviceCharacteristicManager discoverServiceUUIDs] indexOfObject: service.UUID];
            
            // 获得服务特征模型
            CBPWKLServiceCharacteristicModel *model = [self.serviceCharacteristicManager serviceCharacteristicModels][index];
            
            // 将特征返回
            return [model characteristicUUIDs];
        } else {
            return nil;
        }
        
    }];

}

- (void) discoverServiceCharacteristic {
    
    __weak CBPBaseDevice *device = self.baseDevice;
    [device setDiscoverServiceCharacteristicBlock:^(CBPBaseServiceModel *discoverServiceCharacteristicModel, CBPBasePeripheralModel *peripheralModel) {
       
        CBService *service = discoverServiceCharacteristicModel.service;
        
        if ([[self.serviceCharacteristicManager discoverServiceUUIDs] containsObject: service.UUID]) {
            
            // 获得索引值
            NSInteger index = [[self.serviceCharacteristicManager discoverServiceUUIDs] indexOfObject: service.UUID];
            
            // 获得服务特征模型
            CBPWKLServiceCharacteristicModel *model = [self.serviceCharacteristicManager serviceCharacteristicModels][index];
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                // 通知特征, 注意, 这里不能使用 if else, 因为读写特征可能会相同
                if ([characteristic.UUID isEqual: model.notifyCharacteristicUUID]) {
                    
                    model.notifyCharacteristic = characteristic;
                    
                    CBPBaseCharacteristicModel *chaModel = [[CBPBaseCharacteristicModel alloc] init];
                    chaModel.chracteristic = characteristic;
                    chaModel.flag = @"1";
                    [device addCharacteristic: chaModel];
                    
                    // 预定通知
                    _isNotifyCharacterstic = YES;
                    [peripheralModel.peripheral setNotifyValue: YES forCharacteristic: characteristic];
                    
                }
                
                if ([characteristic.UUID isEqual: model.writeCharacteristicUUID]) {
                    
                    model.writeCharacteristic = characteristic;
                    CBPBaseCharacteristicModel *chaModel = [[CBPBaseCharacteristicModel alloc] init];
                    chaModel.chracteristic = characteristic;
                    chaModel.flag = @"2";
                    [device addCharacteristic: chaModel];
                    _isWriteCharacteristic = YES;
                    self.writeCharacteristicUUIDString = [characteristic.UUID.UUIDString lowercaseString];
                }
            }
            
            if (_isNotifyCharacterstic == YES && _isWriteCharacteristic == YES) {
                self.currentServiceCharacteristicModel = model;
                self.baseDevice.isChracteristicReady = YES;
            }
        }
    }];
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
