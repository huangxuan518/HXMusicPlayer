//
//  HXMusicModel.h
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/24.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface HXMusicModel : NSObject

@property (nonatomic,copy) NSString *name;//歌曲名字
@property (nonatomic,copy) NSString *icon;//歌曲大图
@property (nonatomic,copy) NSString *fileName;//歌曲的文件名
@property (nonatomic,copy) NSString *lrcName;//歌词的文件名
@property (nonatomic,copy) NSString *singer;//歌手
@property (nonatomic,copy) NSString *singerIcon;//歌手图标

@end
