//
//  TCPViewController.m
//  TCPconnect
//
//  Created by HengHong on 11/10/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//

#import "TCPViewController.h"
#import "PBLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PBtcpObject.h"
@interface TCPViewController ()

@end

@implementation TCPViewController

@synthesize textArray,inputStream,outputStream;
- (void)viewDidLoad
{
    [super viewDidLoad];
    textArray = [[NSMutableArray alloc]init];

    [self initNetworkCommunication];
    
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated
{
//    PBLoginViewController* loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
//    // Override point for customization after application launch.
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
//    {
//        // To-do, show logged in view        
//         NSLog(@"show logged in view");
//    } else {
//        // No, display the login page.
//        
//        [self presentViewController:loginViewController animated:YES completion:^{
//            
//        }];
//    }
    
}
- (void)initNetworkCommunication {
    
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.7", 5000, &readStream, &writeStream);
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream.delegate = self;
    outputStream.delegate = self;

    [inputStream open];
    [outputStream open];
    
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
        NSLog(@"%@,%@",aStream,aStream.streamError);
    	switch (eventCode) {
        case 0:
            NSLog(@"no event");
            break;
		case 1:
			NSLog(@"Stream opened");
            // here we input our paramsAdd
                if (aStream==outputStream) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(openSession)];
                    if (FBSession.activeSession.isOpen) {
                        [[FBRequest requestForMe] startWithCompletionHandler:
                         ^(FBRequestConnection *connection,
                           NSDictionary<FBGraphUser> *user,
                           NSError *error) {
                             if (!error) {
                                 NSLog(@"%@",user.id);
                                 NSLog(@"%@",user.name);
                                 NSData *pushData = [[NSData alloc] initWithData:[[NSString stringWithFormat:@"paramAdd device_token=%@\n ",[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]] dataUsingEncoding:NSASCIIStringEncoding]];
                                 NSLog(@"submit paramAdd fb_name %u",[outputStream write:[pushData bytes] maxLength:[pushData length]]);
                                 NSData *data = [[NSData alloc] initWithData:[[NSString stringWithFormat:@"paramAdd fb_name=%@\n ",[user.first_name stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] dataUsingEncoding:NSASCIIStringEncoding]];
                                 NSLog(@"submit paramAdd fb_name %u",[outputStream write:[data bytes] maxLength:[data length]]);
                                 NSData* idData = [[NSData alloc] initWithData:[[NSString stringWithFormat:@"paramAdd fb_id=%@\n ",user.id] dataUsingEncoding:NSASCIIStringEncoding]];
                                 NSLog(@"submit paramAdd fb_name %u",[outputStream write:[idData bytes] maxLength:[idData length]]);
                                     NSData* roomChangeData = [[NSData alloc] initWithData:[[NSString stringWithFormat:@"roomChange Lobby\n "] dataUsingEncoding:NSASCIIStringEncoding]];
                                     NSLog(@"submit roomChange %u",[outputStream write:[roomChangeData bytes] maxLength:[roomChangeData length]]);
                             }else{
                                 NSLog(@"error = %@",error);
                             }
                         }];      
                    }else{
                        NSLog(@"FBsession not open");
                    }
                }
                
			break;
            
		case 2:
            NSLog(@"Stream has bytes");
            if (aStream == inputStream) {
                
                uint8_t buffer[4096];
                int len;
                
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer
                                                                    length:len
                                                                  encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"output = %@",output);
                            NSError* error = nil;
                            NSData* data = [[NSData alloc]initWithBytes:buffer length:len];
                            NSDictionary* outDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];                            NSLog(@"error = %@",error);
                      
                            if ([outDictionary objectForKey:@"message"])
                            {
                                [textArray addObject:outDictionary];
                                [_channelTableView reloadData];
                                [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                
                            }
                            if ([outDictionary objectForKey:@"messages"])
                            {
                                NSArray* messagesArray = [outDictionary objectForKey:@"messages"];
                                for (NSString* message in messagesArray)
                                {
                                    NSLog(@"message = %@",message);
                                    NSDictionary* messageDictionary = [NSJSONSerialization
                                                                       JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingAllowFragments
                                                                       error:&error];
                                    [textArray insertObject:messageDictionary atIndex:0];
                                    [_channelTableView reloadData];
                                    [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                                }
                            }
                            
                        }
                    }
                }
            }
            break;
		case 4:
            NSLog(@"Can not connect to the host! %@",[aStream streamError]);
			break;
            
            case NSStreamEventEndEncountered:
                
                [aStream close];
                [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                
                break;

            
		default:
			NSLog(@"Unknown event");
            
	}
    
}
- (IBAction)sendText:(id)sender {

    NSString *response  = [NSString stringWithFormat:@"say %@\n", _sendTextField.text];

    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", _sendTextField.text],@"message",[NSDictionary dictionaryWithObjectsAndKeys:@"MyName",@"fb_name", nil],@"params", nil];
    _sendTextField.text = @"";
    [self.textArray addObject:dictionary];
    [self.channelTableView reloadData];
    [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%u",[outputStream write:[data bytes] maxLength:[data length]]);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [textArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"mycell";
    
    PBChatCell *cell = (PBChatCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSDictionary* messageDictionary = [textArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",[[messageDictionary objectForKey:@"params"] objectForKey:@"fb_name"],[messageDictionary objectForKey:@"message"]];
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
