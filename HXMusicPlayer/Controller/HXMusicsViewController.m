//
//  HXMusicsViewController.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/24.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXMusicsViewController.h"
#import "HXPlayingViewController.h"
#import "HXMusicCell.h"
#import "HXMusicModel.h"
#import "HXMusicData.h"

@interface HXMusicsViewController ()

@property (nonatomic,strong) NSArray *musics;

@end

@implementation HXMusicsViewController

#pragma mark-懒加载
- (NSArray *)musics {
    if (!_musics) {
        _musics = [HXMusicData musics];
    }
    return _musics;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的音乐列表";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXMusicCell *cell = [HXMusicCell cellWithTableView:tableView];
    cell.music = self.musics[indexPath.row];
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HXPlayingViewController *vc = [HXPlayingViewController new];
    //设置播放数据
    [HXMusicData setPlayingMusic:self.musics[indexPath.row]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end