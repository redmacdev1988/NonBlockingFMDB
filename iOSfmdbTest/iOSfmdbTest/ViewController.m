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
            
        [[DatabaseFunctions sharedDatabaseFunctions] insertArticleWithID:[NSString stringWithFormat:@"%d",i]
                                                               withTitle:@"some title"
                                                                  teaser:@"teaser..."
                                                                 andTime:@"06-03-2015"
                                                                onFinish:^(BOOL finished, NSString * articleNum) {
                                                                    
                                                                    (finished) ?
                                                                    NSLog(@"Article %@ has been inserted", articleNum) :
                                                                    NSLog(@"uh oh, Article %@ NOT inserted :(", articleNum) ;
                                                                }];
    }
    
    
        
    [[DatabaseFunctions sharedDatabaseFunctions] deleteArticleWithId:@"99" onFinish:^(BOOL done, NSString * articleId) {
        (done) ? NSLog(@"Article %@ deleted", articleId) : NSLog(@"Article %@ NOT deleted", articleId);
    }];
    
    [[DatabaseFunctions sharedDatabaseFunctions] deleteArticleWithId:@"98" onFinish:^(BOOL done, NSString * articleId) {
        (done) ? NSLog(@"Article %@ deleted", articleId) : NSLog(@"Article %@ NOT deleted", articleId);
    }];
    
    [[DatabaseFunctions sharedDatabaseFunctions] deleteArticleWithId:@"97" onFinish:^(BOOL done, NSString * articleId) {
        (done) ? NSLog(@"Article %@ deleted", articleId) : NSLog(@"Article %@ NOT deleted", articleId);
    }];
    
    [[DatabaseFunctions sharedDatabaseFunctions] deleteArticleWithId:@"96" onFinish:^(BOOL done, NSString * articleId) {
        (done) ? NSLog(@"Article %@ deleted", articleId) : NSLog(@"Article %@ NOT deleted", articleId);
    }];
    
    [[DatabaseFunctions sharedDatabaseFunctions] updateIsReadForArticleId:@"1" onFinish:^(BOOL updated, NSString * articleId) {
        (updated) ? NSLog(@"%@ updated", articleId) : NSLog(@"%@ NOT updated", articleId);
    }];
    
    [[DatabaseFunctions sharedDatabaseFunctions] updateIsReadForArticleId:@"2" onFinish:^(BOOL updated, NSString * articleId) {
        (updated) ? NSLog(@"%@ updated", articleId) : NSLog(@"%@ NOT updated", articleId);
    }];
        
    
    [[DatabaseFunctions sharedDatabaseFunctions] getArticles:^(NSArray * allArticles) {
        NSLog(@"ALL Articles RESULTS : %lu", (unsigned long)[allArticles count]);
    }];

    NSLog(@"viewDidLoad -->");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
