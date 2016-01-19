//
//  AppDelegate.m
//  iOSfmdbTest
//
//  Created by  Ricky Tsao on 1/16/16.
//  Copyright © 2016 Epam. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseFunctions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*
    int totalNumberOfPortfolios = 10000;
    NSLog(@"Let's add %d articles", totalNumberOfPortfolios);
    
    NSDate *start = [NSDate date];
    
    for ( int i = 0; i < totalNumberOfPortfolios; i++) {
        //do long processing task here.

        [[DatabaseFunctions sharedDatabaseFunctions] insertPortfolioWithPfNum:[NSString stringWithFormat:@"%d", i]
                                                                  performance:@"great"
                                                                          aum:@"6.6"
                                                                          ccy:@"3.54"
                                                              chartJSONString:
         @"parameters[[{\"type\":\"portfolio\",\"ptfl\":\"****50\",\"perf\":100.1235123,\"ccy\":\"USD\",\"aum\":97909023,\"chart_w\":[100.1235123,0,0,0,0],\"asof\":\"2013-10-29\",\"job\":\"DE\"}]]"
                                                                      andTime:@"12-14-2014"];
         
    }
    
    
    NSDate * codeFinish = [NSDate date];
    //NSTimeInterval is always specified in seconds
    NSTimeInterval executionTime = [codeFinish timeIntervalSinceDate:start];
    NSLog(@"Execution Time: %f sec, each insert took %f sec", executionTime, executionTime/totalNumberOfPortfolios);
    
    
    
    [[DatabaseFunctions sharedDatabaseFunctions] getAllPortfolios:^(NSArray *resultArray) {
        NSLog(@"YOU JUST INSERTED %lu PORTFOLIOS", (unsigned long)[resultArray count]);
    }];

    [[DatabaseFunctions sharedDatabaseFunctions] resetDB];
    */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
