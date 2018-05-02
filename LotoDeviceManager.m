//
//  LotoDeviceManager.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "LotoDeviceManager.h"

@implementation LotoDeviceManager
+ (LotoDeviceManager *)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LotoDeviceManager alloc] init];
    });
    return _sharedInstance;
}
- (NSString *)currentuserobject:(NSString *)key
{
    NSString *totalstring = nil;
    NSString *txtPath = @"/var/mobile/Media/AppRank/currentuser.plist";
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:txtPath];
    if (dic != nil)
    {
        NSString *fileguid = [dic objectForKey:key];
        if (fileguid != nil)
        {
            totalstring = fileguid;
        }
    }
    return totalstring;
}
@end
