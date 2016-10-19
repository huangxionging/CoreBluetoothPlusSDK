//
//  CBPSynchonizeSleepAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLSynchronizeSleepAction.h"
#import "CBPHexStringManager.h"
#import "NSDate+CBPUtilityTool.h"
#import "CBPDispatchMessageManager.h"
@interface CBPWKLSynchronizeSleepAction () {
    /**
     *  位域控制表
     */
    
    Byte _bitControlTable[15];
    
    /**
     *  短包数
     */
    Byte _shortPackage[120][17];
    
    // 一天的数据
    NSMutableDictionary *_oneDayDataDict;
    
    //一天的分时睡眠数据
    NSMutableArray *_oneDaySleepDataArray;
}

/**
 *  计步数据的总天数, 同时表示长包的个数
 */
@property (nonatomic, assign) NSInteger dayCount;

/**
 *  计步数据
 */
@property (nonatomic, strong) NSMutableDictionary *sleepDataDiction;

/**
 *  单个长包数据
 */
@property (nonatomic, strong) NSMutableData *longPackageData;

/**
 *  长包计数, 也即长包序号
 */
@property (nonatomic, assign) NSInteger longPackageSerialNumber;

/**
 *  一个长包有效数据个数
 */
@property (nonatomic, assign) NSInteger effectiveDataCount;

/**
 *  一个长包包装成短包个数
 */
@property (nonatomic, assign) NSInteger shortPackageTotalCount;

/**
 * 短包序号计数
 */
@property (nonatomic, assign) NSInteger shortPackageSerialNumber;


/**
 *  指示日期
 */
@property (nonatomic, copy) NSString *indicatorDate;

/**
 *  一天的总睡眠时间
 */
@property (nonatomic, copy) NSString *oneDayTotalSleeps;

/**
 * 包含所有长包数据
 */
@property (nonatomic, strong) NSMutableArray *allDaySleepData;

@end

@implementation CBPWKLSynchronizeSleepAction
+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x07", @"0x05", @"0x06", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys 同步睡眠
    NSArray *interfaces = @[@"synchronize_sleep_data"];
    // 返回接口
    return interfaces;
}


- (void) actionData {
    NSDictionary *dict = [self valueForKey: @"parameter"];
    
    NSString *startDate = dict[@"start_date"];
    
    NSString *endDate = dict[@"end_date"];
    Byte bytes[20] = {0};
    bytes[0] = 0x5a;
    bytes[1] = 0x07;
    
    if ([endDate isEqualToString: @"0"]) {
        // 算法问题, 年份 - 2000, 表示两千年以后的年份
        // 开始日期
        bytes[3] = 0;
        bytes[4] = 0;
        bytes[5] = 0;
        // 结束日期
        bytes[6] = 0;
        bytes[7] = 0;
        bytes[8] = 0;
    }
    else {
        
        NSDate *start = [NSDate dateWithFormatString: @"yyyy-MM-dd" andWithDateString: startDate];
        
        NSDate *end = [NSDate dateWithFormatString: @"yyyy-MM-dd" andWithDateString: endDate];
        
        // 算法问题, 年份 - 2000, 表示两千年以后的年份
        // 开始日期
        bytes[3] = [start yearOfGregorian]  - 2000;
        bytes[4] = [start monthOfYear];
        bytes[5] = [start dayOfMonth];
        
        // 结束日期
        bytes[6] = [end yearOfGregorian]  - 2000 ;
        bytes[7] = [end monthOfYear];
        bytes[8] = [end dayOfMonth];
    }
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
}


- (NSMutableArray *)allDaySleepData {
    if (_allDaySleepData == nil) {
        _allDaySleepData = [NSMutableArray arrayWithCapacity: 10];
    }
    return _allDaySleepData;
}

- (NSMutableDictionary *)sleepDataDiction {
    if (_sleepDataDiction == nil) {
        _sleepDataDiction = [NSMutableDictionary dictionaryWithCapacity: 10];
    }
    return _sleepDataDiction;
}
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 第一步处理 指令的第一个回复数据
        if (bytes[0] == 0x5b && bytes[1] == 0x07) {
            [self handleFirstAnswer: (Byte *) bytes];
            return;
        }
        
        // 第二步, 设备开始主动发长包数据
        if (bytes[0] == 0x5a && bytes[1] == 0x05) {
            
            if (bytes[2] == 0x01) {
                // 处理每个长包的第一条数据
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
                [self handleNextDayDataPackage];
            }
        }
        
        
    }
    
    
}

#pragma mark- 处理第一个数据
- (void) handleFirstAnswer: (Byte *) bytes {
    // 总长包的个数
    self.dayCount = bytes[3] * 256 + bytes[4];
    
    NSLog(@"总天数%@", @(self.dayCount));
    NSString *totalCount = [NSString stringWithFormat: @"%ld", (long)self.dayCount];
    
    if (self.dayCount == 0) {
        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeInvalidData info: @"没有有效数据"];
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
        return;
    }
    // 清空数据
    [self.sleepDataDiction removeAllObjects];
    [self.allDaySleepData removeAllObjects];
    
    [self.sleepDataDiction setObject: totalCount forKey: @"total_count"];
    
    if (bytes[5] == 0x00) {
        NSLog(@"后续字段无效");
    } else if ((bytes[5] & 0x01)  == 0x01) {
        NSLog(@"数据有效");
        // 总步数
        NSInteger steps = bytes[6] * 256 + bytes[7];
        
        NSLog(@"最后一天睡眠时长%@", @(steps));
    }
}

#pragma mark- 处理每个长包的第一个短包数据
- (void) handleShortPackageActionAnswer: (Byte *) bytes {
    
    _oneDayDataDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    _oneDaySleepDataArray = [NSMutableArray arrayWithCapacity: 10];
    
    // cmd 控制位 必须是睡眠指令
    if (!(bytes[9] == 0x07)) {
        return;
    }
    // 有效数据个数, 包长度
    self.effectiveDataCount = bytes[3] * 256 + bytes[4];
    
    // 记录长包数据
    if (_longPackageData == nil) {
        _longPackageData = [NSMutableData data];
    }
    
    // 清空
    _longPackageData.length = 0;
    
    // 短包计数
    _shortPackageSerialNumber = bytes[2];
    
    // 短包个数
    _shortPackageTotalCount = self.effectiveDataCount / 17 + ((self.effectiveDataCount % 17) ? 1 : 0);
    
    // 记录长包序号
    _longPackageSerialNumber = bytes[5] * 256 + bytes[6];
    
    // 第一个分包位域控制, 以下三种算法都 ok, 采用取反的方法 ! 不行
    //_bitControlTable[(_shortPackageSerialNumber - 1) / 8] &= 0xff - (1<< ((_shortPackageSerialNumber - 1) % 8));
    
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageSerialNumber - 1) / 8] &= 0xff^(1<<(_shortPackageSerialNumber - 1) % 8);
    
    // 最后一包所在位域
    NSInteger bitIndex = _shortPackageTotalCount % 8 + 1;
    for (NSInteger index = bitIndex; index < 8; ++index) {
        _bitControlTable[(_shortPackageTotalCount) / 8] &= 0xff^(1<<index);
    }
    
    // 0xff - pow(2, (_shortPackageSerialNumber - 1) / 8))
    
    // 位域控制
    for (NSInteger index = (_shortPackageTotalCount) / 8 + 1; index < 15; ++index) {
        _bitControlTable[index] = 0x00;
    }
    
    // 年月日
    NSInteger year = bytes[10] + 2000;
    NSInteger month = bytes[11];
    NSInteger day = bytes[12];
    
    // 当前指示日期
    _indicatorDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)year, (long)month, (long)day];
    
    // 日期
    [_oneDayDataDict setObject: _indicatorDate forKey: @"date"];
    memset(_shortPackage, '\0', sizeof(_shortPackage));
    
    // 条数
    NSInteger  sleepCount = bytes[13];
    
    // 条数
    NSString *count = [NSString stringWithFormat: @"%ld", (long) sleepCount];
    [_oneDayDataDict setObject: count forKey: @"count"];
}

#pragma mark- 处理有效短包
- (void) handleShortPackageEffectiveAnswer: (Byte *) bytes {
    
    if (self.dayCount == 1) {
        // 进度
        NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
        double progressValue = self.shortPackageSerialNumber / (double)self.shortPackageTotalCount;
        // 取 4 位小数
        NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
        // 进度
        [progressData setObject: progress forKey: @"progress"];
        // 调度进度
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", progressData, nil];
    }

    // 屏蔽掉不合理数据
    if (bytes[2] < 0x02 || bytes[2] >= 0xfe) {
        return;
    }
    
    // 获取短包序号 是从 0x02 开始
    _shortPackageSerialNumber = bytes[2];
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageSerialNumber - 1) / 8] &= 0xff^(1<<((_shortPackageSerialNumber - 1) % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 获取短包序号 是从 0x02 开始, 所以要减去 2
    memcpy(_shortPackage[_shortPackageSerialNumber - 2], effectiveByte, sizeof(Byte) * 17);
}

#pragma mark- 处理非最后长包的长包的最后一个短包
- (void) handleShortPackageLastAnswer: (Byte *) bytes {
    
    // 过滤数据
    if (bytes[2] != 0xfe) {
        return;
    }
    _shortPackageSerialNumber = _shortPackageTotalCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageSerialNumber / 8] &= 0xff^(1<< (_shortPackageSerialNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    // 最后一个数据位
    memcpy(_shortPackage[_shortPackageSerialNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDaySleeps];
    }
    
    [self sendBitControllTable];
}

#pragma mark- 判断位域表
- (BOOL) shortPackageFinished {
    
    // 预先假设全部接收
    
    // 判断位域表是否全部为 0
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark- 处理一天的数据
- (void) handleOneDaySleeps {
    
    for (NSInteger index = 0; index < _shortPackageTotalCount; ++index) {
        
        if (index == _shortPackageTotalCount - 1) {
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
    
    NSLog(@"%@: 所有数据:%@ ====> %@", _indicatorDate, _longPackageData, @(_longPackageData.length));
    
    if (_longPackageData.length % 2 != 0) {
        //        CBPDEBUG;
        return;
    }
    
    // 获得数据
    Byte *bytes = (Byte *)[_longPackageData bytes];
    
    NSInteger sumSleep = 0;
    for (NSInteger index = 0; index < _longPackageData.length; index += 4) {
      
        NSMutableDictionary *diction = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        // 起始分钟
        NSInteger startMinute = bytes[index] * 256 + bytes[index + 1];
        NSString *startMinuteTime = [NSString stringWithFormat: @"%ld", (long)startMinute];
        [diction setObject: startMinuteTime forKey: @"start_minute"];
        
        // 睡眠时长
        NSInteger sleepTime = bytes[index + 2];
        NSString *sleep = [NSString stringWithFormat: @"%ld", (long)sleepTime];
        sumSleep += sleepTime;
        [diction setObject: sleep forKey: @"sleep_minute"];
        
        // 睡眠质量
        NSInteger flag = bytes[index + 3];
        NSString *sleepFlag = [NSString stringWithFormat: @"%ld", (long)flag];
        [diction setObject: sleepFlag forKey: @"sleep_flag"];
        
        // 添加睡眠
        [_oneDaySleepDataArray addObject: diction];
    }
    
    // 当天总步数
    NSString *sleepTotalTime = [NSString stringWithFormat: @"%ld", (long) sumSleep];
    [_oneDayDataDict setObject: sleepTotalTime forKey: @"sleep_total_time"];
    [_oneDayDataDict setObject: _oneDaySleepDataArray forKey: @"sleep_data"];
    
    // 添加一天的数据
    [self.allDaySleepData addObject: _oneDayDataDict];
}

#pragma mark- 发送位域控制表
- (void) sendBitControllTable {
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认位域表
    bytes[0] = 0x5b;
    bytes[1] = 0x05;
    bytes[3] = _longPackageSerialNumber / 256;
    bytes[4] = _longPackageSerialNumber % 256;
    
    Byte *bitControlTable = &bytes[5];
    memcpy(bitControlTable, _bitControlTable, sizeof(_bitControlTable) / sizeof(Byte));
    
    NSData *bitControlTableData = [NSData dataWithBytes: bytes length: 20];
    
    model.actionData = bitControlTableData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x05";
    // 回复数据
    id result = model;
    // 回调
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
}

#pragma mark- 处理请求下一天的数据
- (void) handleNextDayDataPackage {
    
    if (self.dayCount > 1) {
        // 进度
        NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
        double progressValue = self.longPackageSerialNumber / (double)self.dayCount;
        // 取 4 位小数
        NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
        // 进度
        [progressData setObject: progress forKey: @"progress"];
        // 调度进度
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", progressData, nil];
    } else if (self.dayCount == 1) {
        // 进度
        NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
        double progressValue = self.shortPackageSerialNumber / (double)self.shortPackageTotalCount;
        // 取 4 位小数
        NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
        // 进度
        [progressData setObject: progress forKey: @"progress"];
        // 调度进度
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", progressData, nil];
    }

    if (_longPackageSerialNumber == _dayCount || _dayCount == 1) {
        // 表示所有数据发送完成
        // 计步数据
        [self.sleepDataDiction setObject: self.allDaySleepData forKey: @"all_day_sleep_data"];
        
        // 回复数据
        //  完成
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", self.sleepDataDiction, nil];
        return;
    }
    
    memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
    
    // 请求下一个长包数据
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认长包
    bytes[0] = 0x5a;
    bytes[1] = 0x06;
    bytes[3] = _longPackageSerialNumber / 256;
    bytes[4] = _longPackageSerialNumber % 256;
    
    if (_longPackageSerialNumber == _dayCount || _dayCount == 1) {
        bytes[3] = 0xff;
        bytes[4] = 0xff;
    }
    
    // 下一个长包数据, 若无则无返回数据
    NSData *nextData = [NSData dataWithBytes: bytes length: 20];
    model.actionData = nextData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x06";
    // 回复数据
    id result = model;
    // 发送消息
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
}

#pragma mark- 最后一个长包的最后一包数据
- (void) handleLastDayPackage: (Byte *)bytes {
    
    // 有效数据放行
    if (bytes[2] != 0xff) {
        return;
    }
    _shortPackageSerialNumber = _shortPackageTotalCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageSerialNumber / 8] &= 0xff^(1<< (_shortPackageSerialNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    // 每天最后一包数据
    memcpy(_shortPackage[_shortPackageSerialNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDaySleeps];
    }
    
    [self sendBitControllTable];
}

- (void)timeOut {
    CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeSynchronizeDataTimeOut info: @"同步睡眠数据超时"];
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
}

@end
