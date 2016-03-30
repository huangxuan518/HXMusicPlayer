//
//  HXMusicCell.h
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/24.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMusicModel;

@interface HXMusicCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic,strong) HXMusicModel *music;

@end
