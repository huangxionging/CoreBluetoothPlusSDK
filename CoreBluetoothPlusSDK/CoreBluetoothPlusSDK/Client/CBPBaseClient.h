//
//  CBPBaseClient.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/8/16.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPBasePeripheralModel.h"

/**
 *  负责蓝牙的基础连接, 外设扫描, 数据传输, 无需考虑可靠性问题.
 */
@interface CBPBaseClient : NSObject<CBCentralManagerDelegate>

+ (instancetype) shareBaseClient;

/**
 *  @brief  添加待扫描外设的服务的 UUID
 *  @param  serviceUUID 是待扫描外设的服务的 UUID
 *  @return void
 */
- (void) addPeripheralScanService: (CBUUID *) serviceUUID;

/**
 *  @brief  添加待扫描外设的服务的 UUID, 数组
 *  @param  serviceUUIDs 是待扫描外设的服务的 UUID 组成的数组
 *  @return void
 */
- (void) addPeripheralScanServices:(NSArray<CBUUID *> *) serviceUUIDs;

/**
 *  @brief  开始扫描
 *  @param  options 是扫描的选项数组
 *  @return void
 *
 *  @seealso            CBCentralManagerScanOptionAllowDuplicatesKey
 *	@seealso			CBCentralManagerScanOptionSolicitedServiceUUIDsKey
 */
- (void) startScanPeripheralWithOptions: (NSDictionary<NSString *, id> *) options;

/**
 *  @brief  设置 扫描超时时间, 默认为 10 秒
 *  @param  interval 是超时时间, 单位为秒数
 *  @return void
 */
- (void) setScanTimeOut: (NSTimeInterval) interval;

/**
 *  @brief  可以开始扫描的回调
 *  @param  scanReadyBlock 是可以开始扫描的回调, 回调会通知上层是否已经可以扫描
 *  @return void
 */
- (void) setScanReadyBlock: (void(^)(CBManagerState ready)) scanReadyBlock;

/**
 *  @brief  已找到外设的回调
 *  @param  searchedPeripheralBlock 是查找最佳匹配的外设的操作, 回调会通知上层找到最佳外设
 *  @return void
 */
- (void) setSearchedPeripheralBlock: (void(^)(CBPBasePeripheralModel *peripheral)) searchedPeripheralBlock;

/**
 *  @brief  已链接外设回调
 *  @param  connectionPeripheralBlock是连接外设回调
 *  @return void
 */
- (void) setConnectionPeripheralBlock: (void(^)(CBPBasePeripheralModel *peripheral)) connectionPeripheralBlock;

/**
 *  @brief  停止扫描
 *  @param  void
 *  @return void
 */
- (void) stopScan;

/**
 *  @brief  连接外设
 *  @param  options 是连接选项
 *  @return void
 */
- (void)connectPeripheral:(CBPBasePeripheralModel *)peripheralModel options:(nullable NSDictionary<NSString *, id> *)options;
/**
 *  @brief  取消连接外设
 *  @param  void
 *  @return void
 */
- (void) cancelPeripheralConnection;
@end
