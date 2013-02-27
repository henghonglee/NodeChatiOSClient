//
//  PBtcpObject.m
//  PolarBear
//
//  Created by HengHong on 25/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import "PBtcpObject.h"
#import <FacebookSDK/FacebookSDK.h>
@implementation PBtcpObject

+ (id)sharedTcpObject
{
    static dispatch_once_t once;
    static PBtcpObject *sharedTcpObject;
    dispatch_once(&once, ^ { sharedTcpObject = [[self alloc] init]; });
    return sharedTcpObject;
}

- (void)initNetworkCommunication {
    
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.7", 5000, &readStream, &writeStream);
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
    
}



@end
