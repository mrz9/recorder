//
//  RecorderUtil.h
//  aochuangPush
//
//  Created by adam on 2020/4/27.
//

#import <Foundation/Foundation.h>


@interface RecorderUtil : NSObject

+ (void)downloadFile:(NSString*)urlString handler:(void(^)(NSString *amrFile))handler;
+ (NSString*)ConvertAmrToWav:(NSString*)path;

+ (NSString*)CreateWavFile:(NSString*) sFileName;
+ (NSString*)CreateAmrFile:(NSString*) sFileName;

@end

