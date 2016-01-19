//
//  HealthCheckModel.h
//  UBSForWatchDemo
//
//  Created by GaryChen on 19/10/15.
//  Copyright © 2015年 丘鼎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthCheckModel : NSObject

@property (copy,    nonatomic)      NSString *pertfolioNum;
@property (copy,    nonatomic)      NSString *message;
@property (copy,    nonatomic)      NSString *date;
@property (assign,  nonatomic)      NSInteger id;
@property (copy,    nonatomic)      NSString *hcCount;
@end
