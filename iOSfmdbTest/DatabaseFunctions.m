//
//  DatabaseFunctions.m
//  UBSForWatchDemo
//
//  Created by RanRan on 15/10/13.
//  Copyright © 2015年 丘鼎. All rights reserved.
//

#import "DatabaseFunctions.h"
#import "PortfolioModel.h"
#import "ArticleModel.h"
#import "HealthCheckModel.h"
#import "NSString+HXAddtions.h"
//#import "PrefixHeader.pch"


#define DATABASE_FILE_NAME                      @"MyDatabase.db"

#define CREATE_TABLE_ARTICLES                   @"CREATE TABLE IF NOT EXISTS Articles (type text, id text PRIMARY KEY, title text, teaser text, date text, isRead text)"
#define CREATE_TABLE_PORTFOLIOS                 @"CREATE TABLE IF NOT EXISTS Portfolios (type text, ptNum text, perf text, aum text, ccy text, chart_w text, date text)"
#define CREATE_TABLE_HEALTHCHECKS               @"CREATE TABLE IF NOT EXISTS HealthChecks (id integer PRIMARY KEY, ptNum text, message text, date text,hcCount text)"
#define CREATE_TABLE_STATE                      @"CREATE TABLE IF NOT EXISTS State (updatedate text)"


#define SELECT_ALL_FROM_ARTICLES                @"SELECT * FROM Articles"
#define SELECT_ALL_FROM_PORTFOLIOS              @"SELECT * FROM Portfolios"
#define SELECT_ALL_FROM_HEALTHCHECKS            @"SELECT * FROM HealthChecks"
#define SELECT_LATEST_STATE                     @"SELECT * from State LIMIT 1"


#define DELETE_ALL_ARTICLES                     @"DELETE FROM Articles"
#define DELETE_ALL_HEALTHCHECKS                 @"DELETE FROM HealthChecks"
#define DELETE_ALL_PORTFOLIOS                   @"DELETE FROM Portfolios"

#define INSERT_INTO_ARTICLES                    @"INSERT INTO Articles (type, id, title, teaser, date, isRead) VALUES (?, ?, ?, ?, ?, ?)"
#define INSERT_INTO_PORTFOLIOS                  @"INSERT INTO Portfolios (type, ptNum, perf, aum, ccy, chart_w, date) VALUES (?, ?, ?, ?, ?, ?, ?)"
#define INSERT_INTO_STATE                       @"INSERT INTO State (updatedate) values (?)"



#define DELETE_FROM_ARTCILES_WHERE_ARTICLEID    @"DELETE FROM Articles WHERE id=?"
#define DELETE_FROM_PORTFOLIOS_WHERE_PTNUM      @"DELETE FROM Portfolios WHERE ptNum = ?"
#define DELETE_FROM_HEALTHCHECKS_WHERE_HEALTHID @"DELETE FROM HealthChecks where id = ?"
#define UPDATE_STATE_UPDATEDATE                 @"UPDATE State SET updatedate = ? "


#define INSERT_INTO_HEALTCHECKS_ID_PTNUM_MESSAGE_DATE_HCCOUNT   @"INSERT INTO HealthChecks (id, ptNum, message, date, hcCount) VALUES (?, ?, ?, ?, ?)"
#define INSERT_INTO_HEALTCHECKS_PTNUM_MESSAGE_DATE_HCCOUNT      @"INSERT INTO HealthChecks (ptNum,message,date,hcCount) VALUES (?,?,?,?)"
#define INSERT_INTO_HEALTHCHECKS_PTNUM_MESSAGE_HCCOUNT          @"INSERT INTO HealthChecks (ptNum,message,hcCount) VALUES (?,?,?)"
#define INSERT_INTO_HEALTHCHECKS_PTNUM_MESSAGE_DATE             @"INSERT INTO HealthChecks (ptNum,message,date) VALUES (?,?,?)"

#define UPDATE_ARTICLES_SET_ISREAD_WHERE_ARTICLEID              @"UPDATE Articles SET isRead = ? where id = ?"

static __strong DatabaseFunctions * _database;

//single fmdb queue ONLY
static __strong FMDatabaseQueue * FMDB_Queue;

static __strong dispatch_queue_t concurrencyQueue; //concurrency queue
static __strong dispatch_queue_t serialQueue ;


@interface DatabaseFunctions() {}


@property (nonatomic, strong) FMDatabase * FMDB;
//++ must keep this private! do not give access to others


//utility of public method 'resetDB'
- (void) updateStateInDB;
- (void) deleteFromAllTables:(void (^)(BOOL)) finish;

//utility of all non-query methods
- (void) executeUpdateOnDBwithSQLParams:(NSString *)sql, ...;


// get all portfolios
- (NSArray*)getAllPortfolios;
- (NSArray*)getAllArticles;
- (NSArray*)getAllHealthChecks;

@end


@implementation DatabaseFunctions

@synthesize FMDB;


#pragma mark -
#pragma mark Singleton

//singleton instance of this class
+ (id)sharedDatabaseFunctions {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _database = [[DatabaseFunctions alloc] init];
        NSLog(@"Created one and only singleton instance DatabaseFunctions %p", _database);
    });
    
    return _database;
}

#pragma mark LifeCycle

-(instancetype)init {
    
    NSLog(@"DatabaseFunctions.m - init <--");
    
    if (self = [super init]) {
        
        NSArray * paths              = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentDirectory = [paths objectAtIndex:0];
        NSString * dbPath            = [documentDirectory stringByAppendingPathComponent:DATABASE_FILE_NAME];
        
        NSLog(@"init only run once... Creating fmdb queue for database manipulation.");
        
        FMDB_Queue          = [FMDatabaseQueue databaseQueueWithPath:dbPath]; //strong the auto-released
        
        concurrencyQueue    = dispatch_queue_create("com.epam.halo.queue", DISPATCH_QUEUE_CONCURRENT);
        serialQueue         = dispatch_queue_create("com.epam.halo.queue2", DISPATCH_QUEUE_SERIAL);
        
        
        if([self CreateSchemas]) {
            NSLog(@"Schema created successfully");
        }
        return self;
        
    } //init if
    return nil;
}




-(void)resetDB {
    
    [self deleteFromAllTables:^(bool deleted) {
        if(deleted)
            [self updateStateInDB];
    }];
}


#pragma mark --- Portfolio Methods ---

-(void)insertPortfolioWithPfNum:(NSString*)portfolioNum
                    performance:(NSString*)performance
                            aum:(NSString*)aum
                            ccy:(NSString*)currency
                chartJSONString:(NSString*)json
                        andTime:(NSString*)time
                       onFinish:(void (^)(BOOL, NSString *)) finish {

    [self run_async_with_UI:^{

        [self executeUpdateOnDBwithSQLParams: INSERT_INTO_PORTFOLIOS,
         @"portfolio", portfolioNum, performance, aum, currency, json, time];
        finish(true, portfolioNum); //synced
    }];
}


-(void)deletePorfolioWithPtNum:(NSString*)ptNum
                      onFinish:(void (^)(BOOL, NSString *)) finish{
    
    [self run_barrier_async_with_UI:^{
        
        [self executeUpdateOnDBwithSQLParams: DELETE_FROM_PORTFOLIOS_WHERE_PTNUM, ptNum];
        finish(true, ptNum);
    }];
}


-(void)deleteAllPortfoliosFromDB: (void (^)(BOOL)) deleted {
    
    [self run_barrier_async_with_UI:^{
            
        [self executeUpdateOnDBwithSQLParams: DELETE_ALL_PORTFOLIOS];
        deleted(true);
    }];
}


-(void)getPortfolios:(void (^)(NSArray*)) finish {
    
    [self run_barrier_async_with_UI:^{
        
        __block NSArray * allPortfolios;
        allPortfolios = [self getAllPortfolios];
        finish(allPortfolios);
        
    }];
}


#pragma mark --- Article Methods ---

-(void)insertArticleWithID:(NSString*)articleId
                 withTitle:(NSString*)title
                    teaser:(NSString*)teaser
                   andTime:(NSString*)time
                  onFinish:(void (^)(BOOL, NSString * )) finish {
    
    [self run_async_with_UI:^{
        NSLog(@"inserting article %@", articleId);
        [self executeUpdateOnDBwithSQLParams: INSERT_INTO_ARTICLES,
                @"article", articleId, title, teaser, time, @"0"];
        
        finish(true, articleId);
    }];
    
}


-(void)updateIsReadForArticleId:(NSString *)articleId
                       onFinish:(void (^)(BOOL, NSString * )) updated {
    
   [self run_async_with_UI:^{
        [self executeUpdateOnDBwithSQLParams: UPDATE_ARTICLES_SET_ISREAD_WHERE_ARTICLEID, @"1", articleId];
        updated(true, articleId);
   }];
}

-(void) updateArticleId:(NSString *)articleId
              onUpdated:(void (^)(BOOL, NSString * )) updated {
    
    [self run_async_with_UI:^{
        NSString * updateSql = [NSString stringWithFormat:
                                @"UPDATE Articles SET %@ = '%@' WHERE %@ = '%@'",
                                @"isRead",@"1",
                                @"id", articleId];
        
        [self executeUpdateOnDBwithSQLParams: updateSql];
        updated(TRUE, articleId);
    }];
}



-(void)deleteArticleWithId:(NSString*)articleID
                  onFinish:(void (^)(BOOL, NSString * )) finish {
    
    [self run_barrier_async_with_UI:^{
        [self executeUpdateOnDBwithSQLParams: DELETE_FROM_ARTCILES_WHERE_ARTICLEID, articleID];
        finish(true, articleID);
    }];
}

-(void)deleteAllArticlesFromDB: (void (^)(BOOL)) finish  {
    
    [self run_barrier_async_with_UI:^{
        [self executeUpdateOnDBwithSQLParams: DELETE_ALL_ARTICLES];
        finish(true);
    }];
}


-(void)getArticles:(void (^)(NSArray*)) finish {
    
    [self run_barrier_async_with_UI:^{
        
        __block NSArray * allArticles;
        allArticles = [self getAllArticles];
        NSLog(@"getArticles received has %lu elements", (unsigned long)[allArticles count]);
        finish(allArticles);
    }];
}



#pragma mark --- Health Check Methods ---

-(void)deleteAllHealthChecksFromDB:(void (^)(BOOL)) finish {
    
    [self run_barrier_async_with_UI:^{
        
        [self executeUpdateOnDBwithSQLParams: DELETE_ALL_HEALTHCHECKS];
        finish(true);
    }];
}


-(void)insertHealthCheckWithIdNum:(NSString*)idNum
                            ptNum:(NSString*)ptNum
                          message:(NSString*)message
                             date:(NSString*)date
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish {
    
    [self run_async_with_UI:^{
        
        [self executeUpdateOnDBwithSQLParams:
         INSERT_INTO_HEALTCHECKS_ID_PTNUM_MESSAGE_DATE_HCCOUNT,
         idNum, ptNum, message, date, hcCount];
        finish(true, idNum);
    }];
}

-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                             date:(NSString*)date
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish {
    
    [self run_async_with_UI:^{
            
        [self executeUpdateOnDBwithSQLParams:
                INSERT_INTO_HEALTCHECKS_PTNUM_MESSAGE_DATE_HCCOUNT,
                ptNum, message, date, hcCount];
            
        finish(true, ptNum);
    }];
}


-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                       andHCCount:(NSString*)hcCount
                         onFinish:(void (^)(BOOL, NSString *)) finish {
    
    [self run_async_with_UI:^{
            
        [self executeUpdateOnDBwithSQLParams:
                INSERT_INTO_HEALTHCHECKS_PTNUM_MESSAGE_HCCOUNT,
                ptNum, message, hcCount];
            
        finish(true, ptNum);
    }];
}


-(void)insertHealthCheckWithPtNum:(NSString*)ptNum
                          message:(NSString*)message
                          andDate:(NSString*)date
                         onFinish:(void (^)(BOOL, NSString *)) finish {
    
    [self run_async_with_UI:^{
            
        [self executeUpdateOnDBwithSQLParams:
                INSERT_INTO_HEALTHCHECKS_PTNUM_MESSAGE_DATE,
                ptNum, message, date];
            
        finish(true, ptNum);
    }];
    
}



- (void)getHealthChecks:(void (^)(NSArray*)) finish {
    
    [self run_barrier_async_with_UI:^{
        
        finish([self getAllHealthChecks]);
    }];
}



-(void)deleteHealthCheckWithID:(NSString*)healthCheckID
                      onFinish:(void (^)(BOOL, NSString *)) finish {
    
    [self run_barrier_async_with_UI:^{
            
        NSLog(@"DatabaseFunctions.m - deleteHealthCheckWithID %@", healthCheckID);
        [self executeUpdateOnDBwithSQLParams: DELETE_FROM_HEALTHCHECKS_WHERE_HEALTHID, healthCheckID];
        finish(true, healthCheckID);
    }];
}


#pragma mark --- State Methods ---

-(void)updateStateInDB {
    
    [self run_async_with_UI:^{
        NSNumber * updatedateValue = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
        [self executeUpdateOnDBwithSQLParams:UPDATE_STATE_UPDATEDATE, [updatedateValue stringValue]];
    }];
}


- (NSString *) getStateUpdatedDate
{
    __block NSString * updateDate;
    
    [self run_async_with_UI:^{

        [FMDB_Queue inDatabase:^(FMDatabase * db) { //ask the singleton fmdb queue for a valid db variable
            FMResultSet * resultSet = [db executeQuery:SELECT_LATEST_STATE];
            
            //we only get 1
            if ([resultSet next]) {
                updateDate = [resultSet stringForColumn:@"updatedate"];
            }
        }];
    }];
    
    return updateDate;
}



#pragma mark --- utility 'execute' Methods ---


-(BOOL)CreateSchemas {
    
    __block bool schemaCreated;
    [self run_barrier_async_with_UI:^{
            
        NSLog(@"CreateSchemas <--");
        
        [FMDB_Queue inDatabase:^(FMDatabase *db) {
            
            if(![db executeUpdate: CREATE_TABLE_ARTICLES]) {
                NSLog(@"ERROR creating Table Articles");
            }
            
            if(![db executeUpdate: CREATE_TABLE_PORTFOLIOS]) {
                NSLog(@"ERROR creating Table Portfolios");
            }
            
            if(![db executeUpdate: CREATE_TABLE_HEALTHCHECKS]) {
                NSLog(@"ERROR creating Table HealthChecks");
            }
            
            if(![db executeUpdate:CREATE_TABLE_STATE]) {
                NSLog(@"ERROR creating Table State");
            }
            
            NSNumber *updatedateValue = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()];
            [db executeUpdate:INSERT_INTO_STATE, [updatedateValue stringValue]];
            
        }];
        
        NSLog(@"CreateSchemas -->");
        schemaCreated = true;
    }];
    
    return schemaCreated;
}



- (void) deleteFromAllTables:(void (^)(bool)) finish {
    
    [self run_barrier_async_with_UI:^{

        [FMDB_Queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:DELETE_ALL_ARTICLES];
            [db executeUpdate:DELETE_ALL_PORTFOLIOS];
            [db executeUpdate:DELETE_ALL_HEALTHCHECKS];
            finish(true);
        }];
    }];
}


- (NSArray*)getAllHealthChecks {
    
    
    __block NSArray * allArticles;
    
    NSLog(@"DatabaseFunctions.m - getAllHealthChecks <--");
    
    [FMDB_Queue inDatabase:^(FMDatabase * db) { //ask the singleton fmdb queue for a valid db variable
        
        NSMutableArray * resultContainer = [NSMutableArray array];
        FMResultSet * resultSet = [db executeQuery:SELECT_ALL_FROM_HEALTHCHECKS];
        
        HealthCheckModel * model;
        
        while ([resultSet next]) {
            
            model =   [[HealthCheckModel alloc] init];
            model.id         =   [resultSet intForColumn:@"id"];
            model.pertfolioNum      =   [resultSet stringForColumn:@"ptNum"];
            model.message           =   [resultSet stringForColumn:@"message"];
            model.hcCount           =   [resultSet stringForColumn:@"hcCount"];
            NSString *dateStr       =   [resultSet stringForColumn:@"date"];
            model.date              =   dateStr;
            [resultContainer addObject:model];
            
        } //while
        
        allArticles = resultContainer;
        
    }];
    
    NSLog(@"DatabaseFunctions.m - getAllHealthChecks -->");
    return allArticles;
}


- (NSArray*)getAllArticles {
    
    __block NSArray * allArticles;
    
    [FMDB_Queue inDatabase:^(FMDatabase * db) { //ask the singleton fmdb queue for a valid db variable
        
        NSMutableArray * resultContainer = [NSMutableArray array];
        
        FMResultSet * resultSet = [db executeQuery:SELECT_ALL_FROM_ARTICLES];
        ArticleModel * model;
        
        while ([resultSet next]) {
            
            model    = [[ArticleModel alloc] init];
            model.type              = [resultSet stringForColumn:@"type"];
            model.articleId         = [resultSet stringForColumn:@"id"];
            model.teaser            = [resultSet stringForColumn:@"teaser"];
            model.date              = [resultSet stringForColumn:@"date"];
            model.title             = [resultSet stringForColumn:@"title"];
            model.isRead            = [[resultSet stringForColumn:@"isRead"] boolValue];
            
            //NSLog(@"Articles (%@ %@) retrieved from DB", model.type, model.articleId);
            [resultContainer addObject:model];
        }
        
        allArticles = resultContainer;
    }];
    
    return allArticles;
}


- (NSArray*)getAllPortfolios {
    
    NSLog(@"DatabaseFunctions.m - getAllPortfolios <--");
    
    __block NSArray * resultArray;
    
    [FMDB_Queue inDatabase:^(FMDatabase * db) { //ask the singleton fmdb queue for a valid db variable
        
        NSMutableArray * resultContainer = [NSMutableArray array];
        FMResultSet * resultSet = [db executeQuery:SELECT_ALL_FROM_PORTFOLIOS];
        
        while ([resultSet next]) {
            
            PortfolioModel * model   = [[PortfolioModel alloc] init];
            
            model.type              = [resultSet stringForColumn:@"type"];
            model.ptNum             = [resultSet stringForColumn:@"ptNum"];
            model.perf              = [resultSet stringForColumn:@"perf"];
            model.aum               = [resultSet stringForColumn:@"aum"];
            model.ccy               = [resultSet stringForColumn:@"ccy"];
            
            NSString * chartStr     = [resultSet stringForColumn:@"chart_w"];
            
            if (chartStr.length) {
                NSData *data        = [chartStr dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *array      = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                model.chart_w       = array;
            }
            
            NSString * date          = [resultSet stringForColumn:@"date"];
            NSString * localDate     = [date getLocalDateFormateUTCDate];
            //if(!localDate) { NSLog(@"...uh oh, date is nil"); }
            model.date              = localDate;
            
            //NSLog(@"Portfolio (%@ %@) retrieved from DB", model.type, model.ptNum);
            
            [resultContainer addObject:model];
        } //while
        
        resultArray = resultContainer;
        NSLog(@"resultContainer - %lu", (unsigned long)[resultContainer count]);
        
    }];
    
    NSLog(@"resultArray - %lu", (unsigned long)[resultArray count]);
    
    NSLog(@"DatabaseFunctions.m - getAllPortfolios -->");
    
    return resultArray;
}


-(void)run_barrier_async_with_UI:(void (^)(void)) task {
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        dispatch_barrier_async(concurrencyQueue, ^{
            
            task();
            
        });
    });
}

-(void)run_async_with_UI:(void (^)(void)) task {
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        dispatch_async(concurrencyQueue, ^{
            
            task();
            
        });
    });
}



//ref - http://stackoverflow.com/questions/2391780/how-to-pass-variable-arguments-to-another-method
//http://alexboyd.me/2014/04/ios-variadic-functions/

-(void) executeUpdateOnDBwithSQLParams:(NSString *)sql, ... {
    
    va_list ap;
    
    __block va_list * vaListPtr = &ap;
    
    __block bool success;
    
    va_start(*vaListPtr, sql);
    
    [FMDB_Queue inDatabase:^(FMDatabase * db) {
        success = [db executeUpdate:sql withVAList:*vaListPtr];
    }];
    
    va_end(*vaListPtr);
}

@end
