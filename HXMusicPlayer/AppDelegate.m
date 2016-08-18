//
//  AppDelegate.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "AppDelegate.h"
#import "HXMusicsViewController.h"

#import "HXMusicModel.h"
#import "HXMusicData.h"
#import "HXAudioTool.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface AppDelegate ()

@property (nonatomic,strong) NSMutableDictionary *songInfo;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    HXMusicsViewController *vc = [HXMusicsViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _songInfo = [[NSMutableDictionary alloc] init];
    [self changeNowPlayingInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - app后台模式下

- (void)changeNowPlayingInfo {
    
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        //获取播放数据
        HXMusicModel *model = [HXMusicData playingMusic];
        
        UIImage *image = [UIImage new];
        if([model.icon rangeOfString:@"http"].location != NSNotFound) {
            image = [self getImageFromURL:model.icon];
        } else {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",model.icon]];
        }
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        [_songInfo setObject:model.name forKey:MPMediaItemPropertyTitle];
        [_songInfo setObject:model.singer forKey:MPMediaItemPropertyAlbumTitle];
        [_songInfo setObject:model.singer forKey:MPMediaItemPropertyArtist];
        [_songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_songInfo];
    }
}

//计时器修改进度
- (void)changeProgress:(NSTimer *)sender {
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        //获取播放数据
        HXMusicModel *model = [HXMusicData playingMusic];
        
        //获取播放器
        id player = [HXAudioTool getAudioPlayer:model.fileName];
        double progress;
        double duration;
        
        if ([player isKindOfClass:[AudioStreamer class]]) {
            //网络歌曲
            AudioStreamer *audioStreamer = (AudioStreamer *)player;
            progress = audioStreamer.progress;
            duration = audioStreamer.duration;
        } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
            //本地歌曲
            AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
            progress = audioPlayer.currentTime;
            duration = audioPlayer.duration;
        }
        
        [_songInfo setObject:[NSNumber numberWithDouble:progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
        [_songInfo setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲剩余时间设置
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_songInfo];
    }
}

- (UIImage *)getImageFromURL:(NSString *)fileURL {
    
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}

@end
