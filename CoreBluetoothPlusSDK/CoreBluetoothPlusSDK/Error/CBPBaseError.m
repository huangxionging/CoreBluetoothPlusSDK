//
//  CBPBaseError.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseError.h"

@implementation CBPBaseError

+ (instancetype)errorWithcode:(BaseErrorType)errorType info:(NSString *)info {
    
    if ([info isKindOfClass: [NSString class]]) {
        return [CBPBaseError errorWithDomain: @"www.movnow.com" code: errorType userInfo: @{NSLocalizedDescriptionKey : info}];
    } else {
        return [CBPBaseError errorWithDomain: @"www.movnow.com" code: errorType userInfo: nil];
    }
    
}

- (void)errorLog {
    NSLog(@"%@", self.localizedDescription);
}

@end
