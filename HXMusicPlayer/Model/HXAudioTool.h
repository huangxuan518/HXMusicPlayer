//
//  HXAudioTool.h
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/25.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioStreamer.h"

@interface HXAudioTool : NSObject

/**
 *  获取播放器
 *
 *  @param fileName <#fileName description#>
 *
 *  @return 返回播放器 id AudioStreamer网络播放器  AVAudioPlayer本地播放器
 */
+ (id)getAudioPlayer:(NSString *)fileName;

/**
 *  播放音乐
 *
 *  @param fileName <#fileName description#>
 *
 *  @return <#return value description#>
 */
+ (void)playMusic:(NSString *)fileName;

/**
 *  暂停播放
 *
 *  @param fileName <#fileName description#>
 */
+ (void)pauseMusic:(NSString *)fileName;

/**
 *  停止音乐
 *
 *  @param fileName <#fileName description#>
 */
+ (void)stopMusic:(NSString *)fileName;

/**
 *  播放音效文件
 *
 *  @param fileName <#fileName description#>
 */
+ (void)playSound:(NSString *)fileName;

/**
 *  销毁音效
 *
 *  @param fileName <#fileName description#>
 */
+ (void)disposeSound:(NSString *)fileName;

@end
