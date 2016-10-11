//
//  QBleClient.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define bleDiscoveredCharacteristicsNoti           @"ble-DiscoveredCharasNoti"

/// 纬科联蓝牙OTA升级连接代理
@protocol bleDidConnectionsDelegate<NSObject>
/**
 * 纬科联蓝牙OTA升级连接成功
 *
 *  @param aPeripheral 外设对象
 */
-(void)bleDidConnectPeripheral : (CBPeripheral *)aPeripheral;
@end

/// 纬科联蓝牙OTA升级代理
@protocol bleUpdateForOtaDelegate<NSObject>

/**
 *  发现升级服务
 *
 *  @param aPeri    外设对象
 *  @param aService 升级服务
 *  @param error    错误信息
 */
-(void)bleDidUpdateCharForOtaService : (CBPeripheral *)aPeri
                         withService : (CBService *)aService
                               error : (NSError *)error;

/**
 *  升级数据回调
 *
 *  @param aService       服务
 *  @param characteristic 特征值
 *  @param error          错误信息
 */
-(void)bleDidUpdateValueForOtaChar : (CBService *)aService
                          withChar : (CBCharacteristic *)characteristic
                             error : (NSError *)error;
@end

@interface qBleClient : NSObject<CBPeripheralDelegate>

/// 纬科联蓝牙OTA升级连接代理
@property (nonatomic,assign) id <bleUpdateForOtaDelegate>  bleUpdateForOtaDelegate;
/// 纬科联蓝牙OTA升级代理
@property (nonatomic,assign) id <bleDidConnectionsDelegate> bleDidConnectionsDelegate;

@property (nonatomic,copy) CBPeripheral *peripheral;

///服务数组
@property (nonatomic, readonly, retain) NSMutableArray *discoveredServices;


+(qBleClient *)sharedInstance;
@end
