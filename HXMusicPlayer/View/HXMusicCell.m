//
//  HXMusicCell.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/24.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXMusicCell.h"
#import "HXMusicModel.h"
#import "UIImageView+WebCache.h"

@implementation HXMusicCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ID";
    HXMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[HXMusicCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (void)setMusic:(HXMusicModel *)music {
    _music = music;
    self.textLabel.text = music.name;
    self.detailTextLabel.text = music.singer;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:music.singerIcon] completed:nil];
}

@end
