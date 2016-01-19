//
//  DatabaseFunctions.h
//  UBSForWatchDemo
//
//  Created by RanRan on 15/10/13.
//  Copyright © 2015年 丘鼎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

typedef enum : NSUInteger {
    DataSelectionPortfolio = 1,     //data for portfolio
    DataSelectionArticles,          //data for articles
    DataSelectionHealthCheck,       //data for healthCheck
    
} DataSelection;


@interface DatabaseFunctions : NSObject
{
    
}

//Singleton
+ (id)sharedDatabaseFunctions;


//Life Cycle
-(instancetype)init;
-(void)resetDB;



//ARTICLE //

-(void)getArticles:(void (^)(NSArray*)) finish;

-(void)insertArticleWithID:(NSString*)articleId
                 withTitle:(NSString*)title
                    teaser:(NSString*)teaser
                   andTime:(NSString*)time
                  onFinish:(void (^)(BOOL, NSString * )) finish;

-(void)updateIsReadForArticleId:(NSString *)articleId
                       onFinish:(void (^)(BOOL, NSString * )) updated;


-(void)deleteArticleWithId:(NSString*)articleID
                  onFinish:(void (^)(BOOL, NSString * )) finish;




//PORTFOLIO //

-(void)insertPortfolioWithPfNum:(NSString*)portfolioNum
                    performance:(NSString*)performance
                            aum:(NSString*)aum
                            ccy:(NSString*)currency
                chartJSONString:(NSString*)json
                        andTime:(NSString*)time
                       onFinish:(void (^)(BOOL, NSString *)) finish;

-(void)deletePorfolioWithPtNum:(NSString*)ptNum
                      onFinish:(void (^)(BOOL, NSString *)) finish;

-(void)deleteAllPortfoliosFromDB: (void (^)(BOOL)) deleted;

-(void)getPortfolios:(void (^)(NSArray*)) finish;


//HEALTH CHECK //


- (void)getHealthChecks:(void (^)(NSArray*)) finish ;


-(void)insertHealthCheckWithIdNum:(NSString*)idNum
                            ptNum:(NSString*)ptNum
                          message:(NSString*)message
                             date:(NSString*)date
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish;


-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                             date:(NSString*)date
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish;


-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish;


-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                          andDate:(NSString*)date
                         onFinish:(void (^)(BOOL, NSString *)) finish;


-(void)deleteHealthCheckWithID:(NSString*)healthCheckID
                      onFinish:(void (^)(BOOL, NSString *)) finish;

-(void)deleteAllHealthChecksFromDB:(void (^)(BOOL)) finish ;



// STATE //

- (NSString *) getStateUpdatedDate;


/*
//delete later
- (NSMutableArray *)queryData:(DataSelection)dataTable;

- (BOOL)modifyData:(NSString *)articleId;

- (BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)database;

- (BOOL) touchDB;

- (BOOL) resetDB;

- (NSString *) getCurrDate;
*/


@end
