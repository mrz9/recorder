//
//  AMRRecorder.h
//  AwesomeForPassenger
//
//  Created by adam on 2018/11/2.
//  Copyright © 2018年 Raymond. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMRRecorderDelegate <NSObject>

- (void)volumeChange:(double)volume;
- (void)failRecord;
- (void)onConvertBegin;
/*
 *
 *voiceData: amr data
 *path: wav file path
 *
 */
- (void)onConvertSuccess:(NSString*)amrPath fileName:(NSString*)fileName path:(NSString*)wavPath recordTime:(double)time;

@end

@interface AMRRecorder : NSObject

@property (nonatomic, weak) id<AMRRecorderDelegate> delegate;

- (instancetype)initWithDelegate:(id<AMRRecorderDelegate>)delegate;
- (void)startRecord;
- (void)startRecord:(NSString*)fileName;
- (void)finish;
- (void)cancelRecord;

@end

