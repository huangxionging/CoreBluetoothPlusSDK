//
//  CBPHexStringManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/8/11.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBPHexStringManager : NSObject

+ (instancetype) shareManager;

// 将16进制字符串转换为字节数
- (Byte *) bytesForString: (NSString *) hexString;

// 将16进制字符串转换为 NSData
- (NSData *) dataForString: (NSString *) hexString;

// NSData 转换为16进制字符串 不带 0x
- (NSString *) hexStringForData: (NSData *) data;

// 将16进制字符串转换为整数
- (NSInteger) integerForString: (NSString *) hexString;

// 将字节数据转换为 16 进制字符串
- (NSString *) hexStringForBytes: (Byte *) bytes length: (NSUInteger) length;
@end
