/*
 * Copyright Cypress Semiconductor Corporation, 2015 All rights reserved.
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

#import "OTAFileParser.h"
#import "Constants.h"
#import "Utilities.h"

#define FILE_HEADER_MAX_LENGTH      12
#define FILE_PARSER_ERROR_CODE      555

/*!
 *  @class OTAFileParser
 *
 *  @discussion Class to parse the bootloader file
 *
 */

@implementation OTAFileParser

/*!
 *  @method parseFirmwareFileWithName: andPath: onFinish:
 *
 *  @discussion Method for parsing the OTA firmware file
 *
 */

- (void) parseFirmwareFileWithName:(NSString *)fileName andPath:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary * header, NSArray * rowData, NSArray * rowIdArray, NSError * error))finish
{
    NSMutableDictionary * fileHeaderDict = [NSMutableDictionary new];
    NSMutableArray * firmwareFileDataArray = [NSMutableArray new];
    NSMutableArray * rowIdArray = [NSMutableArray new];
    NSError * error;
    
    NSString* fileContents = [NSString stringWithContentsOfFile:[NSString pathWithComponents:[NSArray arrayWithObjects:filePath,fileName, nil]]
                                                       encoding:NSUTF8StringEncoding error:nil];
    if (fileContents && fileContents.length > 0) {
        // Separate by new line
        NSMutableArray * fileContentsArray = (NSMutableArray *)[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (fileContentsArray) {
            
            fileContentsArray = [self removeEmptyRowsAndJunkDataFromArray:fileContentsArray];
            
            NSString * fileHeader = [fileContentsArray objectAtIndex:0];
            
            if (fileHeader.length >= FILE_HEADER_MAX_LENGTH) {
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(0, 8)] forKey:SILICON_ID];
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(8, 2)] forKey:SILICON_REV];
                [fileHeaderDict setObject:[fileHeader substringWithRange:NSMakeRange(10, 2)] forKey:CHECKSUM_TYPE];
                [fileContentsArray removeObjectAtIndex:0];
                
                //Parse the Row data
                
                NSString * rowID = @"";
                int rowCount = 0;
                NSMutableDictionary * rowIdDict = [NSMutableDictionary new];
                for (NSString * dataRowString in fileContentsArray) {
                    if (dataRowString.length > 20) {
                        
                        if ([self parseRowDataString:dataRowString] != nil) {
                            [firmwareFileDataArray addObject:[self parseRowDataString:dataRowString]];
                            
                            //Counting Rows in each RowID
                            if ([rowID  isEqual: @""]) {
                                rowID = [dataRowString substringWithRange:NSMakeRange(0, 2)];
                                rowCount++;
                            }else if ([rowID isEqual:[dataRowString substringWithRange:NSMakeRange(0, 2)]] ){
                                rowCount++;
                            }else{
                                [rowIdDict setValue:rowID forKey:ROW_ID];
                                [rowIdDict setValue:[NSNumber numberWithInt:rowCount] forKey:ROW_COUNT];
                                [rowIdArray addObject:(NSDictionary *)rowIdDict];
                                rowIdDict = [NSMutableDictionary new];
                                rowID = [dataRowString substringWithRange:NSMakeRange(0, 2)];
                                rowCount = 1;
                            }
                        }else{
                            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                            
                            finish(nil,nil,nil, error);
                        }
                        
                    }else{
                        error = [[NSError alloc] initWithDomain:FILE_FORMAT_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"dataFormatInvalid") forKey:NSLocalizedDescriptionKey]];
                        finish(nil,nil,nil, error);
                        break;
                    }
                }
                if (!error) {
                    //Counting Rows in each RowID. Adding last RowID count to Dict.
                    [rowIdDict setValue:rowID forKey:ROW_ID];
                    [rowIdDict setValue:[NSNumber numberWithInt:rowCount] forKey:ROW_COUNT];
                    [rowIdArray addObject:(NSDictionary *)rowIdDict];
                    
                    finish(fileHeaderDict, firmwareFileDataArray, rowIdArray, nil);
                }

            }else{
                error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"invalidFile") forKey:NSLocalizedDescriptionKey]];
                
                finish(nil,nil,nil, error);
            }
            
        }else{
            error = [[NSError alloc] initWithDomain:PARSING_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"parsingFailed") forKey:NSLocalizedDescriptionKey]];

            finish(nil,nil,nil, error);
        }
    }else{
        error = [[NSError alloc] initWithDomain:FILE_EMPTY_ERROR code:FILE_PARSER_ERROR_CODE userInfo:[NSDictionary dictionaryWithObject:LOCALIZEDSTRING(@"fileEmpty") forKey:NSLocalizedDescriptionKey]];
        finish(nil,nil,nil, error);
    }
    
}

/*!
 *  @method removeEmptyRowsAndJunkDataFromArray:
 *
 *  @discussion Method for empty rows and junk data from the parsed array of data
 *
 */
- (NSMutableArray *)removeEmptyRowsAndJunkDataFromArray:(NSMutableArray *)dataArray
{
    for (int i = 0; i < dataArray.count; ) {
        if ([[dataArray objectAtIndex:i] isEqualToString:@""]) {
            [dataArray removeObjectAtIndex:i];
        }else{
            NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
            NSString *trimmedReplacement = [[[dataArray objectAtIndex:i]componentsSeparatedByCharactersInSet:charactersToRemove]
                                            componentsJoinedByString:@""];
            [dataArray replaceObjectAtIndex:i withObject:trimmedReplacement];
            i++;
        }
    }
    return dataArray;
}

/*!
 *  @method parseRowDataString:
 *
 *  @discussion Method for parsing each row of data in the firmware file.
 *
 */
- (NSMutableDictionary *)parseRowDataString:(NSString *)rowData
{
    NSMutableDictionary * rowDataDict = [NSMutableDictionary new];
    
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(0, 2)] forKey:ARRAY_ID];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(2, 4)] forKey:ROW_NUMBER];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(6, 4)] forKey:DATA_LENGTH];
    
    NSString * dataString = [rowData substringWithRange:NSMakeRange(10, rowData.length - 12)];
    
    if ([Utilities getIntegerFromHexString:[rowDataDict objectForKey:DATA_LENGTH]] != dataString.length/2 ) {
        return nil;
    }
    
    NSMutableArray * byteArray = [NSMutableArray new];
    for (int i = 0; i+2 <= dataString.length; i += 2) {
        [byteArray addObject:[dataString substringWithRange:NSMakeRange(i, 2)]];
    }
    
    [rowDataDict setValue:byteArray forKey:DATA_ARRAY];
    [rowDataDict setValue:[rowData substringWithRange:NSMakeRange(rowData.length - 2, 2)] forKey:CHECKSUM_OTA];
    return rowDataDict;
}

@end
