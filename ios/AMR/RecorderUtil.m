//
//  RecorderUtil.m
//  aochuangPush
//
//  Created by adam on 2020/4/27.
//

#import "RecorderUtil.h"
#import "VoiceConvert.h"

@implementation RecorderUtil

+ (void)downloadFile:(NSString*)urlString handler:(void(^)(NSString *wavPath))handler{
    if (urlString != NULL) {
        NSLog(@"DownloadFile, url = %@", urlString);
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url= [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:20];
        //提交请求
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data != nil && error == nil) {
                NSString *fileName = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
                //1.保存amr文件到本地
                NSString *amrPath = [self CreateAmrFile:fileName];
                NSLog(@"%@", data);
                [data writeToFile:amrPath atomically:YES];
                //2.转换成wav格式
                NSString *wavPath = [self CreateWavFile:fileName];
                int result = [VoiceConvert ConvertAmrToWav:amrPath wavSavePath:wavPath];
                if (result == 1) {      //转换成功
                    handler(wavPath);
                }else{                  //AMR转wav失败
                    NSLog(@"AMR转wav失败");
                    handler(nil);
                }
            }else{                      //下载文件失败
                 NSLog(@"下载文件失败");
                 handler(nil);
            }
        }];
        [dataTask resume];
    }
}

+ (NSString*)CreateAmrFile:(NSString*)sFileName{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"im_voice_amr_cache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]){
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (sFileName == nil) {
        sFileName = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.amr", sFileName];
    return [filePath stringByAppendingPathComponent:fileName];
}

+ (NSString*)CreateWavFile:(NSString*)sFileName{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"im_voice_cache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]){
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (sFileName == nil) {
        sFileName = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    }
    
    filePath = [filePath stringByAppendingFormat:@"/%@.wav", sFileName];
    return filePath;
}

+ (NSString*)ConvertAmrToWav:(NSString*)path {
    if (path != nil && path.length > 0){
        NSString *wavPath = [self CreateWavFile:nil];
        int result = [VoiceConvert ConvertAmrToWav:path wavSavePath:wavPath];
        if (result == 1) {
            return wavPath;
        }
    }
    return nil;
}

@end
