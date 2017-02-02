//
//  MKJChatViewcontroller.m
//  JSQChatUI
//
//  Created by MKJING on 2016/12/17.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "MKJChatViewcontroller.h"
#import <GCDAsyncSocket.h>

@interface MKJChatViewcontroller () <GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *clientSocket;// 客户端链接的Socket

@end

@implementation MKJChatViewcontroller

- (void)dealloc
{
    NSLog(@"dealloc--->%s",object_getClassName(self));
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    // 1.读取数据
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([dataStr isEqualToString:@"\r\n"]) {
        return;
    }
    if ([dataStr containsString:@"\r"] || [dataStr containsString:@"\n"]) {
        dataStr = [dataStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        dataStr = [dataStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = YES;
    
    /**
     *  Scroll to actually view the indicator 滚动到最后
     */
    [self scrollToBottomAnimated:YES];
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:dataStr];
        
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        // 播放声音
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
    });

    // 2.添加到数据源
//    [self.dataSource addObject:dataStr];
    
    // 3.刷新数据
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self.tableView reloadData];
//    }];
    
    // 4.每次接收完数据，都要再次监听数据
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark socket代理
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接主机成功");
    // 监听数据
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"连接主机失败 %@",err);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 连接到聊天服务器
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    [socket connectToHost:@"127.0.0.1" onPort:3667 error:nil];
    self.clientSocket = socket;
    
    
    
    self.title = @"嗨起来";
    
    // 键盘上面的那个toolbar
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    
    /**
     *  Load up our fake data for the demo
     */
    // 初始化fake消息模型
    self.demoData = [[DemoModelData alloc] init];
    
    
    
    /**
     *  You can set custom avatar sizes
     */
    // 自定义头像View的大小，外部没有进行配置的话
//    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
//    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // 更早的消息按钮展示
    self.showLoadEarlierMessagesHeader = YES;
    
    // 导航栏右侧被发送消息，就是接受到的消息按钮模拟
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
    
    /**
     *  Register custom menu actions for cells.
     */
    // 注册custom按钮，允许自定义
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    
    /**
     *  OPT-IN: allow cells to be deleted
     */
    // 注册delelte按钮，允许被删除
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    // 自定义toolbar左侧和右侧按钮UI
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /**
     *  Set a maximum height for the input toolbar
     *  设置toolbar最大高度
     *  self.inputToolbar.maximumHeight = 150;
     */

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    // 一个bubbles的移动动画效果
    self.collectionView.collectionViewLayout.springinessEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kDynamic"] boolValue];
}

#pragma mark - Custom menu actions for cells
// 自定义action的文案按钮
- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    /**
     *  Display custom menu actions for cells.
     */
    UIMenuController *menu = [notification object];
    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
    
    [super didReceiveMenuWillShowNotification:notification];
}


#pragma mark - Actions
// 收到别人发的消息了
- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = YES;
    
    /**
     *  Scroll to actually view the indicator 滚动到最后
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        // JSQMessage对应的BOOL isMediaMessage = NO就是text，YES就是图片，音频，视频，定位
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            // 先把代理存储下
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            // 如果是图片
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                // 默认都是YES的，这句话的意思是气泡的小尖尖朝哪个方向，YES是发出去的，就朝右，反之
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 *  代表发出去的消息会进行短暂的loading
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                // 坐标消息  同上
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                // 视频消息 同上
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                // 同上
                JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [audioItemCopy.audioData copy];
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            // 除开Text外的消息类
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            /**
             *  Last message was a text message  消息类
             */
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        // 播放声音
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        
        // 如果消息类型是Media  非文本形式
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media  模拟下载
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                    ((JSQAudioMediaItem *)newMediaData).audioData = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}


#pragma mark - JSQMessagesViewController method overrides
// 纯文本发送
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    // 套路三部曲 直接完成组装
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SOCKET"]) {
        [self.clientSocket writeData:[text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [self.clientSocket readDataWithTimeout:-1 tag:0];
    }
    // 发送数据到服务器
    
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.demoData.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}


// 点击左侧accessory按钮启动actionSheet
- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Send photo", nil), NSLocalizedString(@"Send location", nil), NSLocalizedString(@"Send video", nil), NSLocalizedString(@"Send video thumbnail", nil), NSLocalizedString(@"Send audio", nil), nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

// 点击左侧accessory按钮弹出sheet，选择需要发送的事件添加到数据源
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self.demoData addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            break;
            
        case 3:
            [self.demoData addVideoMediaMessageWithThumbnail];
            break;
            
        case 4:
            [self.demoData addAudioMediaMessage];
            break;
    }
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}

// 发送的人ID
- (NSString *)senderId {
    return kJSQDemoAvatarIdSquires;
}
// 发送人名字
- (NSString *)senderDisplayName {
    return kJSQDemoAvatarDisplayNameSquires;
}
// 根据index返回需要加载的message对象
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

// 删除消息
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

// 聊天气泡，根据ID判断是发送的还是接受的
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

// 头像
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

// 时间UI
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

// 除本人以外显示bubble cell上面的名字
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

// 气泡cell底部文字
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 文本直接进行布局
//    if (!isMediaMessage) {
//        cell.textView.text = [messageItem text];
//        
//        if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
//            //  workaround for iOS 7 textView data detectors bug
//            cell.textView.text = nil;
//            cell.textView.attributedText = [[NSAttributedString alloc] initWithString:[messageItem text]
//                                                                           attributes:@{ NSFontAttributeName : collectionView.collectionViewLayout.messageBubbleFont }];
//        }
//        
//        NSParameterAssert(cell.textView.text != nil);
//        
//        id<JSQMessageBubbleImageDataSource> bubbleImageDataSource = [collectionView.dataSource collectionView:collectionView messageBubbleImageDataForItemAtIndexPath:indexPath];
//        cell.messageBubbleImageView.image = [bubbleImageDataSource messageBubbleImage];
//        cell.messageBubbleImageView.highlightedImage = [bubbleImageDataSource messageBubbleHighlightedImage];
//    }
//    else {
    // 文本的话先获取data里面的JSQMessage对象，这个对象都有个JSQAudioMediaItem对象，一共好多种类型，每个类型都有一个对应的item，然后不同的item里面根据需求有个mediaView进行布局，这里直接返回给cell布局
//        id<JSQMessageMediaData> messageMedia = [messageItem media];
//        cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
//        NSParameterAssert(cell.mediaView != nil);
//    }
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor redColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    // 是否是自定义的action
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

// 自定义弹框
- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

// cell气泡上面的时间高度，出来就给默认20  3个给一个
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

// cell气泡上面的人名字高度  发送人不需要  和上一个重名也不需要  不然默认给20
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

// cell底部展示文案的高度
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

// 点击cell边缘头部或者底部的 时间或者名字点击事件
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

// 粘贴的是Media的话就自己配置返回NO，YES就是发送文字
- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods

// 调用这段代码 shouldShowAccessoryButtonForMessage
// cell左右侧出现的标签按钮事件回调
- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
