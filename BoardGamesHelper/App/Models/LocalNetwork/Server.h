//
//  Server.h
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/23.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//
#import <Foundation/Foundation.h>

@class RACSignal, RACChannelTerminal, RACCommand;
@interface Server : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (Server*)sharedInstance;

@property (nonatomic, readonly) RACChannelTerminal *eventStream;

@property (nonatomic, readonly) RACCommand *startServer;

@property (nonatomic, readonly) RACCommand *stopServer;

@end
