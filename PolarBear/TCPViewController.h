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
@interface TCPViewController : UIViewController<NSStreamDelegate,UITableViewDataSource,UITabBarControllerDelegate>

{

}
@property (strong, nonatomic) NSInputStream*inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (retain, nonatomic) NSMutableArray* textArray;
@property (retain, nonatomic) IBOutlet UITableView *channelTableView;
@property (retain, nonatomic) IBOutlet UITextField *sendTextField;
@end
