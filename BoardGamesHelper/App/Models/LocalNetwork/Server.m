//
//  Server.m
//  BoardGamesHelper
//
//  Created by ZangChengwei on 15/3/23.
//  Copyright (c) 2015年 ZangChengwei. All rights reserved.
//

#import "Server.h"
#import <ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <FastServerSocket.h>
#import <FastSocket.h>
#import "GlobalConfiguration.h"

@interface Server()

@property (nonatomic, strong) FastServerSocket *serverSocket;
@property (nonatomic, strong) RACChannel *channel;
@end

@implementation Server

static Server *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[Server alloc] init];
}

- (id)mutableCopy
{
    return [[Server alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    __block BOOL pauseRunLoop = YES;
    self.serverSocket = [[FastServerSocket alloc] initWithPort:SERVER_PORT_STRING];
    @weakify(self);
    _startServer = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            BOOL listenSuccess = [self.serverSocket listen];
            if (!listenSuccess) {
                [subscriber sendError:self.serverSocket.lastError];
            } else {
                pauseRunLoop = NO;
            }
            return nil;
        }];
    }];
    
    _stopServer = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            BOOL closeSuccess = [self.serverSocket close];
            if (!closeSuccess) {
               [subscriber sendError:self.serverSocket.lastError];
            } else {
                pauseRunLoop = YES;
            }
            return nil;
        }];
    }];
    
    self.channel = [[RACChannel alloc] init];
    _eventStream = self.channel.followingTerminal;
    
    NSMutableArray *sockets = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self);
        fd_set server_fd_set;
        int max_fd = -1;
        struct timeval tv;
        tv.tv_sec = 2;
        tv.tv_usec = 0;
        Byte buffer[1024];

        while (1) {
            if (pauseRunLoop) {
                sleep(1);
            } else {
                FD_ZERO(&server_fd_set);
                FD_SET(self.serverSocket.sockfd, &server_fd_set);
                if (max_fd < self.serverSocket.sockfd) {
                    max_fd = self.serverSocket.sockfd;
                }
                
                for (NSNumber *fd in sockets) {
                    int client_fd = [fd intValue];
                    FD_SET(client_fd, &server_fd_set);
                    if (max_fd < client_fd) {
                        max_fd = client_fd;
                    }
                }
                
                int ret = select(max_fd + 1, &server_fd_set, NULL, NULL, &tv);
                if (ret < 0) {
                    continue;
                } else if(ret == 0) {
                    continue;
                } else {
                    if (FD_ISSET(self.serverSocket.sockfd, &server_fd_set)) {
                        FastSocket *socket = [self.serverSocket accept];
                        [sockets addObject:socket];
                    }
                    NSMutableArray *removeSockets = [NSMutableArray array];
                    for (FastSocket *socket in sockets) {
                        if (FD_ISSET(socket.sockfd, &server_fd_set)) {
                            bzero(buffer, 1024);
                            long size = [socket receiveBytes:buffer limit:1024];
                            if (size > 0) {
                                NSData *data = [NSData dataWithBytes:buffer length:size];
                                [self.channel.leadingTerminal sendNext:data];
                            } else if (size < 0) {
                                [self.channel.leadingTerminal sendError:socket.lastError];
                            } else {
                                [removeSockets addObject:socket];
                            }
                        }
                    }
                    [sockets removeObjectsInArray:removeSockets];
                }
                
            }
            
        }
    });
    
    [self.channel.leadingTerminal subscribeNext:^(NSData *x) {
        [sockets enumerateObjectsUsingBlock:^(FastSocket *socket, NSUInteger idx, BOOL *stop) {
        
            [socket sendBytes:x.bytes count:x.length];
        }];
        
    }];
    return self;
}


@end
