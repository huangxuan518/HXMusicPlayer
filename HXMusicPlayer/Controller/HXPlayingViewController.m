//
//  HXPlayingViewController.m
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/25.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXPlayingViewController.h"
#import "AudioStreamer.h"
#import "AppDelegate.h"
#import "HXAudioTool.h"
#import "HXMusicModel.h"
#import "HXMusicData.h"
#import "UIImageView+WebCache.h"

@interface HXPlayingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//标题
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;//歌手
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;//音乐图
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;//播放时间
@property (weak, nonatomic) IBOutlet UILabel *entTimeLabel;//结束时间
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;//进度条
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseMusicButton;//播放/暂停按钮
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation HXPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //刷新UI
    [self refreshUI];
}

//刷新界面显示
- (void)refreshUI {
    
    //获取播放数据
    HXMusicModel *model = [HXMusicData playingMusic];

    _nameLabel.text = model.name;
    _singerLabel.text = model.singer;

    
    if([model.icon rangeOfString:@"http"].location != NSNotFound) {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] completed:nil];
    } else {
        _iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",model.icon]];
    }

    [_playOrPauseMusicButton setBackgroundImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateNormal];
    [_playOrPauseMusicButton setBackgroundImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateHighlighted];
    
    //播放音乐
    [HXAudioTool playMusic:model.fileName];
    
    //开始计时器
    [self start];
}

#pragma mark - 播放器操作

//返回
- (IBAction)backButtonAction:(UIButton *)sender {
    //销毁计时器
    [self setTimerValid];
    
    //获取播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //停止播放的歌曲
    [HXAudioTool stopMusic:model.fileName];
    
    //返回前一个页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

//播放/暂停
- (IBAction)playOrPauseMusicButtonAction:(UIButton *)sender {
    //获取播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //获取播放器
    id player = [HXAudioTool getAudioPlayer:model.fileName];

    BOOL playing;
    if ([player isKindOfClass:[AudioStreamer class]]) {
        //网络歌曲
        AudioStreamer *audioStreamer = (AudioStreamer *)player;
        playing = audioStreamer.isPlaying;
    } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
        //本地歌曲
        AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;
        playing = audioPlayer.isPlaying;
    }
    
    if (playing) {
        [sender setBackgroundImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateHighlighted];
        
        //播放
        [HXAudioTool pauseMusic:model.fileName];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateHighlighted];
        
        //如果暂停,则播放
        [HXAudioTool playMusic:model.fileName];
    }
}

//上一首
- (IBAction)previousMusicButtonAction:(UIButton *)sender {
    //获取当前播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //停止之前的播放器
    [HXAudioTool stopMusic:model.fileName];
    
    //设置数据为播放数据
    [HXMusicData setPlayingMusic:[HXMusicData previousMusic]];
    
    //刷新界面显示
    [self refreshUI];
}

//下一首
- (IBAction)nextMusicButtonAction:(UIButton *)sender {
    //获取当前播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //停止之前的播放器
    [HXAudioTool stopMusic:model.fileName];
    
    //设置数据为播放数据
    [HXMusicData setPlayingMusic:[HXMusicData nextMusic]];

    //刷新界面显示
    [self refreshUI];
}

/**
 *  开始计时器
 */
- (void)start {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
}

/**
 *  结束计时器
 */
- (void)setTimerValid {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (IBAction)sliderMoved:(UISlider *)slider {
    //获取播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //获取播放器
    id player = [HXAudioTool getAudioPlayer:model.fileName];

    if ([player isKindOfClass:[AudioStreamer class]]) {
        //网络歌曲
        AudioStreamer *audioStreamer = (AudioStreamer *)player;

        if (audioStreamer.duration) {
            double newSeekTime = slider.value * audioStreamer.duration;
            [audioStreamer seekToTime:newSeekTime];
        }
    } else if ([player isKindOfClass:[AVAudioPlayer class]]) {
        //本地歌曲
        AVAudioPlayer *audioPlayer = (AVAudioPlayer *)player;

        if (!audioPlayer.isPlaying) {
            //开始播放器
            [audioPlayer play];
        }
        //设置播放时间的推进
        audioPlayer.currentTime = slider.value * audioPlayer.duration;
    }
    
    //开始计时器
    [self start];
}

- (void)updateProgress:(NSTimer *)updatedTimer {
    
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
    
    _nameLabel.text = model.name;
    _singerLabel.text = model.singer;
    _playingTimeLabel.text = [self setCurrentTime:progress];
    _entTimeLabel.text = [self setCurrentTime:duration];
    _progressSlider.value = progress/duration;
    
    if ((int)progress >= (int)duration - 1) {
        _playingTimeLabel.text = [self setCurrentTime:duration];
        [self nextMusicButtonAction:nil];
    }
}

- (NSString *)setCurrentTime:(NSTimeInterval)currentTime {
    int minute = currentTime / 60;
    int second = (int)currentTime % 60;
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute,second];
    return currentTimeStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
