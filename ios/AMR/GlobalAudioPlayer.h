//
//  GlobalAudioPlayer.h
//  AwesomeForPassenger
//
//  Created by adam on 2018/11/3.
//  Copyright © 2018年 Raymond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalAudioPlayer : NSObject

+ (instancetype)shareInstance;

- (BOOL)isPlaying;
- (BOOL)play:(NSString*)sUrl;
- (void)stopPlay;
//震动
- (void)shakeWhenMessageArived;

@end

