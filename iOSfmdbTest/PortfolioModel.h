//
//  PortfolioModel.h
//  UBSForWatchDemo
//
//  Created by 丘鼎 on 10/19/15.
//  Copyright © 2015 丘鼎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioModel : NSObject
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *ptNum;
@property (strong, nonatomic) NSString *perf;
@property (strong, nonatomic) NSString *aum;
@property (strong, nonatomic) NSString *ccy;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSArray *chart_w;

@end
