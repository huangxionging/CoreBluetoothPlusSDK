//
//  CBPBaseActionDataModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CBPBaseAction;

/**
 *  操作数据的数据类型
 */
typedef NS_ENUM(NSUInteger, BaseActionDataType){
    /**
     *  更新发送的数据 这个是 Client 发给 Device 的数据标志
     */
    kBaseActionDataTypeUpdateSend = 0,
    
    /**
     *  更新数据的回复的数据 
     *  @see peripheral:didUpdateValueForCharacteristic:error
     */
    kBaseActionDataTypeUpdateAnwser,
    
    /**
     *  写数据时的 
     *  @see peripheral:didWriteValueForCharacteristic:error
     */
    kBaseActionDataTypeWriteAnswer,
};

@interface CBPBaseActionDataModel : NSObject

/**
 *  操作数据
 */
@property (nonatomic, strong) NSData *actionData;

/**
 *  操作使用的特征所用的 UUID 的标识符
 */
@property (nonatomic, copy) NSString *characteristicString;

// 使用的特征
@property (nonatomic, weak) CBCharacteristic *characteristic;

/**
 *  操作数据类型, 类型为发送的数据, 还是回复的数据
 */
@property (nonatomic, assign) BaseActionDataType actionDatatype;

/**
 *  错误结果
 */
@property (nonatomic, strong) NSError *error;

/**
 *  是否需要回复
 */
@property (nonatomic, assign) CBCharacteristicWriteType writeType;

/**
 *  关键字
 */
@property (nonatomic, copy) NSString *keyword;


/**
 *  发送命令时使用
 */
+ (instancetype) modelWithAction: (CBPBaseAction *)action;

@end
