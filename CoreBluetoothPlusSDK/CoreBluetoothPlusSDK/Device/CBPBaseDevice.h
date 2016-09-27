//
//  CBPBaseDevice.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPBaseActionDataModel.h"
#import "CBPBasePeripheralModel.h"
#import "CBPBaseServiceModel.h"

@class CBPBaseCharacteristicModel;

@interface CBPBaseDevice : NSObject <CBPeripheralDelegate>

/**
 *  由外部设置, 全部特征是否已找到, 找到了, 才可以发送操作
 */
@property (nonatomic, assign) BOOL isChracteristicReady;

/**
 *  特征搜索定时器器超时时间
 */
@property (nonatomic, assign) NSTimeInterval time;

/**
 *  @brief  添加服务的 UUID
 *  @param  serviceUUIDString 是服务的 UUID 标识符
 *  @return void
 */
- (void) addServiceUUIDWithUUIDString: (NSString *)serviceUUIDString;

/**
 *  @brief  添加特征的的 UUID
 *  @param  characteristicUUIDString 是特征的 UUID 标识符
 *  @return void
 */
- (void) addCharacteristicUUIDWithUUIDString: (NSString *)characteristicUUIDString;

/**
 *  @brief  添加特征的
 *  @param  characteristic 是特征
 *  @return void
 */
- (void) addCharacteristic: (CBPBaseCharacteristicModel *) characteristicModel;

/**
 *  @brief  设定特征读取定时器超时时间, 默认为10秒钟, 当 isChracteristicReady 没有变成 yes 才会超时
 *  @param  time 是超时时间
 *  @return void
 */
- (void) setDiscoverCharacteristicTimerOutTime: (NSTimeInterval) time;

/**
 *  @brief  取消定时器工作
 *  @param  void
 *  @return void
 */
- (void) stopDiscoverCharacteristicTimer;

/**
 *  @brief  定时器超时回调
 *  @param  timerBlock 是定时器超时回调
 *  @return void
 */
- (void) discoverCharacteristicTimerTimeOutBlock: (void(^)(NSError *error))timerBlock;

/**
 *  @brief  通过外设开始工作
 *  @param  peripheral 是外设
 *  @return void
 */
- (void) startWorkWith: (CBPBasePeripheralModel *)peripheralModel;


/**
 切换外设模型, 前提是已连接的外设, 用于支持多外设连接

 @param peripheralModel 外设模型
 */
- (void) changePeripheral: (CBPBasePeripheralModel *)peripheralModel;

/**
 *  @brief  发送命令
 *  @param  actionDataModel 是操作的数据模型
 *  @return void
 */
- (void) sendActionWithModel:(CBPBaseActionDataModel *) actionDataModel;

/**
 *  @brief  设置更新回调, 主要用于接收外设发回的数据, 每次接收一个短包
 *  @param  upadateDataBlock 更新数据回调
 *  @return void
 */
- (void) setUpdateDataBlock: (void(^)(CBPBaseActionDataModel *actionDataModel)) upadateDataBlock;

/**
 *  @brief  设置写回调, 主要是发送命令数据
 *  @param  writeDataBlock 写回调
 *  @return void
 */
- (void) setWriteDataBlock: (void(^)(CBPBaseActionDataModel *actionDataModel)) writeDataBlock;

/**
 *  @brief  设置发现指定特征的服务回调
 *  @param  discoverServiceBlock 写回调
 *  @return void
 */
- (void) setDiscoverServiceBlock: (void(^)(CBPBaseServiceModel *discoverServiceModel))discoverServiceBlock;

/**
 *  @brief   获取所有服务的 CBUUID
 */
- (NSArray<CBUUID *> *)serviceUUIDs;

/**
 *  所有特征的
 */
- (NSArray<CBUUID *> *)characteristicUUIDs;



@end
