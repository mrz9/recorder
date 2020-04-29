//
//  AMRRecorder.m
//  AwesomeForPassenger
//
//  Created by adam on 2018/11/2.
//  Copyright © 2018年 Raymond. All rights reserved.
//

#import "AMRRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConvert.h"
#import "RecorderUtil.h"

@interface AMRRecorder()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSString *CAFPath;
@property (nonatomic, strong) NSMutableDictionary *recordParams;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy)NSString *fileName;

@end

@implementation AMRRecorder

- (instancetype)initWithDelegate:(id<AMRRecorderDelegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
        self.recordParams = [[NSMutableDictionary alloc] init];
        [self.recordParams setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];//录音格式 无法使用
        [self.recordParams setValue :[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];//采样率 44100.0
        [self.recordParams setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];//通道数
        [self.recordParams setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];//音频质量,采样质量
        [self.recordParams setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//比特率 一般设16 32
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsNonInterleaved];//AVLinear PCMI 非交叉密钥
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];//采样信号是整数还是浮点数他的值是波尔值也是PCM专属
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];//即大端模式和小端模式，可以理解为一段数据再内存中的起始位置以及终止位置他的值是波尔值这个key也是PCM专属
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        self.recordParams = [[NSMutableDictionary alloc] init];
        [self.recordParams setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];//录音格式 无法使用
        [self.recordParams setValue :[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];//采样率 44100.0
        [self.recordParams setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];//通道数
        [self.recordParams setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];//音频质量,采样质量
        [self.recordParams setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//比特率 一般设16 32
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsNonInterleaved];//AVLinear PCMI 非交叉密钥
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];//采样信号是整数还是浮点数他的值是波尔值也是PCM专属
        [self.recordParams setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];//即大端模式和小端模式，可以理解为一段数据再内存中的起始位置以及终止位置他的值是波尔值这个key也是PCM专属
    }
    return self;
}

- (void)startRecord{
    [self startRecord:nil];
}

#pragma mark - 开始录音
- (void)startRecord:(NSString*)fileName{
    
    self.fileName = fileName;//wav本地文件名
    if (fileName == nil) {
        self.fileName = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    }
    
    //每次重新生成新的wav文件
    self.CAFPath = [RecorderUtil CreateWavFile:self.fileName];
    //1. 设置session
    self.session = [AVAudioSession sharedInstance];
    NSError *error;
    [self.session setCategory:AVAudioSessionCategoryMultiRoute error:&error];
    if(self.session == nil){
        NSLog(@"Error creating session: %@", error.description);
    }else {
        [self.session setActive:YES error:nil];
    }
    //2.重新初始化 AVAudioRecorder
    self.recorder = nil;
    NSURL *url = [NSURL fileURLWithPath:self.CAFPath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recordParams error:&error];
    if (error != nil) {
        NSLog(@"%@", error.description);
    }
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    [self.recorder prepareToRecord];
    [self.recorder record];//开始录音
    [self.timer invalidate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)finish{
    [self.timer invalidate];
    self.timer = nil;
    double recordTime = self.recorder.currentTime;
    [self.recorder stop];
    if (recordTime > 0) {//录音时间大于1秒, 录音有效
        [self parseToAMR: recordTime];
    }else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.recorder.url.path]) {
            if (![self.recorder deleteRecording])//删除文件
                NSLog(@"Failed to delete %@", self.recorder.url);
        }
        if ([self.delegate respondsToSelector:@selector(failRecord)]) {//录音时间少于1秒, 录音有无效
            [self.delegate failRecord];
        }
    }
}

#pragma mark - 取消录音
- (void)cancelRecord{
    [self.timer invalidate];
    self.timer = nil;
    [self.recorder stop];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recorder.url.path]) {
        if (![self.recorder deleteRecording]){
            NSLog(@"Failed to delete %@", self.recorder.url);
        }
    }
}

- (void)parseToAMR:(double)recordTime{
    NSString *wavFilePath = self.CAFPath;
    NSData *voiceData = [NSData dataWithContentsOfFile:wavFilePath];
    NSLog(@"wav = %@", voiceData);
    NSString *amrFilePath = [RecorderUtil CreateAmrFile:nil];
    if (self.delegate && [_delegate respondsToSelector:@selector(onConvertBegin)]) {
        [_delegate onConvertBegin];
    }
    if (wavFilePath != nil && [VoiceConvert ConvertWavToAmr:wavFilePath amrSavePath:amrFilePath]) {
        if (_delegate && [_delegate respondsToSelector:@selector(onConvertSuccess:fileName:path:recordTime:)]) {
            [_delegate onConvertSuccess:amrFilePath fileName:self.fileName path:wavFilePath recordTime:recordTime];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(failRecord)]) {//wav转amr失败
            [self.delegate failRecord];
        }
        NSLog(@"wav转amr失败");
    }
}

// 音量
- (void)detectionVoice {
    [self.recorder updateMeters];//刷新音量数据
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    if ([self.delegate respondsToSelector:@selector(volumeChange:)]) {
        [self.delegate volumeChange:lowPassResults];
    }
    if (self.recorder.currentTime >= 60) {
        [self finish];
    }
}

@end
