//
//  HXAudioTool.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/25.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXAudioTool.h"
#import "AudioStreamer.h"
#import <AVFoundation/AVFoundation.h>

@implementation HXAudioTool

/**
 *存放所有的音乐播放器
*/
static NSMutableDictionary *_musicPlayers;
+ (NSMutableDictionary *)musicPlayers {
    if (_musicPlayers == nil) {
        _musicPlayers = [NSMutableDictionary dictionary];
    }
    return _musicPlayers;
}

+ (id)getAudioPlayer:(NSString *)fileName {
    
    if (!fileName) {
        //如果没有传入文件名，那么直接返回
        return nil;
    }
    
    //1.取出对应的播放器
    id player = [self musicPlayers][fileName];
    
    if (!player) {
        
        if([fileName rangeOfString:@"http"].location != NSNotFound) {
            //网络音乐
            NSURL *url = [NSURL URLWithString:fileName];
            player = [[AudioStreamer alloc] initWithURL:url];
        } else {
            //本地音乐
            //音频文件的URL
            NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
            //根据url创建播放器
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            
            AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
            if (![audioPlayer prepareToPlay]) {
                //如果缓冲失败，那么就直接返回
                return nil;
            }
        }
        
        //存入字典
        [self musicPlayers][fileName] = player;
    }
    
    return player;
}

+ (void)playMusic:(NSString *)fileName {
    if (!fileName) {
        //如果没有传入文件名,那么直接返回
        return;
    }
    
    id player = [self getAudioPlayer:fileName];
    
    if ([player isKindOfClass:[AudioStreamer class]]) {
        //网络音乐
        AudioStreamer *streamer = (AudioStreamer *)player;
        [streamer start];
    } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
        AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
        //暂停
        [audioPlayer play];
    }
}

+ (void)pauseMusic:(NSString *)fileName {
    if (!fileName) {
        //如果没有传入文件名,那么直接返回
        return;
    }

    id player = [self getAudioPlayer:fileName];
    
    if ([player isKindOfClass:[AudioStreamer class]]) {
        //网络音乐
        AudioStreamer *streamer = (AudioStreamer *)player;
        [streamer pause];
    } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
        AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
        //暂停
        [audioPlayer pause];
    }
}

+ (void)stopMusic:(NSString *)fileName {
    if (!fileName) {
        //如果没有传入文件名，那么就直接返回
        return;
    }
    
    id player = [self getAudioPlayer:fileName];
    
    if ([player isKindOfClass:[AudioStreamer class]]) {
        //网络音乐
        AudioStreamer *streamer = (AudioStreamer *)player;
        [streamer stop];
    } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
        AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
        //暂停
        [audioPlayer stop];
    }
    
    //3.将播放器从字典中移除
    [[self musicPlayers] removeObjectForKey:fileName];
}

/**
 *存放所有的音效ID
 */
static NSMutableDictionary *_soundIDs;
+ (NSMutableDictionary *)soundIDs {
    if (_soundIDs == nil) {
        _soundIDs=[NSMutableDictionary dictionary];
    }
    return _soundIDs;
}

+ (void)playSound:(NSString *)fileName {
    if (!fileName) {
        return;
    };
    //1.取出对应的音效
    SystemSoundID soundID = [[self soundIDs][fileName] unsignedIntValue];

    //2.播放音效
    //2.1如果音效ID不存在，那么就创建
    if (!soundID) {
        //音效文件的URL
        NSURL *url = [[NSBundle mainBundle]URLForResource:fileName withExtension:nil];
        if (!url) return;//如果URL不存在，那么就直接返回

        OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        NSLog(@"%d",(int)status);
        //存入到字典中
        [self soundIDs][fileName] = @(soundID);
    }
        
    //2.2有音效ID后，播放音效
    AudioServicesPlaySystemSound(soundID);
}

+ (void)disposeSound:(NSString *)fileName {
    //如果传入的文件名为空，那么就直接返回
    if (!fileName) {
        return;
    };

     //1.取出对应的音效
     SystemSoundID soundID = [[self soundIDs][fileName] unsignedIntValue];

     //2.销毁
     if (soundID) {
         AudioServicesDisposeSystemSoundID(soundID);
         //2.1销毁后，从字典中移除
         [[self soundIDs]removeObjectForKey:fileName];
     }
}

@end
