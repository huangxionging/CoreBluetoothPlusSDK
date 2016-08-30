//
//  CBPWKLTransparentTransmissionAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/24.
//  Copyright © 2015年 huangxiong. All rights reserved.
//


#import "CBPBaseAction.h"

// 每个长包内容的最大长度
const NSInteger max_content_length = 1024;

// 每个短包内容的最大长度 字节
const NSInteger max_short_content_length = 17;

// 短包最大程度 20字节
const NSInteger max_short_package_length = 20;
/**
 *  本操作为透明传输操作, 旨在实现透明传输, 不做功能定义
 */

@interface CBPWKLTransparentTransmissionAction : CBPBaseAction

/**
 *  0x00 表示透传操作为短包, 内容由收发双方自定义;
 *  0x01~0x10 表示短包, 也表示内容长度;
 *  关键字取值为0x01~0x10时,除表示本包为短包透传指令外,还表示内容部分的长度;
 *  关键字0x01~0x10表示相同的功能,同一项目中一般应分配给同一个逻辑功能。若分配给多个功能,则
 *  设备与 APP 端应协商一致,并严格按约定使用。
 *  0x11~0xef 表示短包, 未定义功能, 预留
 *  0xf0 表示长包, 支付相关功能
 *  0xf1~0xfe 表示长包, 未定义
 *  0xff 表示长包, 需要协商
 *  keyWord
 */
@property (nonatomic, copy) NSString *keyWord;

/**
 *  数据内容, 总共长度不固定, 最大为 16 字节以 0x 开头的16进制字符串, 每个字节栈两位
 */
@property (nonatomic, copy) NSString *content;


- (NSData *)actionData;

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

// 继续发送指令
- (void) continueSendAction;

@end
