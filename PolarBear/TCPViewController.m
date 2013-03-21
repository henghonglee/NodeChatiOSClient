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

@interface TCPViewController ()

@end

@implementation TCPViewController

@synthesize textArray,inputStream,outputStream;
- (void)viewDidLoad
{
    [super viewDidLoad];
    textArray = [[NSMutableArray alloc]init];
    self.channelTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-44-40)];
    [self.channelTableView setDelegate:self];
    [self.channelTableView setDataSource:self];
    [self.view addSubview:self.channelTableView];
    [self.view bringSubviewToFront:self.inputToolbar];
    self.navigationItem.title = @"NodeChat";
    UIBarButtonItem* leaveButton = [[UIBarButtonItem alloc]initWithTitle:@"Leave Room" style:UIBarButtonItemStyleBordered target:self action:@selector(leaveAndDisconnect)];
    self.navigationItem.rightBarButtonItem = leaveButton;
	// Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated
{

    
}
-(void)leaveAndDisconnect
{
    NSString *response  = @"leaveRoom Lobby";
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    if([outputStream write:[data bytes] maxLength:[data length]]>0){
        [self breakNetworkCommunication];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Bye!" message:@"You'll stop recieving push notifications =)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    exit(0);
}
//54.225.216.199
- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"54.225.216.199", 5000, &readStream, &writeStream);
    inputStream = (__bridge_transfer NSInputStream *)readStream;
    outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream open];
    [outputStream open];
    
}
- (void)breakNetworkCommunication {
    inputStream.delegate = nil;
    outputStream.delegate = nil;
    [inputStream close];
    [outputStream close];
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    	switch (eventCode) {
        case 0:
            NSLog(@"no event");
            break;
		case 1:
			NSLog(@"Stream opened");
            // here we input our paramsAdd
                if (aStream==outputStream) {
                    NSLog(@"OutStream opened");


                    if (FBSession.activeSession.isOpen) {
                        [[FBRequest requestForMe] startWithCompletionHandler:
                         ^(FBRequestConnection *connection,
                           NSDictionary<FBGraphUser> *user,
                           NSError *error) {
                             if (!error) {
                                 self.currentUser = user;
                                 [textArray removeAllObjects];
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
                        NSLog(@"FBsession not open error ");
                    }
                }
                if (aStream==inputStream){
                    NSLog(@"input stream opened");
                }
			break;
            
		case 2:
            if (aStream == inputStream) {
                NSLog(@"input has bytes");
                uint8_t buffer[8192];
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
            NSLog(@"end encountered");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;

            
		default:
			NSLog(@"Unknown event");
            
	}
    
}
-(void)inputButtonPressed:(NSString *)inputText
{
    [super inputButtonPressed:inputText];
    NSString *response  = [NSString stringWithFormat:@"say %@\n",inputText];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    if([outputStream write:[data bytes] maxLength:[data length]]>0){
        NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", inputText],@"message",[NSDictionary dictionaryWithObjectsAndKeys:self.currentUser.first_name,@"fb_name", nil],@"params", nil];
        inputText = @"";
        [self.textArray addObject:dictionary];
        [self.channelTableView reloadData];
        [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}



- (IBAction)sendText:(id)sender {

    }
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [textArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *channelCellIdentifier = @"channelCell";
    PBChatCell* cell = (PBChatCell*) [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PBChatCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (PBChatCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    NSDictionary* messageDictionary = [textArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",[[messageDictionary objectForKey:@"params"] objectForKey:@"fb_name"],[messageDictionary objectForKey:@"message"]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.inputToolbar.textView resignFirstResponder];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    [super keyboardWillShow:notification];
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.channelTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-kbSize.height-44)];
    if (self.textArray.count>0) {
        [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [super keyboardWillHide:notification];
    [self.channelTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    if (self.textArray.count>0) {
        [self.channelTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.textArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
