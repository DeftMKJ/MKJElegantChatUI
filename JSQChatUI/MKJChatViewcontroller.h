//
//  MKJChatViewcontroller.h
//  JSQChatUI
//
//  Created by MKJING on 2016/12/17.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "DemoModelData.h"

@interface MKJChatViewcontroller : JSQMessagesViewController<UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>


@property (strong, nonatomic) DemoModelData *demoData; //!< 消息模型

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

@end
