//
//  CBPStringToHex.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/27.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#ifndef CBPStringToHex_hpp
#define CBPStringToHex_hpp

#import <stdio.h>
#import <map>
#import <string>
#import <Foundation/Foundation.h>

using namespace std;

class CBPStringToHex {
    map<char, int> hex_map;
    
public:
    
    // 默认构造函数
    CBPStringToHex();
    
    // 析构函数
    ~CBPStringToHex();
    
    // 单例模式
    static CBPStringToHex * getInstance();
    
    // 将 oc 字符串转换成字节
    Byte * bytesForHexString(NSString *hexString);
    
    // 转换成 data
    NSData * dataForHexString(NSString *hexString);
    
    // 将 16 进制数据转换成字符串, 不以 @"0x" 开头
    NSString *hexStringForData(NSData *data);
    
    // 将16进制字符串转换成整数, 适用于小数据量
    NSInteger demicalIntegerForHexString(NSString *hexString);
    
    // 将指定16字节转换为对应的字符串
    NSString *hexStringForBytes(Byte *bytes, NSUInteger length);
};

#endif /* StringToBytes_hpp */