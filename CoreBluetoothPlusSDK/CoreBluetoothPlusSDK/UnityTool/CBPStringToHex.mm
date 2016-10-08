//
//  CBPStringToHex.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/27.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#include "CBPStringToHex.h"

#pragma mark- 默认构造函数
CBPStringToHex::CBPStringToHex () {
    
    // 将16进制数据写入 map 表
    for (int index = 0; index < 16; ++index) {
        
        // 创建 char
        char *hexChar = (char *)malloc(sizeof(char));
        
        // 写入 char
        sprintf(hexChar, "%x", index);

        // 插入到 map
        hex_map.insert(pair<char, int>(*hexChar, index));
    }
    
}

#pragma mark- 析构函数
CBPStringToHex::~CBPStringToHex() {
    free(&hex_map);
}

#pragma mark- 单例, 获取实例
CBPStringToHex * CBPStringToHex::getInstance() {
    
    // 采用 oc 的标准
    static CBPStringToHex *instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = new CBPStringToHex();
    });
    
    return instance;
}

#pragma mark- 将16进制字符串转换成字节数组
Byte *CBPStringToHex::bytesForHexString(NSString *strings) {
    
    if (![strings hasPrefix: @"0x"]) {
        strings = [NSString stringWithFormat: @"0x%@", strings];
    }
    if (strings == nil) {
        return NULL;
    }
    
    // 求长度
    NSUInteger length = strings.length / 2 - 1;
    
    // 创建字节数组
    Byte *bytes = (Byte *)malloc(sizeof(Byte) *length);
    memset(bytes, 0, length);
    
    // 转换成小写
    NSString *lowcaseString = [strings lowercaseString];
    
    // for loop 开始转换
    for (NSInteger index = 2; index < lowcaseString.length; index+=2) {
        
        // 获取高位字符
        char highChar = [lowcaseString characterAtIndex: index];
        
        // 获取低位字符
        char lowChar = [lowcaseString characterAtIndex: index + 1];
        
//        NSLog(@"%c === %c", highChar, lowChar);
        // 获取值
        int highValue = hex_map.find(highChar)->second;
        int lowValue = hex_map.find(lowChar)->second;
        
        bytes[index / 2 - 1] = highValue * 16 + lowValue;
    }
    
    return bytes;
}

#pragma mark- 将16进制字符串转换为二进制 Data
NSData *CBPStringToHex::dataForHexString (NSString *strings) {
    
    if (![strings hasPrefix: @"0x"]) {
        strings = [NSString stringWithFormat: @"0x%@", strings];
    }
    NSInteger leng = strings.length / 2 - 1;
    
    // 通过之前 API 来转换
    Byte *bytes = this->bytesForHexString(strings);
    
    return [NSData dataWithBytes: bytes length: leng];
    
}

#pragma mark- 二进制 Data 转换为字符串
NSString *CBPStringToHex::hexStringForData(NSData *data) {
    
    // 用可变字符串接
    NSMutableString *mutableString = [NSMutableString string];
    // 处理 data 所有的数据
    NSInteger length = data.length;
    Byte *bytes = (Byte *)[data bytes];
    for (NSInteger index = 0; index < length; ++index) {
        [mutableString appendFormat: @"%02x", bytes[index]];
    }
    return mutableString;
}

#pragma mark- 获取对应的10进制数
NSInteger CBPStringToHex::demicalIntegerForHexString(NSString *strings) {
    
    // 添加 0x 前缀
    if (![strings hasPrefix: @"0x"]) {
        strings = [NSString stringWithFormat: @"0x%@", strings];
    }
    
    // 得到长度
    NSInteger leng = strings.length / 2 - 1;
    
    // 获得字节
    Byte *bytes = this->bytesForHexString(strings);
    
    // 获取结果
    NSInteger sum = 0;
    for (NSInteger index = leng - 1; index >= 0; --index) {
        sum += bytes[index] * pow(256, leng - index - 1);
    }
    return sum;
}

NSString *CBPStringToHex::hexStringForBytes(Byte *bytes, NSUInteger length) {
    
    // 数据
    NSData *data = [NSData dataWithBytes: bytes length: length];
    
    if (!data) {
        return nil;
    }
    // 16进制字符串
    NSString *hexString = this->hexStringForData(data);
    
    return hexString;
    
}
