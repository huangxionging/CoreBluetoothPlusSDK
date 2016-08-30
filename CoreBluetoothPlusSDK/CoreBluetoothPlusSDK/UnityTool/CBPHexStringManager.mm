//
//  HexStringManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/8/11.
//  Copyright © 2016年 HelloWorld. All rights reserved.
//

#import "CBPHexStringManager.h"
#import "CBPStringToHex.h"

@interface CBPHexStringManager () {
    CBPStringToHex *_hexString;
}

@end

@implementation CBPHexStringManager

+ (instancetype)shareManager {
    static CBPHexStringManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // 单例
        _hexString = CBPStringToHex::getInstance();
    }
    return self;
}

- (Byte *) bytesForString:(NSString *)hexString {
    return _hexString->bytesForString(hexString);
}

- (NSData *)dataForString:(NSString *)hexString {
    return _hexString->dataForString(hexString);
}

- (NSString *)hexStringForData:(NSData *)data {
    return _hexString->hexStringForData(data);
}

- (NSInteger)integerForString:(NSString *)hexString {
    return _hexString->demicalIntegerForHexString(hexString);
}

- (NSString *)hexStringForBytes:(Byte *)bytes length:(NSUInteger)length{
    return _hexString->hexStringForBytes(bytes, length);
}

@end


