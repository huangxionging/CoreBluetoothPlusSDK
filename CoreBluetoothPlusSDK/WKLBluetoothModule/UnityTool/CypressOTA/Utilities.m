/*
 * Copyright Cypress Semiconductor Corporation, 2014-2015 All rights reserved.
 *
 * This software, associated documentation and materials ("Software") is
 * owned by Cypress Semiconductor Corporation ("Cypress") and is
 * protected by and subject to worldwide patent protection (UnitedStates and foreign), United States copyright laws and international
 * treaty provisions. Therefore, unless otherwise specified in a separate license agreement between you and Cypress, this Software
 * must be treated like any other copyrighted material. Reproduction,
 * modification, translation, compilation, or representation of this
 * Software in any other form (e.g., paper, magnetic, optical, silicon)
 * is prohibited without Cypress's express written permission.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
 * NONINFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes
 * to the Software without notice. Cypress does not assume any liability
 * arising out of the application or use of Software or any product or
 * circuit described in the Software. Cypress does not authorize its
 * products for use as critical components in any products where a
 * malfunction or failure may reasonably be expected to result in
 * significant injury or death ("High Risk Product"). By including
 * Cypress's product in a High Risk Product, the manufacturer of such
 * system or application assumes all risk of such use and in doing so
 * indemnifies Cypress against all liability.
 *
 * Use of this Software may be limited by and subject to the applicable
 * Cypress software license agreement.
 *
 *
 */

#import "Utilities.h"

/*!
 *  @class Utilities
 *
 *  @discussion Class that contains common reusable methods
 *
 */

@implementation Utilities

/*!
 *  @method timeInFormat:
 *
 *  @discussion Method that converts seconds to minute:seconds format
 *
 */
+(NSString*)timeInFormat:(double)timeInterval
{
    int duration = (int)timeInterval; // cast timeInterval to int - note: some precision might be lost
    int minutes = duration / 60; //get the elapsed minutes
    int seconds = duration % 60; //get the elapsed seconds
    return  [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]; //create a string of the elapsed time in xx:xx format for example 01:15 as 1 minute 15 seconds
}

/*!
 *  @method getCurrentDate
 *
 *  @discussion Method that returns the current date
 *
 */
+(NSString *) getCurrentDate
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:DATE_FORMAT];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    return date;
}

/*!
 *  @method getCurrentTime
 *
 *  @discussion Method that returns the current time
 *
 */
+(NSString *) getCurrentTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:TIME_FORMAT];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    return date;
}

/*!
 *  @method alert: Message:
 *
 *  @discussion Method to show alert
 *
 */

+(void)alert:(NSString*)title Message:(NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: title message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction: [UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
//    [UIApplication sharedApplication].keyWindow presen
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:OK otherButtonTitles: nil];
//    [alert show];
}

/*!
 *  @method secondsToHour:
 *
 *  @discussion Method that converts seconds to hours
 *
 */

+(double)secondsToHour:(double)timeInterval
{
    if(timeInterval>0)
        return (timeInterval/3600.0f);
    return 0;
}

/*!
 *  @method secondsToMinute:
 *
 *  @discussion Method that converts seconds to minute
 *
 */
+(double)secondsToMinute:(double)timeInterval
{
    if(timeInterval>0)
        return (timeInterval/60.0f);
    return 0;
}

/*!
 *  @method meterToKM:
 *
 *  @discussion Method that converts meter to km
 *
 */
+(double)meterToKM:(double)meter
{
    if(meter>0)
        return meter/1000.0f;
    return 0;
}

/*!
 *  @method getDiscriptorNameForUUID:
 *
 *  @discussion Method that returns descriptor name for given UUID
 *
 */
+(NSString *)getDiscriptorNameForUUID:(CBUUID *)UUID
{
    NSString * descriptorName;
    if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTY_UUID]) {
        descriptorName = CHARACTERISTIC_EXTENDED_PROPERTIES;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION_UUID]) {
        descriptorName = CHARACTERISTIC_USER_DESCRIPTION;
    }else if ([UUID isEqual:DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorName = CLIENT_CHARACTERISTIC_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorName = SERVER_CHARACTERISTIC_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT_UUID]) {
        descriptorName = CHARACTERISTIC_PRESENTATION_FORMAT;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT_UUID]) {
        descriptorName = CHARACTERISTIC_AGGREGATE_FORMAT;
    }else if ([UUID isEqual:DESCRIPTOR_VALID_RANGE_UUID]) {
        descriptorName = VALID_RANGE;
    }else if ([UUID isEqual:DESCRIPTOR_EXTERNAL_REPORT_REFERENCE_UUID]) {
        descriptorName = EXTERNAL_REPORT_REFERENCE;
    }else if ([UUID isEqual:DESCRIPTOR_REPORT_REFERENCE_UUID]) {
        descriptorName = REPORT_REFERENCE;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_CONFIG_UUID]) {
        descriptorName = ENVIRONMENTAL_SENSING_CONFIG;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_MEASUREMENT_UUID]) {
        descriptorName = ENVIRONMENTAL_SENSING_MEASUREMENT;
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_TRIGGER_SETTING_UUID]) {
        descriptorName =ENVIRONMENTAL_SENSING_TRIGGER_SETTING;
    }
    return descriptorName;
}

/*!
 *  @method getDescriptorValueInformation: andValue:
 *
 *  @discussion Method that returns descriptorValueInformation for given UUID
 *
 */

+(NSString *)getDescriptorValueInformation:(CBUUID *)UUID andValue:(NSNumber *)value
{
    NSString * descriptorValueInformation;
    if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_EXTENDED_PROPERTY_UUID]) {
       
        switch ([value integerValue]){
            case 0:
                descriptorValueInformation = [NSString stringWithFormat:@"%@ \n%@",RELIABLE_WRITE_DISABLED,WRITABLE_AUXILARIES_DISABLED];
                break;
            case 1:
                descriptorValueInformation = RELIABLE_WRITE_ENABLED;
                break;
            case 2:
                descriptorValueInformation = WRITABLE_AUXILARIES_ENABLED;
                break;
                
            default:
                break;
        }
        
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_USER_DESCRIPTION_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_CLIENT_CHARACTERISTIC_CONFIG_UUID]){
       
        switch ([value integerValue]){
            case 0:
                descriptorValueInformation =[NSString stringWithFormat:@"%@ \n%@",INDICATE_DISABLED,NOTIFY_DISABLED];
                break;
            case 1:
                descriptorValueInformation = NOTIFY_ENABLED;
                break;
            case 2:
                descriptorValueInformation = INDICATE_ENABLED;
                break;
                
            default:
                break;
        }
    }else if ([UUID isEqual:DESCRIPTOR_SERVER_CHARACTERISTIC_CONFIG_UUID]) {
        descriptorValueInformation = value ? BROADCAST_ENABLED : BOADCAST_DISABLED;
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_PRESENTATION_FORMAT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_CHARACTERISTIC_AGGREGATE_FORMAT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_VALID_RANGE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_EXTERNAL_REPORT_REFERENCE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_REPORT_REFERENCE_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_CONFIG_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_MEASUREMENT_UUID]) {
        descriptorValueInformation = @"";
    }else if ([UUID isEqual:DESCRIPTOR_ENVIRONMENTAL_SENSING_TRIGGER_SETTING_UUID]) {
        descriptorValueInformation = @"";
    }
    return descriptorValueInformation;
}

/*!
 *  @method dataFromHexString:
 *
 *  @discussion Method to handle conversion of user entered hex value
 *
 */

+ (NSMutableData *)dataFromHexString:(NSString *)string
{
    NSMutableData *data = [NSMutableData new];
    NSCharacterSet *hexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF "] invertedSet];
    
    // Check whether the string is a valid hex string. Otherwise return empty data
    if ([string rangeOfCharacterFromSet:hexSet].location == NSNotFound) {
       
        string = [string lowercaseString];
        unsigned char whole_byte;
        char byte_chars[3] = {'\0','\0','\0'};
        int i = 0;
        int length = (int)string.length;
        
        while (i < length-1)
        {
            char c = [string characterAtIndex:i++];
            
            if (c < '0' || (c > '9' && c < 'a') || c > 'f')
                continue;
            byte_chars[0] = c;
            byte_chars[1] = [string characterAtIndex:i++];
            whole_byte = strtol(byte_chars, NULL, 16);
            [data appendBytes:&whole_byte length:1];
        }
    }
    return data;
}

/*!
 *  @method convertToHexFromASCII:
 *
 *  @discussion Method to convert ASCII string to hex
 *
 */
+ (NSString *) convertToHexFromASCII:(NSString *)ASCIIString{
    
    NSString *hexString = @"";
    
    NSData *data = [ASCIIString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *tempHexString = [[[[NSString stringWithFormat:@"%@",data] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    tempHexString = [tempHexString uppercaseString];
    for (int i=0; i<tempHexString.length; i+=2) {
        
        NSString *hexValue = [tempHexString substringWithRange:NSMakeRange(i, 2)];
        hexString = [hexString stringByAppendingString:[NSString stringWithFormat:@"0x%@ ",hexValue]];
    }
    
    return hexString;
    
}

/*!
 *  @method convertCharacteristicValueToASCII:
 *
 *  @discussion Method to handle ASCII conversion
 *
 */

+(NSString *)convertCharacteristicValueToASCII:(NSData *)data
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < data.length; i++)
    {
        unsigned char byte;
        [data getBytes:&byte range:NSMakeRange(i, 1)];
        
        if (byte >= 32 && byte < 127)
        {
            [string appendFormat:@"%c", byte];
        }
        
    }
    return string;
}



/*!
 *  @method captureScreenShot
 *
 *  @discussion Method to capture the currrent screen shot
 *
 */

+(UIImage *) captureScreenShot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    
    UIGraphicsBeginImageContext([UIApplication sharedApplication].keyWindow.bounds.size);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*!
 *  @method getIntegerFromHexString:
 *
 *  @discussion Method that returns the integer from hex string
 *
 */
+(unsigned int) getIntegerFromHexString:(NSString *)hexString
{
    unsigned int integerValue;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&integerValue];
    
    return integerValue;
}

/*!
 *  @method get128BitUUIDForUUID:
 *
 *  @discussion Method that returns the 128 bit UUID
 *
 */

+(NSString *)get128BitUUIDForUUID:(CBUUID *)UUID
{
    NSString *uuidString = [NSString stringWithFormat:@"0000%@-0000-1000-8000-00805F9B34FB",UUID.UUIDString];
    return [uuidString lowercaseString];
}

/*!
 *  @method convertDataToLoggerFormat:
 *
 *  @discussion Method that returns the data to logger forma string
 *
 */

+(NSString *) convertDataToLoggerFormat:(NSData *)data
{
    NSString *dataString = [NSString stringWithFormat:@"%@",data];
    dataString = [[[dataString stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *tempString = @"";
    
    if (dataString.length != 0)
    {
        int i = 0;
        for (; i < dataString.length-1; i++)
        {
            if ((i%2) != 0)
            {
                tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c ",[dataString characterAtIndex:i]]];
            }
            else
                tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c",[dataString characterAtIndex:i]]];
        }
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%c",[dataString characterAtIndex:i]]];

    }
    else
        tempString = @" ";
    
    NSString *logString = [NSString stringWithFormat:@"[%@]",tempString];
    return logString;
}

/*!
 *  @method logDataWithService: characteristic: descriptor: operation:
 *
 *  @discussion Method to log the data 
 *
 */

+(void) logDataWithService:(NSString *)serviceName characteristic:(NSString *)characteristicName descriptor:(NSString *)descriptorName operation:(NSString *)operationInfo
{
    if (descriptorName != nil)
    {
//        [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@|%@|%@] %@",serviceName,characteristicName,descriptorName,operationInfo]];
    }
    else
    {
//        [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@|%@] %@",serviceName,characteristicName,operationInfo]];
    }
    
}


/*!
 *  @method convertSFLOATFromData:
 *
 *  @discussion Method to convert the SFLOAT to simple float
 *
 */

+(float) convertSFLOATFromData:(int16_t)tempData{
    
    int16_t exponent = (tempData & 0xF000) >> 12;
    int16_t mantissa = (int16_t)(tempData & 0x0FFF);
    
    if (mantissa >= 0x0800)
        mantissa = -(0x1000 - mantissa);
    if (exponent >= 0x08)
        exponent = -(0x10 - exponent);
    
    float tempValue = (float)(mantissa*pow(10, exponent));
    return tempValue;
}

@end
