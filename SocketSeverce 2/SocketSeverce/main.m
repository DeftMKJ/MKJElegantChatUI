//
//  main.m
//  SocketSeverce
//
//  Created by 宓珂璟 on 2017/2/1.
//  Copyright © 2017年 Deft_Mikejing_iOS_coder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKJSocketService.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        MKJSocketService *socketService = [[MKJSocketService alloc] init];
        [socketService connected];
        [[NSRunLoop mainRunLoop] run];
        
    }
    return 0;
}
