//
//  TCPViewController.h
//  TCPconnect
//
//  Created by HengHong on 11/10/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import "PBChatCell.h"
#import "UIInputToolbarViewController.h"
#import "UIInputToolbar.h"  
#import <FacebookSDK/FacebookSDK.h>
@interface TCPViewController : UIInputToolbarViewController<NSStreamDelegate,UITableViewDataSource,UITabBarControllerDelegate,UITableViewDelegate>

{

}
@property (strong, nonatomic) NSDictionary<FBGraphUser> * currentUser;
@property (strong, nonatomic) NSInputStream*inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (retain, nonatomic) NSMutableArray* textArray;
@property (strong, nonatomic) UITableView *channelTableView;
@property (retain, nonatomic) IBOutlet UITextField *sendTextField;
@end
