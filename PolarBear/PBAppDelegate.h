//
//  PBAppDelegate.h
//  PolarBear
//
//  Created by HengHong on 20/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface PBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)openSession;
- (void)openSessionWithCallbackBlock:(void (^)(BOOL success))callbackBlock;
@end
