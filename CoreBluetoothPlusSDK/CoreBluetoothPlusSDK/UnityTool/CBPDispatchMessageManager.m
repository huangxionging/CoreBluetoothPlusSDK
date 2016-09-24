//
//  CBPDispatchMessageManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/9/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPDispatchMessageManager.h"
#import <objc/message.h>

#define EMOJI_METHOD(x,y) + (NSString *)x { return MAKE_EMOJI(y); }
@implementation CBPDispatchMessageManager

+ (instancetype)shareManager {
    static CBPDispatchMessageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });

    return manager;
}

- (void) dispatchTarget:(id)target method:(NSString *)method, ... {
    
    // 方法
    SEL selector = NSSelectorFromString(method);
    NSMutableArray *parameterArray = [NSMutableArray arrayWithCapacity: 5];
    
    if (![target respondsToSelector: selector]) {
        NSAssert(0, @"目标不能响应方法");
    }
    
    // 可变指针
    va_list ap;
    va_start(ap, method);
    
    // 循环获取参数
    id object = nil;
    while ((object = va_arg(ap, id))) {
        [parameterArray addObject: object];
    }
    va_end(ap);
    
    // 调用方法, 为了支持 64 位
    switch (parameterArray.count) {
        case 0: {
            void (*dispatch)(id, SEL) = (void (*)(id, SEL)) objc_msgSend;
            dispatch(target, selector);
            break;
        }
        case 1: {
            void (*dispatch)(id, SEL, id) = (void (*)(id, SEL, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0]);
            break;
        }
        case 2: {
            void (*dispatch)(id, SEL, id, id) = (void (*)(id, SEL, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1]);
            break;
        }
        case 3: {
            void (*dispatch)(id, SEL, id, id, id) = (void (*)(id, SEL, id, id, id)) objc_msgSend;
           dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2]);
            break;
        }
        case 4: {
            void (*dispatch)(id, SEL, id, id, id, id) = (void (*)(id, SEL, id, id, id, id)) objc_msgSend;
           dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3]);
            break;
        }
        case 5: {
            void (*dispatch)(id, SEL, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4]);
            break;
        }
        case 6: {
            void (*dispatch)(id, SEL, id, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5]);
            break;
        }
        case 7: {
            void (*dispatch)(id, SEL, id, id, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6]);
            break;
        }
        case 8: {
            void (*dispatch)(id, SEL, id, id, id, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7]);
            break;
        }
        case 9: {
            void (*dispatch)(id, SEL, id, id, id, id, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7], parameterArray[8]);
            break;
        }
        case 10: {
            void (*dispatch)(id, SEL, id, id, id, id, id, id, id, id, id, id) = (void (*)(id, SEL, id, id, id, id, id, id, id, id, id, id)) objc_msgSend;
            dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7], parameterArray[8], parameterArray[9]);
            break;
        }
        default:
            NSLog(@"😝, 你脑袋被门挤了, 超过10个参数");
            break;
    }
}

- (id)dispatchReturnValueTarget:(id)target method:(NSString *)method, ... {
    // 方法
    SEL selector = NSSelectorFromString(method);
    NSMutableArray *parameterArray = [NSMutableArray arrayWithCapacity: 5];
    
    if (![target respondsToSelector: selector]) {
        NSAssert(0, @"目标不能响应方法");
    }
    
    // 可变指针
    va_list ap;
    va_start(ap, method);
    
    // 循环获取参数
    id object = nil;
    while ((object = va_arg(ap, id))) {
        [parameterArray addObject: object];
    }
    va_end(ap);
    
    // 调用方法, 为了支持 64 位
    switch (parameterArray.count) {
        case 0: {
            id (*dispatch)(id, SEL) = (id (*)(id, SEL)) objc_msgSend;
            return dispatch(target, selector);
            break;
        }
        case 1: {
            id (*dispatch)(id, SEL, id) = (id (*)(id, SEL, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0]);
            break;
        }
        case 2: {
            id (*dispatch)(id, SEL, id, id) = (id (*)(id, SEL, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1]);
            break;
        }
        case 3: {
            id (*dispatch)(id, SEL, id, id, id) = (id (*)(id, SEL, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2]);
            break;
        }
        case 4: {
            id (*dispatch)(id, SEL, id, id, id, id) = (id (*)(id, SEL, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3]);
            break;
        }
        case 5: {
            id (*dispatch)(id, SEL, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4]);
            break;
        }
        case 6: {
            id (*dispatch)(id, SEL, id, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5]);
            break;
        }
        case 7: {
            id (*dispatch)(id, SEL, id, id, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6]);
            break;
        }
        case 8: {
            id (*dispatch)(id, SEL, id, id, id, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7]);
            break;
        }
        case 9: {
            id (*dispatch)(id, SEL, id, id, id, id, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7], parameterArray[8]);
            break;
        }
        case 10: {
            id (*dispatch)(id, SEL, id, id, id, id, id, id, id, id, id, id) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, id)) objc_msgSend;
            return dispatch(target, selector, parameterArray[0], parameterArray[1], parameterArray[2], parameterArray[3], parameterArray[4], parameterArray[5],parameterArray[6], parameterArray[7], parameterArray[8], parameterArray[9]);
            break;
        }
        default:
            NSLog(@"😝, 你脑袋被门挤了, 超过10个参数");
            return nil;
            break;
    }
}

@end

