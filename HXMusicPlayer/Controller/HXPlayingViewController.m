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

#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

@interface HXPlayingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//标题
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;//歌手
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;//音乐图
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;//播放时间
@property (weak, nonatomic) IBOutlet UILabel *entTimeLabel;//结束时间
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;//进度条
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseMusicButton;//播放/暂停按钮
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) MPMediaItemArtwork *albumArt;

@end

@implementation HXPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //刷新UI
    [self refreshUI];
}

- (void)changeTrackTitles
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter)
    {
        //获取播放数据
        HXMusicModel *model = [HXMusicData playingMusic];
        
        UIImage *image = nil;
        if([model.icon rangeOfString:@"http"].location != NSNotFound) {
            image = [self getImageFromURL:model.icon];
        } else {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",model.icon]];
        }
        
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
        
        _albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:model.name forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:model.singer forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:model.singer forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:_albumArt forKey:MPMediaItemPropertyArtwork];
        
        [songInfo setObject:[NSNumber numberWithDouble:progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
        [songInfo setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
        
//        //音乐当前播放时间 在计时器中修改
//        [songInfo setObject:[NSNumber numberWithDouble:duration] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

//计时器修改进度
- (void)changeProgress:(NSTimer *)sender{
//    if(self.player){
//        //当前播放时间
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
//        [dict setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//        
//    }
}

- (UIImage *)getImageFromURL:(NSString *)fileURL {
    
    NSLog(@"执行图片下载函数");
    
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

//received remote event
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    //type==2  subtype==单击暂停键：103，双击暂停键104
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:{
                NSLog(@"play---------");
                [self playOrPauseMusicButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlPause:{
                NSLog(@"Pause---------");
                [self playOrPauseMusicButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlStop:{
                NSLog(@"Stop---------");
                [self stopButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlTogglePlayPause:{
                //单击暂停键：103
                NSLog(@"单击暂停键：103");
                [self playOrPauseMusicButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlNextTrack:{
                //双击暂停键：104
                NSLog(@"双击暂停键：104");
                [self nextMusicButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                NSLog(@"三击暂停键：105");
                [self previousMusicButtonAction:nil];
            }break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:{
                NSLog(@"单击，再按下不放：108");
            }break;
            case UIEventSubtypeRemoteControlEndSeekingForward:{
                NSLog(@"单击，再按下不放，松开时：109");
            }break;
            default:
                break;
        }
    }
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
    
    [self stopButtonAction:sender];
    
    //返回前一个页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopButtonAction:(UIButton *)sender {
    //获取播放数据
    HXMusicModel *model = [HXMusicData playingMusic];
    
    //停止播放的歌曲
    [HXAudioTool stopMusic:model.fileName];
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
    [self stopButtonAction:sender];
    
    //设置数据为播放数据
    [HXMusicData setPlayingMusic:[HXMusicData previousMusic]];
    
    //刷新界面显示
    [self refreshUI];
}

//下一首
- (IBAction)nextMusicButtonAction:(UIButton *)sender {
    [self stopButtonAction:sender];
    
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
    [self changeTrackTitles];
    
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
