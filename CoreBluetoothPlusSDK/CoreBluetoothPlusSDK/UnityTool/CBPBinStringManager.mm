//
//  CBPBinStringManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/12.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPBinStringManager.h"
#import "CBPStringToHex.h"

@implementation CBPBinStringManager

+ (instancetype)shareManager {
    static CBPBinStringManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
