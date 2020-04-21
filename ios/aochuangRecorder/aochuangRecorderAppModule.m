//
//  aochuangRecorderAppModule.m
//  Pods
//

#import "aochuangRecorderAppModule.h"
#import <WeexPluginLoader/WeexPluginLoader.h>

@interface aochuangRecorderAppModule ()

@end

@implementation aochuangRecorderAppModule

@synthesize weexInstance;

WX_PlUGIN_EXPORT_MODULE(aochuangRecorder, aochuangRecorderAppModule)
WX_EXPORT_METHOD(@selector(start::))
WX_EXPORT_METHOD(@selector(stop:))
WX_EXPORT_METHOD(@selector(finish:))
WX_EXPORT_METHOD(@selector(play:::))
WX_EXPORT_METHOD(@selector(stopPlay:))

//回调演示
- (void)start:(NSDictionary*)options :(WXModuleCallback)callback
{
    if (callback != nil) {
        callback(nil);
    }
}

- (void)stop:(NSDictionary*)options :(WXModuleCallback)callback
{
    if (callback != nil) {
        callback(nil);
    }
}

- (void)finish:(WXModuleCallback)callback{
    if (callback != nil) {
        callback(@{@"path": @"", @"duraction": @1000});
    }
}

- (void)play:(NSString*)url :(NSInteger)mode :(WXModuleCallback)callback
{
    if (callback != nil) {
        callback(@{@"message": @"start", @"code": @1000});
    }
}

- (void)stopPlay:(WXModuleCallback)callback
{
    if (callback != nil) {
        callback(nil);
    }
}
@end
