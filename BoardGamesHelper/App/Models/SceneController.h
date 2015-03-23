//
//  SceneController.h
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/22.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@interface SceneController : NSObject

@property (nonatomic, readonly) RACSignal *sceneStream; /* type is scene */
@end
