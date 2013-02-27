//
//  PBAppDelegate.m
//  PolarBear
//
//  Created by HengHong on 20/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import "PBAppDelegate.h"
#import "PBLoginViewController.h"
#import "PBMasterViewController.h"
#import "PBtcpObject.h"
@implementation PBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound |
      UIRemoteNotificationTypeAlert)];
    return YES;
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)devToken
{
	NSLog(@"In did register for Remote Notifications , %@", devToken);
    if (devToken) {
        NSString *str = [NSString
                         stringWithFormat:@"%@",devToken];
        NSString *newString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"<" withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
        [[NSUserDefaults standardUserDefaults]setObject:newString forKey:@"pushToken"];
    }

}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:
(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

// You can alternately implement the pushRegistrationFailed API:

// +(void)pushRegistrationFailed:(UIApplication*)application errorInfo: (NSError *)err



- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)
userInfo
{
	NSLog(@"In did receive  Remote Notifications, %@", userInfo);
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    [((PBtcpObject*)[PBtcpObject sharedTcpObject]) initNetworkCommunication];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark FBSession Methods
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:

            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            break;
    }
    
    if (error) {
        NSString *errorTitle = NSLocalizedString(@"Error", @"Facebook connect");
        NSString *errorMessage = [error localizedDescription];
        if (error.code == FBErrorLoginFailedOrCancelled) {
            errorTitle = NSLocalizedString(@"Facebook Login Failed", @"Facebook Connect");
            errorMessage = NSLocalizedString(@"Make sure you've allowed My App to use Facebook in Settings > Facebook.", @"Facebook connect");
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Facebook Connect")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end
