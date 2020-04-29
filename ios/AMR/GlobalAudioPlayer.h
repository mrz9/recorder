//
//  GlobalAudioPlayer.h
//  AwesomeForPassenger
//
//  Created by adam on 2018/11/3.
//  Copyright © 2018年 Raymond. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

- (void)onPlayFinish;

@end

@interface GlobalAudioPlayer : NSObject

+ (instancetype)shareInstance;

@property(nonatomic, weak) id<PlayerDelegate> delegate;

- (BOOL)isPlaying;
- (BOOL)play:(NSString*)sUrl;
- (void)stopPlay;
//震动
- (void)shakeWhenMessageArived;

@end

