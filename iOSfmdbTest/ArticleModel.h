//
//  ArticleModel.h
//  UBS_SprintDemo
//
//  Created by RanRan on 15/10/7.
//  Copyright © 2015年 Gary_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleModel : NSObject
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *articleId;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *teaser;
@property (copy, nonatomic)NSString *date;
@property (assign, nonatomic)BOOL isRead;

@end
