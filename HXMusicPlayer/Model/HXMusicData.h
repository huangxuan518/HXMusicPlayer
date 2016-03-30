//
//  HXMusicData.h
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/25.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXMusicModel;

@interface HXMusicData : NSObject

/**
 *  返回所有的歌曲数据
 *
 *  @return <#return value description#>
 */
+ (NSArray *)musics;

/**
 *  返回当前歌曲数据
 *
 *  @return <#return value description#>
 */
+ (HXMusicModel *)playingMusic;

/**
 *  设置当前歌曲数据
 *
 *  @param playingMusic <#playingMusic description#>
 */
+ (void)setPlayingMusic:(HXMusicModel *)playingMusic;

/**
 *  上一首歌曲数据
 *
 *  @return <#return value description#>
 */
+ (HXMusicModel *)previousMusic;

/**
 *  下一首歌曲数据
 *
 *  @return <#return value description#>
 */
+ (HXMusicModel *)nextMusic;

@end
