//
//  NSString+HXAddtions.m
//  UBSForWatchDemo
//
//  Created by 丘鼎 on 10/12/15.
//  Copyright © 2015 丘鼎. All rights reserved.
//

#import "NSString+HXAddtions.h"
#import "ArticleModel.h"
@implementation  NSString (HXAddtions)

-(NSString*)myGetLocalDateFormateUTCDate {

    NSLog(@"self string: %@", self);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSZ"];
    
    NSDate * beginDate = [formatter dateFromString:self];
    
    [formatter setDateFormat:@"MMM dd hh:mm a"];
    NSString *dateString = [formatter stringFromDate:beginDate];
    NSLog(@"date: %@", dateString);
    
    return dateString;
}


//将UTC时间转换成本地时间字符串
-(NSString *)getLocalDateFormateUTCDate
{
    if (!self.length) {
        return @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:self];
    //输出格式
    [dateFormatter setDateFormat:@"dd MMM yyy"];
    
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}



- (NSString *)getLocalizedDateFormateUTCDate
{
    if (!self.length) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyy"];
    NSDate *dateFormatted = [dateFormatter dateFromString:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *language = [defaults objectForKey:@"appLanguage"];//取到当前app 的语言环境
    NSLocale *userLocale = [[NSLocale alloc] initWithLocaleIdentifier:language];
    if ([language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"zh-Hant"]) {
        [dateFormatter setDateFormat:@"yyyy年 MM月 dd日"];
    } else {
        [dateFormatter setDateFormat:@"dd MMM yyy"];
    }
    
    [dateFormatter setLocale:userLocale];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
            ];
}
+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [NSString jsonStringWithObject:valueObj];
        NSString *lastValue = [NSString stringWithFormat:@"\"%@\":%@",name,value];
        if (lastValue.length) {
            [keyValues addObject:lastValue];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [NSString jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [NSString jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [NSString jsonStringWithArray:object];
    }
    return value;
}

@end

@implementation NSMutableDictionary (DataAdditions)

+(NSMutableDictionary *)jsonDicLoadFromDefaultPath{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *jsonPath = [path stringByAppendingPathComponent:@"Notification-mock.json"];
    NSError *error = nil;
    NSString *jsonStr = nil;
    jsonStr = [NSString stringWithContentsOfFile:jsonPath encoding:NSASCIIStringEncoding error:&error];
    if (error) {
        NSLog(@"read failed:%@", [error localizedDescription]);
        jsonStr = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:&error];
    }
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = nil;
    if (data) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    }
    if (error) {
        NSLog(@"json parse failed:%@", [error localizedDescription]);
    }
    return dic;
}

-(BOOL)jsonDicWriteToFileWithDictionary{
    NSString *lastStr = [NSString jsonStringWithDictionary:self];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *jsonPath = [path stringByAppendingPathComponent:@"Notification-mock.json"];
    NSError *error = nil;
    [lastStr writeToFile:jsonPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return NO;
    }
    else{
        return YES;
    }
}

@end

@implementation NSMutableArray (SourceAdditions)

//sort article
- (void)sortArticleWithArr:(NSMutableArray*)articleArr
{
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
//    NSSortDescriptor *titleDesc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *descs = [NSArray arrayWithObjects:dateDesc,nil];
    [articleArr sortUsingDescriptors:descs];
}

//将utc时间转换成时间戳
- (long long)generateStampWithUTCDate:(NSString *)utcDate
{
    long long  timeIntervel;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    timeIntervel = (long long)[dateFormatted timeIntervalSince1970];
    return timeIntervel;
}

//filter article data
- (NSMutableArray*)filterArticleWithArticleCount:(NSInteger)count days:(NSInteger)days
{
    NSMutableArray *resultArr = [NSMutableArray array];
    NSDate *currentDate = [NSDate date];
    //当前时间的时间戳
    long long currentStamp = (long long)[currentDate timeIntervalSince1970];
    float tempStamp = days*24*3600;
    //指定时间的时间戳
    long long specifyStamp = currentStamp - tempStamp;
    NSLog(@"specifyStamp:%lld",specifyStamp);
    NSDate *specifyDate = [NSDate dateWithTimeIntervalSince1970:specifyStamp];
    NSLog(@"specifyDate:%@",specifyDate);
    for (int i = 0; i < self.count; i ++) {
        NSMutableDictionary *dic =[self objectAtIndex:i];
        NSString *date = [dic objectForKey:@"publicationDateTime"];
        NSString *newDate = [self timeFormatToUTCWithTime:date];
        long long stamp = [self generateStampWithUTCDate:newDate];
        if (!newDate.length) {
            [resultArr addObject:dic];
        }
        else{
            if ((stamp >= specifyStamp && stamp <= currentStamp) || stamp == 0) {
                [resultArr addObject:dic];
            }
        }
    }
//    [self sortArticleWithArr:resultArr];
    if (resultArr.count > count) {
        [resultArr removeObjectsInRange:NSMakeRange(count, resultArr.count - count)];
    }
    return resultArr;
}

-(NSString *)timeFormatToUTCWithTime:(NSString *)time{
    if (!time) {
        return nil;
    }
    else{
        NSMutableString *newTime = [NSMutableString stringWithString:time];
        NSRange TRange = [newTime rangeOfString:@"T"];
        NSRange ZRange = [newTime rangeOfString:@"Z"];
        if (TRange.length) {
            [newTime replaceCharactersInRange:TRange withString:@" "];
        }
        if (ZRange.length) {
            [newTime replaceCharactersInRange:ZRange withString:@" UTC+8"];
        }
        NSString *newStr = [NSString stringWithFormat:@"%@", newTime];
        return newStr;
    }
}

@end
