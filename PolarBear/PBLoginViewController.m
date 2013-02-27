//
//  PBLoginViewController.m
//  PolarBear
//
//  Created by HengHong on 20/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//
#import "PBAppDelegate.h"
#import "PBLoginViewController.h"

@interface PBLoginViewController ()

@end

@implementation PBLoginViewController

+(PBLoginViewController *)sharedInstance
{
    static PBLoginViewController *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [PBLoginViewController alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)showLoggedInView
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (IBAction)loginWithFacebook:(id)sender {
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // To-do, show logged in view
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    } else {
        PBAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate openSession];
        // No, display the login page.
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
