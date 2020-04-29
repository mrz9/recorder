//
//  aochuangRecorderAppModule.m
//  Pods
//

#import "aochuangRecorderAppModule.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import "AMRRecorder.h"
#import "GlobalAudioPlayer.h"
#import "RecorderUtil.h"

@interface aochuangRecorderAppModule ()<AMRRecorderDelegate, PlayerDelegate>

@property (nonatomic, strong) AMRRecorder *recorder;
@property (nonatomic, strong) WXModuleKeepAliveCallback callback;
@property (nonatomic, strong) WXModuleKeepAliveCallback playCallback;

@end

@implementation aochuangRecorderAppModule

@synthesize weexInstance;

WX_PlUGIN_EXPORT_MODULE(aochuangRecorder, aochuangRecorderAppModule)
WX_EXPORT_METHOD(@selector(start::))
WX_EXPORT_METHOD(@selector(stop::))
WX_EXPORT_METHOD(@selector(finish:))
WX_EXPORT_METHOD(@selector(play:::))
WX_EXPORT_METHOD(@selector(stopPlay:))

- (AMRRecorder*)getAmrRecorder{
    static AMRRecorder *instance;
    if (instance == nil){
        instance = [[AMRRecorder alloc] init];
    }
    instance.delegate = self;
    return instance;
}

//回调演示
- (void)start:(NSDictionary*)options :(WXModuleKeepAliveCallback)callback {
    [[self getAmrRecorder] startRecord];
    if (callback != nil){
        callback(@{@"message":@"success", @"code":@1}, true);
    }
}

- (void)stop:(NSDictionary*)options :(WXModuleKeepAliveCallback)callback {
    [[self getAmrRecorder] cancelRecord];
    if (callback != nil){
        callback(@{@"message":@"success", @"code":@1}, true);
    }
}

- (void)finish:(WXModuleKeepAliveCallback)callback {
    self.callback = callback;
    [[self getAmrRecorder] finish];
}

- (void)play:(NSString*)url :(NSInteger)mode :(WXModuleKeepAliveCallback)callback {
    self.playCallback = callback;
    if ([url hasPrefix:@"http://"] == YES || [url hasPrefix:@"https://"] == YES || [url hasPrefix:@"ftp://"] == YES){
        [RecorderUtil downloadFile:url handler:^(NSString * _Nonnull wavPath) {
            if (wavPath != nil){
                [GlobalAudioPlayer shareInstance].delegate = self;
                BOOL result = [[GlobalAudioPlayer shareInstance] play:wavPath];
                if (result == YES){
                    if (callback != nil){
                        callback(@{@"message":@"start", @"code":@1}, true);
                    }
                    return;
                }
            }
            if (callback != nil){
                callback(@{@"message":@"error", @"code":@-1}, true);
            }
        }];
    }else{
        NSString *wavPath = url;
        if ([url hasSuffix:@".amr"] == YES){
            wavPath = nil;
            wavPath = [RecorderUtil ConvertAmrToWav:url];
        }
        if (wavPath != nil && wavPath.length > 0 && [wavPath hasSuffix:@".wav"] == YES){
            [GlobalAudioPlayer shareInstance].delegate = self;
            BOOL result = [[GlobalAudioPlayer shareInstance] play:wavPath];
            if (result == YES){
                if (callback != nil){
                    callback(@{@"message":@"start", @"code":@1}, true);
                }
                return;
            }
        }
        if (callback != nil){
            callback(@{@"message":@"error", @"code":@-1}, true);
        }
    }
}

- (void)stopPlay:(WXModuleKeepAliveCallback)callback {
    [[GlobalAudioPlayer shareInstance] stopPlay];
    if (callback != nil) {
        callback(@{@"message":@"success", @"code":@1}, true);
    }
}

#pragma mark - AMRRecorderDelegate Method
- (void)volumeChange:(double)volume {}

- (void)failRecord {
    if (self.callback != nil) {
        self.callback(@{@"message":@"error", @"code":@-1}, true);
    }
}

- (void)onConvertBegin {}
 
- (void)onConvertSuccess:(NSString*)amrPath fileName:(NSString*)fileName path:(NSString*)wavPath recordTime:(double)time{
    if (self.callback != nil) {
        self.callback(@{@"message":@"success", @"path":amrPath, @"wavPath":wavPath, @"duraction":[NSNumber numberWithDouble:time]}, true);
    }
}

#pragma mark - PlayerDelegate Method
- (void)onPlayFinish{
    if (self.playCallback != nil){
        self.playCallback(@{@"message":@"completion", @"code":@1}, true);
    }
}

@end
