//
//  AppDelegate.h
//  HXMusicPlayDemo
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGMMainScreenWidth            ([[UIScreen mainScreen] bounds].size.width)
#define CGMMainScreenHeight           ([[UIScreen mainScreen] bounds].size.height)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)changeNowPlayingInfo;
- (void)changeProgress:(NSTimer *)sender;

@end

