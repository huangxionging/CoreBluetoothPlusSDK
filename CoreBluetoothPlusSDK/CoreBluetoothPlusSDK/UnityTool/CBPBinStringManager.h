//
//  CBPBinStringManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/12.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author huangxiong
 *
 *  @brief 二进制字符串转换工具 @"0110010" => 0110010
 */
@interface CBPBinStringManager : NSObject

+ (instancetype) shareManager;

// 将二进制字符串转换为字节数
- (Byte *) bytesForString: (NSString *) binString;

// 将二进制字符串转换为 NSData
- (NSData *) dataForString: (NSString *) binString;

// NSData 转换为二进制字符串
- (NSString *) binStringForData: (NSData *) data;

// 将二进制字符串转换为整数
- (NSInteger) integerForString: (NSString *) binString;

// 将字节数据转换为二进制字符串
- (NSString *) binStringForBytes: (Byte *) bytes length: (NSUInteger) length;

@end
