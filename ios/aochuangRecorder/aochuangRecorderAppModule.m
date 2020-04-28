//
//  aochuangRecorderAppModule.m
//  Pods
//

#import "aochuangRecorderAppModule.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import "AMRRecorder.h"
#import "GlobalAudioPlayer.h"
#import "RecorderUtil.h"

@interface aochuangRecorderAppModule ()<AMRRecorderDelegate>

@property (nonatomic, strong) AMRRecorder *recorder;
@property (nonatomic, strong) WXModuleCallback callback;

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
    static dispatch_once_t onceToken;
    static AMRRecorder *instance;
    dispatch_once(&onceToken, ^{
        instance = [[AMRRecorder alloc] initWithDelegate:self];
    });
    return instance;
}

//回调演示
- (void)start:(NSDictionary*)options :(WXModuleCallback)callback {
    [[self getAmrRecorder] startRecord];
    if (callback != nil){
        callback(@{@"message":@"success", @"code":@1});
    }
}

- (void)stop:(NSDictionary*)options :(WXModuleCallback)callback {
    [[self getAmrRecorder] cancelRecord];
    if (callback != nil){
        callback(@{@"message":@"success", @"code":@1});
    }
}

- (void)finish:(WXModuleCallback)callback {
    self.callback = callback;
    [[self getAmrRecorder] finish];
}

- (void)play:(NSString*)url :(NSInteger)mode :(WXModuleCallback)callback {
//    url = @"http://static1.oasystem.com/file/010/4dca3a3c103849509956200af692f52a.amr";
//    url = @"http://static1.oasystem.com/file/080/4ec8c04c02ddad5da2f0cb296e1b8a18.amr";
    if ([url hasPrefix:@"http://"] == YES || [url hasPrefix:@"https://"] == YES || [url hasPrefix:@"ftp://"] == YES){
        [RecorderUtil downloadFile:url handler:^(NSString * _Nonnull wavPath) {
            if (wavPath != nil){
                BOOL result = [[GlobalAudioPlayer shareInstance] play:wavPath];
                if (result == YES){
                    if (callback != nil){
                        callback(@{@"message":wavPath, @"code":@1});
                    }
                    return;
                }
            }
            if (callback != nil){
                callback(@{@"message":@"error", @"code":@-1});
            }
        }];
    }else{
        NSString *wavPath = url;
        if ([url hasSuffix:@".amr"] == YES){
            wavPath = nil;
            wavPath = [RecorderUtil ConvertAmrToWav:url];
        }
        if (wavPath != nil && wavPath.length > 0 && [wavPath hasSuffix:@".wav"] == YES){
            BOOL result = [[GlobalAudioPlayer shareInstance] play:wavPath];
            if (result == YES){
                if (callback != nil){
                    callback(@{@"message":wavPath, @"code":@1});
                }
                return;
            }
        }
        if (callback != nil){
            callback(@{@"message":@"error", @"code":@-1});
        }
    }
}

- (void)stopPlay:(WXModuleCallback)callback {
    [[GlobalAudioPlayer shareInstance] stopPlay];
    if (callback != nil) {
        callback(@{@"message":@"success", @"code":@1});
    }
}

#pragma mark - AMRRecorderDelegate Method
- (void)volumeChange:(double)volume {}

- (void)failRecord {
    if (self.callback != nil) {
        self.callback(@{@"message":@"error", @"code":@-1});
    }
}

- (void)onConvertBegin {}
 
- (void)onConvertSuccess:(NSString*)amrPath fileName:(NSString*)fileName path:(NSString*)wavPath recordTime:(double)time{
    if (self.callback != nil) {
        self.callback(@{@"path":amrPath, @"wavPath":wavPath, @"duraction":[NSNumber numberWithDouble:time]});
    }
}

@end
