//
//  NSDate+CBPUtilityTool.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/4/22.
//  Copyright (c) 2015年 New_Life. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CBPUtilityTool)

/**
 *  @brief: 判断当前日期是星期几, 1-7 表示周一到周日
 *  @param: 无
 *  @return: NSInteger 类型, 表示当前日期是周几
 */
- (NSInteger) dayOfWeek;

/**
 *  @brief: 判断当前日期是当月的天
 *  @param: 无
 *  @return: NSInteger 类型, 表示当前日期是周几
 */
- (NSInteger) dayOfMonth;


/**
 *  @brief: 判断当前日期是本季度第多少天
 *  @param: 无
 *  @return: NSInteger 类型
 */
- (NSInteger) dayOfQuarter;

/**
 *  @brief: 判断当前日期是本年度第多少天
 *  @param: 无
 *  @return: NSInteger 类型
 */
- (NSInteger) dayOfYear;

/**
 *  @brief: 判断当前周是本月第多少周
 *  @param: 无
 *  @return: NSInteger 类型
 */
- (NSInteger) weekOfMonth;

/**
 *  @brief: 判断当前周是本季度第多少周
 *  @param: 无
 *  @return: NSInteger 类型
 */
- (NSInteger) weekOfQuarter;

/**
 *  @brief: 判断当前周是本年度第多少周
 *  @param: 无
 *  @return: NSInteger 类型
 */
- (NSInteger) weekOfYear;

/**
 *  @brief: 判断当前月份
 *  @param: 无
 *  @return:NSInteger 类型
 */
- (NSInteger) monthOfYear;

/**
 *  @brief: 判断当前年份
 *  @param: 无
 *  @return:NSInteger 类型
 */
- (NSInteger) yearOfGregorian;

/**
 *  @author huangxiong
 *
 *  @brief 24 小时制, 时
 *
 *  @return
 */
- (NSInteger) hour;

/**
 *  @author huangxiong
 *
 *  @brief 分钟
 *
 *  @return 分钟
 */
- (NSInteger) minute;

/**
 *  @author huangxiong
 *
 *  @brief 秒
 *
 *  @return 秒
 */
- (NSInteger) second;

/**
 *  @brief: 获取本月的最后一天
 *  @param: 无
 *  @return: NSDate 类型
 */
- (NSDate *) lastDateOfCurrntMonth;

/**
 *  @brief: 获取本月的第一天
 *  @param: 无
 *  @return: NSDate 类型
 */
- (NSDate *) firstDateOfCurrntMonth;

/**
 *  @brief: 计算离现在日期相隔多少天的日期
 *  @param: numberDay 是整数表示与当前日期的间隔, 负数往前数, 正数往后数
 *  @return: 对应的日期
 */
- (NSDate *) dateByAddingNumberDay: (NSInteger) numberDay;

/**
 *  @brief: 将日期转换成相应格式的字符串
 *  @param: formatString 是格式字符串, 需遵循 NSDateFormatter 支持的格式
 *  @return: NSString 类型, 是格式化后的字符串
 *  @default: 默认格式 为 yyyyMMDD 例如 20150422
 */
- (NSString *) stringForCurrentDateWithFormatString: (NSString *)formatString;

/**
 *  @brief: 计算指定年月的第一天
 *  @param: month 是指定的月份, year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) firstDateByMonth: (NSUInteger) month andByYear: (NSInteger) year;

/**
 *  @brief: 计算指定年月的最后天
 *  @param: month 是指定的月份, year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) lastDateByMonth: (NSUInteger) month andByYear: (NSInteger) year;

/**
 *  @brief: 计算指定年份和季度的第一天
 *  @param:  quarter 是指定的季度, year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) firstDateByQuarter: (NSUInteger) quarter andByYear: (NSInteger) year;


/**
 *  @brief: 计算指定年份季度的最后天
 *  @param: quarter 是指定的季度, year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) lastDateByQuarter: (NSUInteger) quarter andByYear: (NSInteger) year;

/**
 *  @brief: 计算指定年份的第一天
 *  @param:  year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) firstDateByYear: (NSInteger) year;

/**
 *  @brief: 计算指定年份的最后一天
 *  @param:  year 是指定的年份
 *  @return:日期
 */
+ (NSDate *) lastDateByYear: (NSInteger) year;

/**
 *  @brief: 通过指定格式的字符串创建日期
 *  @param:  formatString 是格式字符串, 为 nil 时格式为 yyyyMMdd; dateString是源日期字符串
 *  @return:日期
 */
+ (instancetype)dateWithFormatString:(NSString *)formatString andWithDateString:(NSString *)dateString;
/**
 *  计算日期之间的间隔
 */
- (NSInteger)dayofIntervalToDate:(NSDate *)ortherDate;

@end
