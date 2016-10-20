//
//  CBPWKLTransparentTransmissionAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/24.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLTransparentTransmissionAction.h"
#include "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"


// 短包最大程度 20字节
static NSInteger max_short_package_length = 20;

unsigned short crc_ccitt(unsigned char *q, int len);

@interface CBPWKLTransparentTransmissionAction () {
    
    /**
     *  操作长度, 字节数
     */
    NSInteger _actionLength;
    
    /**
     *  位域控制表
     */

    Byte _bitControlTable[15];

    /**
     *  短包数
     */
    Byte _shortPackage[120][17];
    
    /**
     *  表示设备是否主动发送
     */
    BOOL _deviceFirst;
    
    CBPHexStringManager *_hexStringMangaer;
    
    // 关键字
    Byte _byteKeyWord;
    
    Byte _actionKeyWord;
    
    long _totalSize;
}

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

/**
 *  同时表示长包的个数
 */
@property (nonatomic, assign) NSInteger longPackageTotal;

/**
 *  长包计数, 也即长包序号
 */
@property (nonatomic, assign) NSInteger longPackageNumber;

/**
 *  一个长包有效数据个数
 */
@property (nonatomic, assign) NSInteger effectiveDataCount;

/**
 *  短包个数
 */
@property (nonatomic, assign) NSInteger shortPackageCount;

/**
 * 短包序号计数
 */
@property (nonatomic, assign) NSInteger shortPackageNumber;

/**
 *  单个长包数据
 */
@property (nonatomic, strong) NSMutableData *longPackageData;

/**
 *  一天的总步数
 */
@property (nonatomic, copy) NSString *oneDayTotalData;

/**
 *  每天的数据信息
 */
@property (nonatomic, strong) NSMutableDictionary *dataInfo;

/**
 * 包含所有长包数据
 */
@property (nonatomic, strong) NSMutableArray *allData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *longActionArray;

@property (nonatomic, assign) NSInteger indexOfAction;

@end


@implementation CBPWKLTransparentTransmissionAction

@synthesize isLongAction = _isLongAction;

+ (void)load {
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x19", @"0x05", @"0x06", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys 同步心率数据
    NSArray *interfaces = @[@"synchronize_heart_rate_data"];
    // 返回接口
    return interfaces;
}


- (NSInteger)actionLength {
    return _actionLength;
}


#pragma mark- 长指令数组
- (NSMutableArray *)longActionArray {
    if (_longActionArray == nil) {
        _longActionArray = [NSMutableArray arrayWithCapacity: 10];
    }
    return _longActionArray;
}

#pragma mark- 发送指令相关
- (void)actionData {
    
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    NSAssert(parameter, @"参数写错了");
    _content = parameter[@"content"];
    _keyWord = parameter[@"keyword"];
    if (![_content hasPrefix: @"0x"]) {
        _content = [NSString stringWithFormat: @"0x%@", _content];
    }
    NSLog(@"内容数据: %@", _content);
    if (_content) {
        NSInteger length = _content.length / 2 - 1;
        _actionLength = length;
    } else {
        return;
    }
    
    Byte *bytes = (Byte *)malloc(sizeof(Byte) * max_short_package_length);
    memset(bytes, 0x00, sizeof(Byte) * max_short_package_length);
    // 创建 解析器
    _hexStringMangaer = [CBPHexStringManager shareManager];
    
    bytes[0] = 0x5a;
    bytes[1] = 0x19;
    bytes[2] = 0x00;
    
    // 超过16 就要分包了.
    if (_actionLength <= 16) {
        // 记录关键字
        _byteKeyWord = *[_hexStringMangaer bytesForString: _keyWord];
        bytes[3] = _byteKeyWord;
        
        // 拷贝数据
        memcpy(&bytes[4], [_hexStringMangaer bytesForString: _content], _actionLength);
        _isLongAction = NO;
    } else {
        _isLongAction = YES;
        NSInteger shortActionCount = _actionLength / 16 + ((_actionLength % 16) ? 1 : 0);
        
        _indexOfAction = 1;
        for (NSInteger index = 0; index < shortActionCount; ++index) {
            
            NSInteger len = 16;
            if (index == shortActionCount - 1) {
                len = _actionLength - index * 16;
            }
            
            NSRange range = NSMakeRange(index * 16 * 2 + 2, len * 2);
            NSString *shortAction = [_content substringWithRange: range];
            
            // 添加长包
            [self.longActionArray addObject: shortAction];
        }
        
        bytes[3] = 0x11;
        // 拷贝数据
        memcpy(&bytes[4], [_hexStringMangaer bytesForString:[self.longActionArray firstObject]], 16);
    }
    
    _actionKeyWord = 0x19;
    
    // 数据 气死爸爸了
    NSData *data = [NSData dataWithBytes: bytes length: max_short_package_length];
    
    
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];}

#pragma mark- 继续发送
- (void) continueSendAction {
    
    if (_indexOfAction > self.longActionArray.count) {
        return;
    } else if (_indexOfAction == self.longActionArray.count - 1) {
        [self sendLastAction];
    } else {
        [self sendCommonAction];
    }
}

#pragma mark- 发送普通包
- (void) sendCommonAction {
    
    if (_indexOfAction > self.longActionArray.count) {
        return;
    }
    
    Byte bytes[20] = {0};
    
    // 普通包标识
    bytes[0] = 0x5a;
    bytes[1] = 0x19;
    bytes[3] = (0x11 + _indexOfAction);
    
    // 拷贝数据
    NSString *lastAction = self.longActionArray[_indexOfAction];
    
    memcpy(&bytes[4], [_hexStringMangaer bytesForString: lastAction], lastAction.length / 2);
    _indexOfAction++;
    // 发送指令数据
    NSData *data = [NSData dataWithBytes: bytes length: lastAction.length / 2 + 4];
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
}

#pragma mark- 发送最后的包
- (void) sendLastAction {
    
    if (_indexOfAction > self.longActionArray.count) {
        return;
    }
    
    
    Byte bytes[20] = {0};
    
    // 最后一包标识
    bytes[0] = 0x5a;
    bytes[1] = 0x19;
    bytes[3] = 0xdf;
    
    // 拷贝数据
    NSString *lastAction = [self.longActionArray lastObject];
    
    memcpy(&bytes[4], [_hexStringMangaer bytesForString: lastAction], lastAction.length / 2);
    
    NSData *data = [NSData dataWithBytes: bytes length: lastAction.length / 2 + 4];
    
    _indexOfAction = self.longActionArray.count + 1;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
}


#pragma mark- 接受数据
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    // 关闭超时定时器
    NSLog(@"接受数据 AAA %@", updateDataModel.actionData);
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        if (bytes == NULL) {
            return;
        }
        
        if (bytes[0] == 0x5a) {
            _deviceFirst = YES;
        } else {
            _deviceFirst = NO;
        }
        
        // 表示 设备主动发送
        if (_deviceFirst) {
            // 长包
            if (bytes[1] == 0x19 && bytes[3] >= 0xf0) {
                 [self handleFirstAnswer: bytes];
                return;
            } else if (bytes[1] == 0x19 && bytes[3] < 0xf0) {
                // 短包处理
                NSLog(@"发送的是短包数据");
                if (_longPackageData == nil) {
                    _longPackageData = [NSMutableData data];
                }
                
                // 短包且表示长度
                NSInteger length = bytes[3];
                
                _longPackageData.length = 0;
                [_longPackageData appendBytes: &bytes[4] length: length];
                
                // 短包 回复, 回复都是 0x5b
                NSLog(@"短包:%@  ==== length: %@", _longPackageData, @(_longPackageData.length));
                
                // 完成信息
                // 待回传的结果
                NSMutableDictionary *success = [NSMutableDictionary dictionaryWithCapacity: 5];
                
                NSString *result = [_hexStringMangaer  hexStringForData:_longPackageData];
                // 传输结果
                [success setObject: result forKey: @"result"];
                // 回传结果
                [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", success, nil];

            }
            // 设备开始主动发数据, 通用长包处理过程
            if (bytes[1] == 0x05) {
                
                if (bytes[2] == 0x01) {
                    
                    // 处理短包 操作信息
                    [self handleShortPackageActionAnswer: bytes];
                } else if (bytes[2] >= 0x02 && bytes[2] < 0xfe) {
                    
                    // 处理短包有效信息
                    [self handleShortPackageEffectiveAnswer: bytes];
                    
                } else if (bytes[2] == 0xfe) {
                    // 每个长包的最后一个短包
                    [self handleShortPackageLastAnswer: bytes];
                    
                } else if (bytes[2] == 0xff) {
                    // 最后一天数据
                    [self handleLastDayPackage: bytes];
                    
                } else if (bytes[2] == 0x00) {
                    // 特殊回应
                    [self handleNextDataPackage];
                }
            }

        } else {
           // 5b1900ff 00
            if (bytes[1] == 0x19 && bytes[3] >= 0xf0) {
               
            } else if (bytes[1] == 0x19 && bytes[3] < 0xf0) {
                // 短包处理
                NSLog(@"发送的是短包数据");
                if (_longPackageData == nil) {
                    _longPackageData = [NSMutableData data];
                }
                
                // 短包且表示长度
                NSInteger length = bytes[3];
                
                _longPackageData.length = 0;
                [_longPackageData appendBytes: &bytes[4] length: length];
                
                // 短包 回复, 回复都是 0x5b
                NSLog(@"短包:%@  ==== length: %@", _longPackageData, @(_longPackageData.length));
                
                // 待回传的结果
                NSMutableDictionary *success = [NSMutableDictionary dictionaryWithCapacity: 5];
                
                NSString *result = [_hexStringMangaer  hexStringForData:_longPackageData];
                // 传输结果
                [success setObject: result forKey: @"result"];
                // 回传结果
                [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", success, nil];
            }
        }
    }
}

#pragma mark---处理第一个数据
- (void) handleFirstAnswer: (Byte *) bytes {
    
    
    _totalSize = 0;
    
    _longPackageTotal = 0;
    
    // 总长包的个数
    _totalSize = (bytes[4] << 24) + (bytes[5] << 16) + (bytes[6] << 8) + bytes[7];
    
    NSInteger oneLongPackageSize = bytes[8] * 256 + bytes[9];
    
    _longPackageTotal = _totalSize / oneLongPackageSize + (_totalSize % oneLongPackageSize)?1:0;
    
    NSLog(@"长包数%@", @(_longPackageTotal));
    NSLog(@"一个长包的长度%@", @(oneLongPackageSize));
    NSLog(@"总长度%@", @(_totalSize));

}

#pragma mark--- 处理每个长包的第一个短包数据
- (void) handleShortPackageActionAnswer: (Byte *) bytes {
    
    if (bytes[9] != _actionKeyWord) {
        return;
    }
    
    // 有效数据个数
    self.effectiveDataCount = bytes[3] * 256 + bytes[4];
    
    // 记录长包数据
    if (_longPackageData == nil) {
        _longPackageData = [NSMutableData data];
    }
    
    // 清空每个长包
    _longPackageData.length = 0;
    
    _shortPackageNumber = bytes[2];
    
    // 短包个数,
    _shortPackageCount = self.effectiveDataCount / 17 + ((self.effectiveDataCount % 17)?1:0);
    
    // 记录长包序号
    _longPackageNumber = bytes[5] * 256 + bytes[6];
    
    // 第一个分包位域控制, 以下三种算法都 ok, 采用取反的方法 ! 不行
    //_bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff - (1<< ((_shortPackageNumber - 1) % 8));
    
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<(_shortPackageNumber - 1) % 8);
    
    // 最后一包所在位域
    NSInteger bitIndex = _shortPackageCount % 8 + 1;
    for (NSInteger index = bitIndex; index < 8; ++index) {
        _bitControlTable[(_shortPackageCount) / 8] &= 0xff^(1<<index);
    }
    
    // 0xff - pow(2, (_shortPackageNumber - 1) / 8))
    
    // 位域控制
    for (NSInteger index = (_shortPackageCount) / 8 + 1; index < 15; ++index) {
        _bitControlTable[index] = 0x00;
    }
    
    memset(_shortPackage, '\0', sizeof(_shortPackage));
}

#pragma mark---处理有效数据
- (void) handleShortPackageEffectiveAnswer: (Byte *) bytes {
    
    // 屏蔽掉不合理数据
    if (bytes[2] < 0x02 || bytes[2] >= 0xfe) {
        return;
    }
    
    // 获取短包序号 是从 0x02 开始
    _shortPackageNumber = bytes[2];
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<((_shortPackageNumber - 1) % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 获取短包序号 是从 0x02 开始, 所以要减去 2
    memcpy(_shortPackage[_shortPackageNumber - 2], effectiveByte, sizeof(Byte) * 17);
}

#pragma mark---处理除最后一个长包外的每个长包的最后一个短包,
- (void) handleShortPackageLastAnswer: (Byte *) bytes {
    
    // 过滤数据
    if (bytes[2] != 0xfe) {
        return;
    }
    
    // 修改短包序号
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    if (!effectiveLength) {
        effectiveLength = 17;
    }
    
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDayData];
    }
    
    [self sendBitControllTable];
}

#pragma mark---判断位域表
- (BOOL) shortPackageFinished {
    
    // 判断位域表是否全部为 0
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark---处理睡眠数据
- (void) handleOneDayData {
    
    for (NSInteger index = 0; index < _shortPackageCount; ++index) {
        
        if (index == _shortPackageCount - 1) {
            // 最后一个有效数据的长度
            NSInteger effectiveLength = _effectiveDataCount % 17;
            
            // 有效数据
            if (!effectiveLength) {
                effectiveLength = 17;
            }
            
            // 最后一个短包
            [_longPackageData appendBytes: _shortPackage[index] length: effectiveLength];
            
        } else {
            [_longPackageData appendBytes: &_shortPackage[index] length: 17];
        }
    }
    
    NSLog(@"所有数据:%@ ====> 长度: %@", _longPackageData, @(_longPackageData.length));
    
        // 获得数据
}

#pragma mark---发送位域控制表
- (void) sendBitControllTable {
    @try {
        
        Byte bytes[20] = {0};
        
        // 确认位域表
        bytes[0] = 0x5b;
        bytes[1] = 0x05;
        bytes[3] = _longPackageNumber / 256;
        bytes[4] = _longPackageNumber % 256;
        
        Byte *bitControlTable = &bytes[5];
        
        memcpy(bitControlTable, _bitControlTable, sizeof(_bitControlTable) / sizeof(Byte));
        
        NSData *bitControlTableData = [NSData dataWithBytes: bytes length: 20];
        // 发送指令数据
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", bitControlTableData, nil];
        }
    @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
    }   
}

#pragma mark---处理请求下一个长包
- (void) handleNextDataPackage {
    
    if (_longPackageNumber == _longPackageTotal || _longPackageTotal == 1) {
        // 表示所有数据发送完成
        
        NSLog(@"%@  ==== length: %@", _longPackageData, @(_longPackageData.length));
        
        // 待回传的结果
        NSMutableDictionary *success = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        NSString *result = [_hexStringMangaer  hexStringForData:_longPackageData];
        // 传输结果
        [success setObject: result forKey: @"result"];
        // 回传结果
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", success, nil];
        return;
    }
    
    memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
    
    Byte bytes[20] = {0};
    
    // 确认长包
    bytes[0] = 0x5a;
    bytes[1] = 0x06;
    bytes[3] = _longPackageNumber / 256;
    bytes[4] = _longPackageNumber % 256;
    
    if (_longPackageNumber == _longPackageTotal || _longPackageTotal == 1) {
        bytes[3] = 0xff;
        bytes[4] = 0xff;
    }
    
    // 请求下一个回复数据
    NSData *nextData = [NSData dataWithBytes: bytes length: 20];
    
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", nextData, nil];
}

#pragma mark---处理最后一个长包的最后一个短包数据
- (void) handleLastDayPackage: (Byte *)bytes {
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    if (!effectiveLength) {
        effectiveLength = 17;
    }
    
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDayData];
    }
    
    [self sendBitControllTable];
}

@end


