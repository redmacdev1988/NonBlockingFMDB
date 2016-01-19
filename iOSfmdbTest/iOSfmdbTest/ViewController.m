//
//  ViewController.m
//  iOSfmdbTest
//
//  Created by  Ricky Tsao on 1/16/16.
//  Copyright © 2016 Epam. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseFunctions.h"

@interface ViewController ()
{
    dispatch_queue_t queue ;
}



@end

@implementation ViewController

-(instancetype)init {
    
    if(self = [super init]) {
    
        
        NSLog(@"got my queue");
    }
    
    return self;
}

-(void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    float value = slider.value;
    //-- Do further actions
    
    NSLog(@"slider value: %f", value);
}


- (void)viewDidLoad {
    
    NSLog(@"viewDidLoad <--");
    
    [super viewDidLoad];
    
 
    
    
    CGRect frame = CGRectMake(20.0, 120.0, 280.0, 30.0);
    
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor redColor]];
    
    slider.minimumValue = 0.0;
    slider.maximumValue = 50.0;
    slider.continuous = YES;
    slider.value = 25.0;
    [self.view addSubview:slider];
    

    for ( int i = 0; i < 100; i++) {

        //put task on main queue
        dispatch_async(dispatch_get_main_queue(), ^() {
        
            
            /*
            [[DatabaseFunctions sharedDatabaseFunctions] insertHealthCheckWithIdNum:[NSString stringWithFormat:@"%d",i]
                                                                              ptNum:@"some pt num"
                                                                            message:@"my message to you is..."
                                                                               date:@"2015-03-02"
                                                                         andHCCount:@"325"
                                                                           onFinish:^(BOOL inserted, NSString * idNum) {
                                                                               
            (inserted) ? NSLog(@"health check %@ inserted", idNum) : NSLog(@"health check %@ NOT inserted", idNum);
             
            
             }];
             */
            /*
            [[DatabaseFunctions sharedDatabaseFunctions] insertHealthCheckWithPtNum:@"some pt num"
                                                                            message:@"message"
                                                                            andDate:@"some date"
                                                                           onFinish:^(BOOL inserted, NSString *ptNum) {
                (inserted) ? NSLog(@"health check %@ inserted", ptNum) : NSLog(@"health check %@ NOT inserted", ptNum);
            }];
            */
            
            /*
            [[DatabaseFunctions sharedDatabaseFunctions] insertHealthCheckWithPtNum:@"some pt num"
                                                                             message:@"my message"
                                                                          andHCCount:@"what's the count"
                                                                            onFinish:^(BOOL inserted, NSString * ptNum) {
                 (inserted) ? NSLog(@"health check %@ inserted", ptNum) : NSLog(@"health check %@ NOT inserted", ptNum);
            }];
            */
            
            
    
        });
        
    }


    //put this task on main queue
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        [[DatabaseFunctions sharedDatabaseFunctions] getHealthChecks:^(NSArray * allHealthChecks) {
            NSLog(@"ALL health check RESULTS : %lu", (unsigned long)[allHealthChecks count]);
        }];
        
        [[DatabaseFunctions sharedDatabaseFunctions] deleteAllHealthChecksFromDB:^(BOOL deleted) {
            (deleted) ? NSLog(@"ALL health checks deleted") : NSLog(@"hc not deleted");;
        }];
        
        [[DatabaseFunctions sharedDatabaseFunctions] getHealthChecks:^(NSArray * allHealthChecks) {
            NSLog(@"ALL health check RESULTS : %lu", (unsigned long)[allHealthChecks count]);
        }];
    });
    
    
    /*
    //put this task on main queue
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[DatabaseFunctions sharedDatabaseFunctions] deleteAllPortfoliosFromDB:^(BOOL deleted) {
            (deleted) ?
            NSLog(@"all portfolios deleted") :
            NSLog(@"uh oh, all portfolios NOT DELETED :(") ;
        }];
    });
     */
    

    NSLog(@"viewDidLoad -->");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
