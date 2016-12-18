//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "JSQMessages.h"

/**
 *  This is for demo/testing purposes only. 
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Jesse Squires";
static NSString * const kJSQDemoAvatarDisplayNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarDisplayNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarDisplayNameWoz = @"Steve Wozniak";

static NSString * const kJSQDemoAvatarIdSquires = @"053496-4509-289";
static NSString * const kJSQDemoAvatarIdCook = @"468-768355-23123";
static NSString * const kJSQDemoAvatarIdJobs = @"707-8956784-57";
static NSString * const kJSQDemoAvatarIdWoz = @"309-41802-93823";



@interface DemoModelData : NSObject

/*
 *  这里放的都是JSQMessage对象 该对象有两个初始化方式 1.media or noMedia
 */

@property (strong, nonatomic) NSMutableArray *messages; // message数组

@property (strong, nonatomic) NSDictionary *avatars; // 聊天人所有头像

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData; // 发出去的气泡颜色

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData; // 收到的气泡颜色

@property (strong, nonatomic) NSDictionary *users; // 用户名字信息

- (void)addPhotoMediaMessage;//!< 图片消息

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion; //!< 定位小心

- (void)addVideoMediaMessage; //!< 视频 无底图

- (void)addVideoMediaMessageWithThumbnail; //!< 视频带底图

- (void)addAudioMediaMessage; //!< 音频

@end
