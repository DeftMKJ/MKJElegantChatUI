//
//  MKJSocketService.m
//  SocketSeverce
//
//  Created by 宓珂璟 on 2017/2/1.
//  Copyright © 2017年 Deft_Mikejing_iOS_coder. All rights reserved.
//

#import "MKJSocketService.h"
#import "GCDAsyncSocket.h"

@interface MKJSocketService () <GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *serviceSocket; // 服务端socket
@property (nonatomic,strong) NSMutableArray *connectionClientSockets; // 已经链接的socket

@end

@implementation MKJSocketService

- (NSMutableArray *)connectionClientSockets
{
    if (_connectionClientSockets == nil) {
        _connectionClientSockets = [[NSMutableArray alloc] init];
    }
    return _connectionClientSockets;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        /**
         注意：这里的服务端socket，只负责socket(),bind()，lisence(),accept(),他的任务到底结束，只负责监听是否有客户端socket来连接
         */
        self.serviceSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}

- (void)connected
{
    NSError *error = nil;
    // 给一个需要连接的端口，0-1024是系统的
    [self.serviceSocket acceptOnPort:3667 error:&error];
    if (error) {
        NSLog(@"3666服务器开启失败。。。。。%@",error);
    }
    else
    {
        NSLog(@"开启成功，并开始监听");
    }
}
// 有客户端连接该服务器进行会话 Mac 终端下调用telnet IP port进行与服务器的链接，如果链接上了就会调用这个方法
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"服务器%@",sock);
    NSLog(@"客户端%@ IP:%@,%d 连接成功",newSocket,newSocket.connectedHost,newSocket.connectedPort);
    // 1.如果不用全局变量存取，直接就会推出
    [self.connectionClientSockets addObject:newSocket];
    
    // 2.连接完成之后进行 客户端的sock进行监听状态
    [newSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"已经链接的客户端:%ld",self.connectionClientSockets.count);
    
    // 3.write目的就是发送数据 有人连接到服务端之后就进行一系列响应
//    NSMutableString *options = [NSMutableString string];
//    [options appendString:@"欢迎来到东莞 请输入下面的数字选择服务\n"];
//    [options appendString:@"[0]按摩\n"];
//    [options appendString:@"[1]洗脚\n"];
//    [options appendString:@"[2]大保健\n"];
//    [options appendString:@"[3]special services\n"];
//    [options appendString:@"[4]退出\n"];
//    // 服务端发送数据
//    [newSocket writeData:[options dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}


/**
 这个是服务端的代码，这里的write就是服务器发送数据，而且这里的发送socket对象也是连接的客户端socket
 当有连接好的客户端之后发送消息给服务器，就能通过该方法受到消息，在通过消息，服务端在进行write数据给客户端展示
 */
- (void)socket:(GCDAsyncSocket *)clientSock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    for (NSInteger i = 0; i < self.connectionClientSockets.count; i++) {
        if (self.connectionClientSockets[i] == clientSock) {
            continue;
        }
        GCDAsyncSocket *socket = self.connectionClientSockets[i];
        [self writeDataWithSocket:socket message:receiveStr];
    }
    [clientSock readDataWithTimeout:-1 tag:0];
}

/**
 断开链接调用
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"失去连接了");
    NSLog(@"currentSocket:%ld",self.connectionClientSockets.count);
}


/**
 发送数据给客户端
 */
- (void)writeDataWithSocket:(GCDAsyncSocket *)socket message:(NSString *)msg
{
    [socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}


/**
 断开连接，会调用Connection closed by foreign host.
 并且发送数据到客户端
 最终从服务端的数组中移除，释放内存，断开socket

 @param socket 需要断开的客户端socket
 */
- (void)exitSocket:(GCDAsyncSocket *)socket
{
    [self writeDataWithSocket:socket message:@"离开东莞\n"];
    [self.connectionClientSockets removeObject:socket];
    NSLog(@"currentSocket:%ld",self.connectionClientSockets.count);
}

















@end
