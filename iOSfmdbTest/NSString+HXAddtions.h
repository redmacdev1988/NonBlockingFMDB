//
//  NSString+HXAddtions.h
//  UBSForWatchDemo
//
//  Created by 丘鼎 on 10/12/15.
//  Copyright © 2015 丘鼎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXAddtions)

-(NSString*)myGetLocalDateFormateUTCDate;

-(NSString *)getLocalDateFormateUTCDate;

-(NSString *)getLocalizedDateFormateUTCDate;


+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;

+(NSString *) jsonStringWithArray:(NSArray *)array;

+(NSString *) jsonStringWithString:(NSString *) string;

+(NSString *) jsonStringWithObject:(id) object;

@end

@interface NSMutableDictionary (DataAdditions)

+(NSMutableDictionary *)jsonDicLoadFromDefaultPath;

-(BOOL)jsonDicWriteToFileWithDictionary;

@end

@interface NSMutableArray (SourceAdditions)

- (NSMutableArray*)filterArticleWithArticleCount:(NSInteger)count days:(NSInteger)days;

@end