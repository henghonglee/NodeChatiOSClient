//
//  PBtcpObject.h
//  PolarBear
//
//  Created by HengHong on 25/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBtcpObject : NSObject<NSStreamDelegate>

@property (nonatomic,strong) NSInputStream*inputStream;
@property (nonatomic,strong) NSOutputStream *outputStream;
+ (id)sharedTcpObject;
- (void)initNetworkCommunication;
@end
