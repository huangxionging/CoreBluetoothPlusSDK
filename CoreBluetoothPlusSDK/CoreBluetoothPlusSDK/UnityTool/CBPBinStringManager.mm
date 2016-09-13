//
//  CBPBinStringManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/12.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPBinStringManager.h"
#import "CBPStringToHex.h"

@interface CBPBinStringManager () {
    CBPStringToHex *_hexString;
}

@property (nonatomic, strong) NSDictionary *hexToBinDiction;
@end

@implementation CBPBinStringManager

+ (instancetype)shareManager {
    static CBPBinStringManager *manager = nil;
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

- (NSDictionary *)hexToBinDiction {
    
    return  @{
              @"0" : @"0000",
              @"1" : @"0001",
              @"2" : @"0010",
              @"3" : @"0011",
              @"4" : @"0100",
              @"5" : @"0101",
              @"6" : @"0110",
              @"7" : @"0111",
              @"8" : @"1000",
              @"9" : @"1001",
              @"a" : @"1010",
              @"b" : @"1011",
              @"c" : @"1100",
              @"d" : @"1101",
              @"e" : @"1110",
              @"f" : @"1111",
              @"A" : @"1010",
              @"B" : @"1011",
              @"C" : @"1100",
              @"D" : @"1101",
              @"E" : @"1110",
              @"F" : @"1111",};
}


- (NSDictionary *)binToHexDiction {
    
    return  @{
              @"0000": @"0",
              @"0001": @"1",
              @"0010": @"2",
              @"0011": @"3",
              @"0100": @"4",
              @"0101": @"5",
              @"0110": @"6",
              @"0111": @"7",
              @"1000": @"8",
              @"1001": @"9",
              @"1010": @"a",
              @"1011": @"b",
              @"1100": @"c",
              @"1101": @"d",
              @"1110": @"e",
              @"1111": @"f",
              };
}


- (Byte *)bytesForBinString:(NSString *)binString {
    // 得到16进制字符串
    NSString *hexString = [self hexStringForBinString: binString];
    
    // 获得字符串
    return _hexString->bytesForHexString(hexString);
}

- (NSData *) dataForBinString: (NSString *) binString {
    
    // 得到16进制字符串
    NSString *hexString = [self hexStringForBinString: binString];
    return _hexString->dataForHexString(hexString);
}

#pragma mark- 二进制转16进制
- (NSString *)hexStringForBinString:(NSString *)binString {
    NSInteger length = binString.length;
    
    if (length % 4 != 0) {
        NSLog(@"二进制字符串错误");
        return nil;
    }
    
    NSMutableString *hexString = [NSMutableString string];
    for (NSInteger index = 0; index < length;  index += 4) {
        NSString *subBinString = [binString substringWithRange: NSMakeRange(index, 4)];
        
        NSString *subHexString = [[self binToHexDiction] objectForKey: subBinString];
        
        [hexString appendString: subHexString];
    }
    
    return hexString;
}

#pragma mark- 16进制转二进制
- (NSString *)binStringForHexString:(NSString *)hexString {
    // 得到长度
    NSMutableString *binString = [NSMutableString string];
    NSInteger hexLength = hexString.length;
    for (NSInteger index = 0; index < hexLength;  ++index) {
        NSString *subString = [hexString substringWithRange: NSMakeRange(index, 1)];
        
        // 对应二进制字符串
        NSString *subBinString = [[self hexToBinDiction] objectForKey: subString];
        
        // 拼接二进制
        [binString appendString: subBinString];
    }
    
    return binString;

}

#pragma mark- data 转二进制字符串
- (NSString *) binStringForData: (NSData *) data {
    NSInteger length = data.length;
    Byte *bytes = (Byte *)data.bytes;
    return [self binStringForBytes: bytes length:length];
}

#pragma mark- 字节数组转换为二进制字符串
- (NSString *)binStringForBytes:(Byte *)bytes length:(NSUInteger)length {
    // 先得到 16 进制字符串
    NSString *hexString = _hexString->hexStringForBytes(bytes, length);
    // 转换为二进制数据
    return [self binStringForHexString: hexString];
}


- (NSInteger)integerForBinString:(NSString *)binString {
    NSString *hexString = [self hexStringForBinString: binString];
    return _hexString->demicalIntegerForHexString(hexString);
}

- (NSString *)subStringForString:(NSString *)string withStartLocation:(NSInteger)location length:(NSInteger)length {
    return  [string substringWithRange: NSMakeRange(location, length)];
}

@end
