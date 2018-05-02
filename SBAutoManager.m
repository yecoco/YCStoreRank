//
//  SBAutoManager.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "SBAutoManager.h"

@implementation SBAutoManager

+ (SBAutoManager *)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SBAutoManager alloc] init];
    });
    return _sharedInstance;
}

- (void)writeLog:(NSString *)logString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = @"/var/mobile/Media/AppRank/appranklogs.txt";
    NSError *error = nil;
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *jsonStr = [NSString stringWithFormat:@"%@: %@",strDate,logString];
    jsonStr = [jsonStr stringByAppendingString:@",\n"];
    string = [string stringByAppendingString:jsonStr];
    if(![string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"writeLog error:%@",error);
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        [self performSelector:@selector(checkAppStoreStatues) withObject:nil afterDelay:300];
        NSLog(@"------------------------SBAutoManager init------------------------");
    }
    return self;
}

- (void)checkAppStoreStatues
{
    NSLog(@"---------checkAppStoreStatues-----------");
    if (!self.bAppStoreLive && !self.bDelayRate)
    {
        NSLog(@"---------checkAppStoreStatues bAppStoreLive NO TO KILL-----------");
        NSString *txtPath = @"/var/mobile/Media/AppRank/auto.txt";
        NSString *autoString = [[NSString alloc] initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        autoString = [autoString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        autoString = [autoString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        autoString = [autoString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([autoString isEqualToString:@"start"])
        {
            system("killall -9 AppStore");
            self.bOpenedAppStore = NO;
        }
        else
        {
            system("killall -9 AppStore");
            [self performSelector:@selector(openDownloadApplication) withObject:nil afterDelay:1];
        }
    }
    self.bAppStoreLive = NO;
    [self performSelector:@selector(checkAppStoreStatues) withObject:nil afterDelay:300];
}

- (void)delayDoNext
{
    self.bDelayRate = NO;
    NSString *autoPath = @"/var/mobile/Media/AppRank/auto.txt";
    NSString *startString = @"done";
    [startString writeToFile:autoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)lotoUninstallApplication
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *bundleid = self.currentRankApp.bundldID;
        if (bundleid)
        {
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            if (LSApplicationWorkspace_class) {
                LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
                if(workspace && [workspace applicationIsInstalled:bundleid])
                {
                    if([workspace uninstallApplication:bundleid withOptions:nil])
                    {
                        self.bUninstall = YES;
                        NSLog(@"-----lotoUninstallApplication uninstall success");
                    }
                    else
                    {
                        self.bUninstall = NO;
                        NSLog(@"-----lotoUninstallApplication uninstall failed");
                    }
                }
                else if (workspace)
                {
                    self.bUninstall = YES;
                    NSLog(@"-----lotoUninstallApplication not install application");
                }
                else
                {
                    self.bUninstall = NO;
                    NSLog(@"-----Uninstall failed workspace nil");
                }
            }
            else
            {
                self.bUninstall = NO;
                NSLog(@"-----Uninstall failed nil LSApplicationWorkspace_class");
            }
        }
        else
        {
            self.bUninstall = NO;
            NSLog(@"-----Uninstall not find bundldID");
        }
    });
}

- (void)uninstallApp:(NSString *)bundleID
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *bundleid = bundleID;
        if (bundleid)
        {
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            if (LSApplicationWorkspace_class) {
                LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
                if(workspace && [workspace applicationIsInstalled:bundleid])
                {
                    if([workspace uninstallApplication:bundleid withOptions:nil])
                    {
                        self.bUninstall = YES;
                        NSLog(@"-----lotoUninstallApplication uninstall success");
                    }
                    else
                    {
                        self.bUninstall = NO;
                        NSLog(@"-----lotoUninstallApplication uninstall failed");
                    }
                }
                else if (workspace)
                {
                    self.bUninstall = YES;
                    NSLog(@"-----lotoUninstallApplication not install application");
                }
                else
                {
                    self.bUninstall = NO;
                    NSLog(@"-----Uninstall failed workspace nil");
                }
            }
            else
            {
                self.bUninstall = NO;
                NSLog(@"-----Uninstall failed nil LSApplicationWorkspace_class");
            }
        }
        else
        {
            self.bUninstall = NO;
            NSLog(@"-----Uninstall not find bundldID");
        }
    });
}

- (void)openDownloadApplication
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *bundleid = self.currentRankApp.bundldID;
        if (bundleid)
        {
            Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
            if (LSApplicationWorkspace_class) {
                LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
                if(workspace && [workspace applicationIsInstalled:bundleid])
                {
                    if([workspace openApplicationWithBundleID:bundleid])
                    {
                        NSLog(@"-----openDownloadApplication success");
                    }
                    else
                    {
                        NSLog(@"-----openDownloadApplication failed");
                    }
                }
                else if (workspace)
                {
                    NSLog(@"-----openDownloadApplication not downloaded to open");
                }
                else
                {
                    NSLog(@"-----openDownloadApplication workspace nil");
                }
            }
            else
            {
                NSLog(@"-----openDownloadApplication failed nil LSApplicationWorkspace_class");
            }
        }
        else
        {
            NSLog(@"-----openDownloadApplication not find bundldID");
        }
    });
}

- (void)openApplication
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        if (LSApplicationWorkspace_class)
        {
            LSApplicationWorkspace *workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
            if (workspace && [workspace openApplicationWithBundleID:@"com.apple.AppStore"])
            {
                self.bAppStoreLive = YES;
                NSLog(@"------openApplication Successful!");
            }
            else
            {
                self.bAppStoreLive = NO;
                NSLog(@"-----openApplication failed");
            }
        }
        else
        {
            self.bAppStoreLive = NO;
            NSLog(@"-----openApplication failed nil LSApplicationWorkspace_class");
        }
    });
}

- (void)randomVerifySerialNumber
{
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/com.apple.itunesstored.2.sqlitedb" error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/Cookies.binarycookies" error:nil];
    NSString *alphabet = @"A0B1CDEF2GHI3JKL4MN5OP6QRS7TU8VW9XYZ";
    NSString *randomString = @"";
    for (int i = 0; i < 12; ++i) {
        NSUInteger j = arc4random_uniform(36);
        NSString *cu = [alphabet substringWithRange:NSMakeRange(j,1)];
        randomString = [NSString stringWithFormat:@"%@%@",randomString,cu];
    }
    if (randomString.length != 12) {
        randomString = @"D68FK8PBDG2X";
    }
    NSError *error = nil;
    if(![randomString writeToFile:@"/var/mobile/Library/Preferences/deviceInfo.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"---------------write SerialNumber failed:%@",error);
    }
    NSLog(@"randomSerialNumber:%@",randomString);
    system("killall -9 configd & killall -9 fairplayd.H1 & killall -9 fairplayd.H2 & killall -9 absd & killall -9 gamed & killall -9 adid & killall -9 itunesstored & killall -9 storebookkeeperd & killall -9 accountsd & killall -9 StoreKitUIService");
}

- (void)checkAutoTxt
{
    NSString *txtPath = @"/var/mobile/Media/AppRank/auto.txt";
    NSString *autoString = [[NSString alloc] initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
    autoString = [autoString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    autoString = [autoString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    autoString = [autoString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([autoString isEqualToString:@"opendone"])
    {
        self.bOpenedAppStore = NO;
        NSString *startString = @"openstart";
        [startString writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else if ([autoString isEqualToString:@"openstart"])
    {
        if (self.bOpenedAppStore == NO)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/applist.plist"];
            self.currentRankApp = [RankAppModel itemWithDictionary:dic];
            NSLog(@"checkAutoTxt:openstart");
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [@"" writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bOpenedAppStore = YES;
            [self performSelector:@selector(openDownloadApplication) withObject:nil afterDelay:0];
            [self performSelector:@selector(openApplication) withObject:nil afterDelay:20];
            [self performSelector:@selector(lotoUninstallApplication) withObject:nil afterDelay:24];
        }
    }
    else if ([autoString isEqualToString:@"done"])
    {
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/com.apple.itunesstored.2.sqlitedb" error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/com.apple.itunesstored.binarycookies" error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/com.apple.itunesstored.2.sqlitedb-shm" error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Cookies/com.apple.itunesstored.2.sqlitedb-wal" error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Caches/sharedCaches" error:nil];
        self.bOpenedAppStore = NO;
        NSString *startString = @"start";
        [startString writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        system("killall -9 itunesstored");
    }
    else if ([autoString isEqualToString:@"start"])
    {
        if (self.bOpenedAppStore == NO)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/applist.plist"];
            self.currentRankApp = [RankAppModel itemWithDictionary:dic];
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [@"" writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bOpenedAppStore = YES;
            NSLog(@"checkAutoTxt:start");
            [self openApplication];
            [self lotoUninstallApplication];
        }
    }
    else if ([autoString isEqualToString:@"pause"])
    {
        NSLog(@"checkAutoTxt %@",autoString);
    }
    else if ([autoString isEqualToString:@"complete"])
    {
        NSLog(@"checkAutoTxt %@",autoString);
    }
    if (self.bAutoCheck)
    {
        [self performSelector:@selector(checkAutoTxt) withObject:nil afterDelay:1];
    }
}

- (void)doCreate:(NSArray *)objectArray
{
    typedef void (^actionHandle)(UIAlertAction *action);
    actionHandle handle = nil;
    SBUserNotificationAlert *alertItem = objectArray.firstObject;
    UIAlertController *alert = [alertItem _alertController];
    if (alert.actions.count != 3)
    {
        return;
    }
    UIAlertAction *action = alert.actions[1];
    NSLog(@"do alert action title %@",action.title);
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"UIAlertAction"), &numIvars);
    NSString *key = nil;
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if ([key isEqualToString:@"_handler"])
        {
            handle = object_getIvar(action,thisIvar);
            break;
        }
    }
    free(vars);
    if (handle != nil)
    {
        handle(action);
    }
    else
    {
        NSLog(@"handle nil");
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doCreate:) object:objectArray];
}

- (void)doContinue:(NSArray *)objectArray
{
    typedef void (^actionHandle)(UIAlertAction *action);
    actionHandle handle = nil;
    SBUserNotificationAlert *alertItem = objectArray.firstObject;
    UIAlertController *alert = [alertItem _alertController];
    UIAlertAction *action = alert.actions.firstObject;
    if (objectArray.count == 2)
    {
        action = alert.actions.lastObject;
    }
    NSLog(@"do alert action title %@",action.title);
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"UIAlertAction"), &numIvars);
    NSString *key = nil;
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if ([key isEqualToString:@"_handler"])
        {
            handle = object_getIvar(action,thisIvar);
            break;
        }
    }
    free(vars);
    if (handle != nil)
    {
        handle(action);
    }
    else
    {
        NSLog(@"handle nil");
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doContinue:) object:objectArray];
}

- (void)alertdo:(NSArray *)alertObject
{
    id signinalert = alertObject.firstObject;
    SBUserNotificationAlertSheet *signinalertsheet = alertObject.lastObject;
    NSString *alerttitle = signinalertsheet.title;
    NSString *logString = [NSString stringWithFormat:@"alert %@",alerttitle];
    [self writeLog:logString];
    if ([alerttitle isEqualToString:@"Sign In to iTunes Store"])
    {
        NSLog(@"%@ do 1111111",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:1];
        [signinalertsheet dismissWithClickedButtonIndex:1 animated:NO];
    }
    else if ([alerttitle isEqualToString:@"Require password for additional purchases on this device?"])
    {
        NSLog(@"%@ do 000000",alerttitle);
        self.bShowAgree = NO;
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else if([alerttitle isEqualToString:@"You must own this item to write a Customer Review."])
    {
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
        notify_post("com.lotogram.downloadapptoreview");
    }
    else if([alerttitle isEqualToString:@"This nickname is taken. Enter another and try again."])
    {
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
        notify_post("com.lotogram.changenickname");
    }
    else if ([alerttitle isEqualToString:@"Sign-In Required"])
    {
        NSLog(@"%@ do 1111111",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:1];
        [signinalertsheet dismissWithClickedButtonIndex:1 animated:NO];
    }
    else if ([alerttitle isEqualToString:@"Apple Media Services Terms and Conditions have changed."])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (self.bShowAgree == NO)
        {
            self.bShowAgree = YES;
            NSLog(@"%@ do 1111111",alerttitle);
            [signinalert alertView:signinalertsheet clickedButtonAtIndex:1];
            [signinalertsheet dismissWithClickedButtonIndex:1 animated:NO];
        }
        else
        {
            NSLog(@"%@ do 000000",alerttitle);
            [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
            [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
    else if ([alerttitle isEqualToString:@"Verification Failed"])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else if([alerttitle isEqualToString:@"Your Apple ID has been disabled."])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else if([alerttitle isEqualToString:@"Verification Required"])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else if([alerttitle isEqualToString:@"Apple ID Verification"])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else if([alerttitle isEqualToString:@"Cannot connect to iTunes Store"])
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    else
    {
        NSLog(@"%@ do 000000",alerttitle);
        [signinalert alertView:signinalertsheet clickedButtonAtIndex:0];
        [signinalertsheet dismissWithClickedButtonIndex:0 animated:NO];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(alertdo:) object:alertObject];
}

@end
