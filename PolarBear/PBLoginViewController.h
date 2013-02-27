//
//  PBLoginViewController.h
//  PolarBear
//
//  Created by HengHong on 20/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>

@interface PBLoginViewController : UIViewController
+(PBLoginViewController*)sharedInstance;
-(void)showLoggedInView;
@end
