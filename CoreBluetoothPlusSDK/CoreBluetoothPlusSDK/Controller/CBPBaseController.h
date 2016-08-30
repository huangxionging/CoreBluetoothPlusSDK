//
//  CBPBaseController.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPBaseClient.h"
#import "CBPBaseDevice.h"
#import "CBPBaseAction.h"
#import "CBPBaseError.h"

/**
 *  基础控制器
 */
@interface CBPBaseController : NSObject

/**
 *  基础连接, 负责查找外设
 */
@property (nonatomic, strong) CBPBaseClient *baseClient;

/**
 *  基础设备, 负责管理数据
 */
@property (nonatomic, strong) CBPBaseDevice *baseDevice;


/**
 *  @author huangxiong, 2016/05/26 10:47:00
 *
 *  @brief 集合
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *actionKeywordSet;

/**
 *  @author huangxiong, 2016/05/26 10:01:05
 *
 *  @brief 操作字典, 回传数据根据操作字典进行投送
 *
 *  @since 1.0
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CBPBaseAction *> *actionSheet;

/**
 *  写特征的 UUID 标识符
 */
@property (nonatomic, strong) NSString *writeCharacteristicUUIDString;

/**
 *  @author huangxiong
 *
 *  @brief 开始工作, with block
 *
 *  @param block 回调
 */
-(void) startWorkWithBlock: (void(^)(id result))block;

/**
 *  @brief  开始工作
 *  @param  baseClient
 *  @return void
 */
- (void) startWorkWithClient: (CBPBaseClient *)baseClient;

/**
 *  @brief  设置设备
 *  @param  baseDevice 是从外部传进来的设备
 *  @return void
 */
- (void)setBaseDevice:(CBPBaseDevice *)baseDevice;

/**
 *  @brief  发送操作
 *  @param  baseAction
 *  @return void
 */
- (void) sendAction: (CBPBaseAction *) baseAction;

/**
 *  @brief  设备开始工作, 通过传入外设模型
 *  @param  peripheralModel 是外设模型
 *  @return void
 */
- (void) deviceStartWorkWith: (CBPBasePeripheralModel *) peripheralModel;


/**
 *  @author huangxiong, 2016/04/13 15:42:56
 *
 *  @brief 发送操作并协调返回数据
 *
 *  @param actionName action 具体的 action类名
 *  @param parameters action 所需要的参数
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @since 1.0
 */
- (void) sendAction:(NSString *)actionName parameters:(id)parameters success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure;

/**
 *  @author huangxiong, 2016/05/25 14:57:36
 *
 *  @brief 注册 action, 注册成功才能发送数据, 否则应当返回错误
 *
 *  @param action action
 *
 *  @return 返回注册成功或者失败
 *
 *  @since 1.0
 */
- (BOOL) registerAction: (CBPBaseAction *) action;

/**
 *  @author huangxiong, 2016/06/06 20:07:19
 *
 *  @brief 删除 action 释放通道
 *
 *  @param action 操作
 *
 *  @return 删除结果
 *
 *  @since 1.0
 */
- (BOOL) removeAction: (CBPBaseAction *) action;


@end
