//
//  GlobalAudioPlayer.m
//  AwesomeForPassenger
//
//  Created by adam on 2018/11/3.
//  Copyright © 2018年 Raymond. All rights reserved.
//

#import "GlobalAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GlobalAudioPlayer ()<AVAudioPlayerDelegate>{
    NSString *playingUrl;
}

@property(nonatomic, strong)AVAudioPlayer *player;

@end

@implementation GlobalAudioPlayer

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static GlobalAudioPlayer *instance;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalAudioPlayer alloc] init];
    });
    return instance;
}

- (BOOL)isPlaying {
    return self.player != nil;
}

- (BOOL)play:(NSString*)sUrl {
    if (sUrl != nil ) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,sizeof (audioRouteOverride),&audioRouteOverride);
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        [self stopPlay];
        playingUrl = sUrl;
        
        NSError *error;
        NSURL *url = [NSURL fileURLWithPath:sUrl];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];//播放出错的情况也要处理一下，可默认播下一个
        if (self.player != nil && error == nil) {
            self.player.volume = 1.0f;
            [self.player prepareToPlay];
            self.player.delegate = self;
            [self.player play];
            return YES;
        }
    }
    return NO;
}

- (void)stopPlay {
    if (self.player != nil) {
        [self.player stop];
        self.player.delegate = nil;
        self.player = nil;
    }
    playingUrl = nil;
}

#pragma mark - AVAudioPlayerDelegate Method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    playingUrl = nil;
    self.player.delegate = nil;
    self.player = nil;
}

//震动
- (void)shakeWhenMessageArived {
    dispatch_async(dispatch_get_main_queue(), ^{
        //调用提示音，非系统音（静音模式下，调用系统音，系统音会转换成一次震动）
        int soundID = 1007;
        AudioServicesPlayAlertSound(soundID);
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
            //声音播放完毕，并震动完成后调用的代码块
        });
    });
}

@end
