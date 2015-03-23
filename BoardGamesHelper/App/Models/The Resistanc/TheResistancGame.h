//
//  TheResistancGame.h
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/22.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//

#import "Game.h"

@interface TheResistancGame : Game

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSArray *spies;
@property (nonatomic, readonly) NSArray *freeSolders;

@end
