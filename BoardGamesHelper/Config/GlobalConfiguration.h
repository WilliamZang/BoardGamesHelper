//
//  GlobalConfiguration.h
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/23.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//

#ifndef BoardGamesHelper_GlobalConfiguration_h
#define BoardGamesHelper_GlobalConfiguration_h

#import <FBTweakInline.h>

#define SERVER_PORT         FBTweakValue(@"Server", @"Host", @"Port", 9876, 8000, 60000)
#define SERVER_PORT_STRING  [NSString stringWithFormat:@"%d", SERVER_PORT]

#endif
