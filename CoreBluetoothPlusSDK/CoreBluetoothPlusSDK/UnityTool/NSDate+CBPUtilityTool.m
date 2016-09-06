//
//  NSDate+CBPUtilityTool.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/4/22.
//  Copyright (c) 2015年 New_Life. All rights reserved.
//

#import "NSDate+CBPUtilityTool.h"

@implementation NSDate (CBPUtilityTool)
#pragma mark---计算当前日期是周几
- (NSInteger) dayOfWeek {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitWeekday;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    // 转换一下
    return (componets.weekday + 5) % 7 + 1;
}

#pragma mark---计算当前日期在月多少天
- (NSInteger)dayOfMonth {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitDay;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    // 转换一下
    return componets.day;
}


#pragma mark---计算当前日期在本季度多少天
- (NSInteger) dayOfQuarter {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    NSInteger month = componets.month;
    
    NSInteger quarter = (month + 2) / 3;
    
    NSInteger startMonth = quarter * 3 - 2;
    
    // 设置该季度的第一天
    [componets setMonth: startMonth];
    [componets setDay: 1];
    
    // 得到本季度第一天的日期
    NSDate *startDate = [calendar dateFromComponents: componets];
    
    // 计算两个日期的差
    NSTimeInterval timeInterval = [self timeIntervalSinceDate: startDate];
    
    // 得到时间
    return (NSInteger)(timeInterval / 24 / 3600) + 1;
}

#pragma mark---yearOf
- (NSInteger) yearOfGregorian {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitYear;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    // 转换一下
    return componets.year;
}


#pragma mark---计算当前日期在本年度第多少天
- (NSInteger) dayOfYear {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    // 设置 1月1号
    [componets setMonth: 1];
    [componets setDay: 1];
    
    // 得到本季度第一天的日期
    NSDate *startDate = [calendar dateFromComponents: componets];
    
    // 计算两个日期的差
    NSTimeInterval timeInterval = [self timeIntervalSinceDate: startDate];
    
    // 得到时间
    return (NSInteger)(timeInterval / 24 / 3600) + 1;
}


- (NSInteger) weekOfMonth {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitWeekOfMonth;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    return componets.weekOfMonth;
}

#pragma mark---本季度第多少周
- (NSInteger) weekOfQuarter {
    
    NSInteger dayOfQuarter = [self dayOfQuarter] - 1;
    
    // 本季度第一天是周几
    NSInteger startWeek = [[self dateByAddingNumberDay: -dayOfQuarter] dayOfWeek];
    
    // 今天是周几
    NSInteger currentWeek = [self dayOfWeek];
    
    return (dayOfQuarter + startWeek + 7 - currentWeek) / 7;
}

- (NSInteger) weekOfYear {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitWeekOfYear;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    return componets.weekOfYear;
}

- (NSInteger) monthOfYear {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitMonth;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    return componets.month;
}

- (NSInteger) quarterOfYear {
    // 获取公历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取周
    NSInteger flag = NSCalendarUnitQuarter | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    return (componets.month + 2) / 3;
}

#pragma mark---计算与当前时间间隔多少天的日期
- (NSDate *) dateByAddingNumberDay: (NSInteger) numberDay {
    // 获取时间差
    NSTimeInterval time = numberDay * 24 * 60 * 60;
    // 计算时间
    return [NSDate dateWithTimeInterval: time sinceDate: self];
}

#pragma mark- 时
- (NSInteger)hour {
    NSString *hourString = [self stringForCurrentDateWithFormatString: @"hh"];
    return hourString.integerValue;
}

#pragma mark- 分
- (NSInteger)minute {
    NSString *minuteString = [self stringForCurrentDateWithFormatString: @"mm"];
    return minuteString.integerValue;
}

#pragma mark- 秒
- (NSInteger)second {
    NSString *secondString = [self stringForCurrentDateWithFormatString: @"ss"];
    return secondString.integerValue;
}

#pragma mark---将当前日期转换为字符串
- (NSString *)stringForCurrentDateWithFormatString:(NSString *)formatString {
    // 日期格式器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (formatString) {
        // formatString 存在
        [formatter setDateFormat: formatString];
    }
    else {
        // 默认格式
        [formatter setDateFormat: @"yyyyMMdd"];
    }
    
    return [formatter stringFromDate: self];
}

#pragma mark---计算当前日期所在月份的第一天
- (NSDate *) firstDateOfCurrntMonth {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取年月日
    NSInteger flag = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    // 设定1号
    [componets setDay: 1];
    
    return [calendar dateFromComponents: componets];
    
}

#pragma mark---计算当前日期所在月份的最后一天
- (NSDate *) lastDateOfCurrntMonth {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 提取年月日
    NSInteger flag = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;
    
    // 日期组件
    NSDateComponents *componets = [calendar components: flag fromDate: self];
    
    NSInteger month = componets.month;
    
    if (month != 12) {
        
        // 设定下个月份
        [componets setMonth: month + 1];
        
        // 设定 1号
        [componets setDay: 1];
        
        // 然后往前推一天
        NSDate *startDate = [calendar dateFromComponents: componets];
        return [startDate dateByAddingNumberDay: -1];
    }
    else {
        // 如果是12月, 直接计算为
        [componets setDay: 31];
        return [calendar dateFromComponents: componets];
    }
    
}

#pragma mark---获取指定年份和指定月份的第一天
+ (NSDate *) firstDateByMonth: (NSUInteger) month andByYear: (NSInteger) year {
    
    // 日历
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    // 组件
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = 1;
    
    return [calendar dateFromComponents: dateComponents];
}

#pragma mark---获取指定年份和指定月份的最后一天
+ (NSDate *) lastDateByMonth: (NSUInteger) month andByYear: (NSInteger) year{
    
    // 先获取第一天, 然后利用之前写好的 API 快速的给出最后一天的日期
    return [[NSDate firstDateByMonth: month andByYear: year] lastDateOfCurrntMonth];
}

#pragma mark---获取指定年份和指定季度的第一天
+ (NSDate *)firstDateByQuarter:(NSUInteger)quarter andByYear:(NSInteger)year {
    NSInteger month = (quarter - 1) * 3 + 1;
    return [NSDate firstDateByMonth: month andByYear: year];
}

#pragma mark---获取指定年份和指定季度的最后一天
+ (instancetype)lastDateByQuarter:(NSUInteger)quarter andByYear:(NSInteger)year {
    NSInteger month = quarter * 3;
    return [NSDate lastDateByMonth: month andByYear: year];
}

+ (instancetype) firstDateByYear: (NSInteger) year {
    return [NSDate firstDateByMonth: 1 andByYear: year];
}

+ (instancetype) lastDateByYear: (NSInteger) year {
    return [NSDate lastDateByMonth: 12 andByYear: year];
}

#pragma mark---通过指定字符串创建
+ (instancetype)dateWithFormatString:(NSString *)formatString andWithDateString:(NSString *)dateString {
    
    // 日期格式器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (formatString) {
        // formatString 存在
        [formatter setDateFormat: formatString];
    }
    else {
        // 默认格式
        [formatter setDateFormat: @"yyyyMMdd"];
    }
    
    return [formatter dateFromString: dateString];
}

- (NSInteger)dayofIntervalToDate:(NSDate *)ortherDate {
    
    // 获取
    NSString * dateString = [ortherDate stringForCurrentDateWithFormatString: @"yyyyMMdd"];
    
    NSDate *currentDate = [NSDate dateWithFormatString: @"yyyyMMdd" andWithDateString: dateString];
    
    NSInteger interval = [currentDate timeIntervalSinceDate: self] / 24 / 3600;
    
    
    NSDate *date = [self dateByAddingNumberDay: interval];
    
    // 合法
    if ([date isEqualToDate: currentDate]) {
        return interval;
    } else {
        return MAXFLOAT;
    }
}

@end
