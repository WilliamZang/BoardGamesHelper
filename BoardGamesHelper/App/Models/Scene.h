//
//  Scene.h
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/22.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game, RACSignal;
@interface Scene : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) RACSignal *finish;

- (void)play:(Game *)game;


@end
