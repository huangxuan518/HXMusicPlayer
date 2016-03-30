//
//  YYMusicData.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/25.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXMusicData.h"
#import "HXMusicModel.h"

@implementation HXMusicData

static NSArray *_musics;
static  HXMusicModel *_playingMusic;

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSArray *)musics {
    if (_musics==nil) {
    
        NSMutableArray *musics = [NSMutableArray new];
        //添加plist数据 ====================
        //创建主束
        NSBundle *bundle=[NSBundle mainBundle];
        //读取plist文件路径
        NSString *path = [bundle pathForResource:@"Info" ofType:@"plist"];
        //读取数据到 NsDictionary字典中
        NSDictionary *dictionary=[[NSDictionary alloc]initWithContentsOfFile:path];
        
        NSArray *ary = dictionary[@"Root"];
        
        for (NSDictionary *dic in ary) {
            HXMusicModel *model = [HXMusicModel new];
            model.name = dic[@"name"];
            model.icon = dic[@"icon"];
            model.fileName = dic[@"fileName"];
            model.lrcName = dic[@"lrcName"];
            model.singer = dic[@"singer"];
            model.singerIcon = dic[@"singerIcon"];
            
            [musics addObject:model];
        }

        //添加网络数据
        NSString *json = @"[{\n   \"name\": \"I Believe\",\n   \"icon\": \"http://p3.music.126.net/1W118vLAePcixn_Ckg2xUQ==/1376588561547944.jpg\",\n   \"fileName\": \"http://m2.music.126.net/feplW2VPVs9Y8lE_I08BQQ==/1386484166585821.mp3\",\n   \"lrcName\": \"\",\n   \"singer\": \"张信哲\",\n   \"singerIcon\": \"\"\n\t},\n{\n   \"name\": \"LIAR LIAR\",\n   \"icon\": \"http://p3.music.126.net/THS5HMOjmKNDDCj9G0ROyQ==/1376588561547947.jpg\",\n   \"fileName\": \"http://m2.music.126.net/dUZxbXIsRXpltSFtE7Xphg==/1375489050352559.mp3\",\n   \"lrcName\": \"\",\n   \"singer\": \"OH MY GIRL\",\n   \"singerIcon\": \"\"\n\t},\n{\n   \"name\": \"正义之手\",\n   \"icon\": \"http://p4.music.126.net/xXrsv_rI6Qucb1dxibve4A==/3272146615759748.jpg\",\n   \"fileName\": \"http://m2.music.126.net/zLk1RXSKMONJye6jB3mjSA==/1407374887680902.mp3\",\n   \"lrcName\": \"\",\n   \"singer\": \"SNH48\",\n   \"singerIcon\": \"\"\n\t}\n]";
        
        NSArray *dictArray1 = [self dictionaryWithJsonString:json];
        // JSON array -> User array
        NSArray *userArray = [HXMusicModel mj_objectArrayWithKeyValuesArray:dictArray1];
        
        // Printing
        for (HXMusicModel *model in userArray) {
            
            [musics addObject:model];
        }
    
        _musics = musics;
    }
    return _musics;
}

+ (HXMusicModel *)playingMusic {
    return _playingMusic;
}

+ (void)setPlayingMusic:(HXMusicModel *)playingMusic {
    //如果传入的歌曲名不在音乐库中，那么就直接返回
    if (![[self musics] containsObject:playingMusic]) {
        return;
    }

    _playingMusic = playingMusic;
}

+ (HXMusicModel *)previousMusic {
    //设定一个初值
    NSInteger previousIndex = 0;
    if (_playingMusic) {
        //获取当前播放音乐的索引
        NSInteger playingIndex = [[self musics] indexOfObject:_playingMusic];
        //设置下一首音乐的索引
        previousIndex = playingIndex - 1;
        //检查数组越界，如果下一首音乐是最后一首，那么重置为0
        if (previousIndex < 0) {
            previousIndex = [self musics].count - 1;
        }
    }
    return [self musics][previousIndex];
}

+ (HXMusicModel *)nextMusic {
    //设定一个初值
    NSInteger nextIndex = 0;
    if (_playingMusic) {
        //获取当前播放音乐的索引
        NSInteger playingIndex = [[self musics] indexOfObject:_playingMusic];
        //设置下一首音乐的索引
        nextIndex = playingIndex + 1;
        //检查数组越界，如果下一首音乐是最后一首，那么重置为0
        if (nextIndex >= [self musics].count) {
            nextIndex = 0;
        }
    }
    
    return [self musics][nextIndex];
}

@end
