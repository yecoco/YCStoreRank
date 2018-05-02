//
//  RankManager.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "RankManager.h"

static BOOL doRate = NO;
static BOOL doReview = NO;

@implementation RankManager

+ (RankManager *)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RankManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"----------------RankManager init----------------");
        self.disableAccounts = [NSArray arrayWithContentsOfFile:@"/var/mobile/Media/AppRank/disableaccount.plist"];
    }
    return self;
}

- (NSString *)queryDictionaryToString:(NSDictionary *)dic
{
    NSString *requestBody = @"";
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    for (id nestedKey in [dic.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
        id nestedValue = dic[nestedKey];
        if (nestedValue) {
            if (requestBody.length > 0)
                requestBody = [NSString stringWithFormat:@"%@&%@=%@",requestBody,nestedKey,nestedValue];
            else
                requestBody = [NSString stringWithFormat:@"%@=%@",nestedKey,nestedValue];
        }
    }
    return requestBody;
}

- (void)getUserFromServer:(BOOL)bHaveDeviceName complete:(void (^)(id responseObject, NSError *error))complete
{
    NSString *baseURL = @"http://10.0.1.11:8088/tasks/fetch?";
    if (doRate)
    {
        baseURL = @"http://10.0.1.11:8088/rating/fetch?";
    }
    else if(doReview)
    {
        baseURL = @"http://10.0.1.11:8088/rates/fetch?";
    }

    NSString *urlString = [NSString stringWithFormat:@"%@country=%@",baseURL,@"US"];
    if (bHaveDeviceName)
    {
        NSString* userPhoneName = [[UIDevice currentDevice] name];
        urlString = [NSString stringWithFormat:@"%@country=%@&deviceName=%@", baseURL, @"US",userPhoneName];
    }
    NSLog(@"-----getUserFromServer:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                NSLog(@"error:%@", error.localizedDescription);
                if (complete) {
                    complete(nil,error);
                }
            }
            else
            {
                NSError *errorJson = nil;
                id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&errorJson];
                NSLog(@"success:%@",object);
                if (complete) {
                    complete(object,errorJson);
                }
            }
        });
    }];
    [task resume];
}

- (void)changeUserInfo:(NSDictionary *)para bSuccess:(BOOL)bsuccess complete:(void (^)(id responseObject, NSError *error))complete
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"user":para}];
    if (bsuccess)
    {
        NSDictionary *task = @{@"_id":self.currentapp.taskID};
        [dic setObject:task forKey:@"task"];
        if (self.currentapp.workType == 1)
        {
            NSDictionary *task = @{@"_id":self.currentRate.rateID,@"status":@(0)};
            [dic setObject:task forKey:@"rate"];
        }
    }
    
    NSLog(@"---changeUserInfo para %@",dic);
    NSError *jsonerror = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&jsonerror];
    if (jsonerror) {
        NSLog(@"%@",jsonerror);
        if (complete) {
            complete(nil,jsonerror);
        }
        return;
    }
    NSString *urlString = @"http://10.0.1.11:8088/tasks/update";
    if (self.currentapp.workType == 1)
    {
        urlString = @"http://10.0.1.11:8088/rates/update";
    }
    else if (self.currentapp.workType == 2)
    {
        urlString = @"http://10.0.1.11:8088/rating/update";
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = jsonData;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                NSLog(@"error:%@", error.localizedDescription);
                if (complete) {
                    complete(nil,error);
                }
            }
            else
            {
                NSError *errorJson = nil;
                id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&errorJson];
                NSLog(@"success:%@ error:%@",object,errorJson);
                if (complete) {
                    complete(object,errorJson);
                }
            }
        });
    }];
    [task resume];
}

- (void)writeErrorAccout:(NSString *)alerttitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = @"/var/mobile/Media/AppRank/erroraccount.txt";
    NSError *error = nil;
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *jsonStr = [NSString stringWithFormat:@"%@: %@ %@",strDate,self.currentAccount.appleid,alerttitle];
    jsonStr = [jsonStr stringByAppendingString:@",\n"];
    string = [string stringByAppendingString:jsonStr];
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (void)writeLog:(NSString *)logString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *filePath = @"/var/mobile/Media/AppRank/appranklogs.txt";
    NSError *error = nil;
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *jsonStr = @"";
    if (self.keywodIndex < self.currentapp.moreKeywords.count)
    {
        NSString *keyword = [self.currentapp.moreKeywords objectAtIndex:self.keywodIndex];
        jsonStr = [NSString stringWithFormat:@"%@: keyword:%@ %@",strDate,keyword,logString];
    }
    else
    {
        jsonStr = [NSString stringWithFormat:@"%@: keyword:%@ %@",strDate,self.currentapp.searchTerms,logString];
    }
    jsonStr = [jsonStr stringByAppendingString:@",\n"];
    string = [string stringByAppendingString:jsonStr];
    if(![string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"writeLog error:%@",error);
    }
}

- (void)flagErrorAccount:(NSInteger)status complete:(void (^)())complete
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0" forKey:@"holdingtime"];
    [dic setObject:self.currentAccount.appleid forKey:@"appleid"];
    [dic setObject:@(status) forKey:@"status"];
    if (self.currentAccount.devicename == nil)
    {
        NSString* userPhoneName = [[UIDevice currentDevice] name];
        [dic setObject:userPhoneName forKey:@"deviceName"];
    }
    [self changeUserInfo:dic bSuccess:NO complete:^(id responseObject, NSError *error) {
        NSString *status = [responseObject objectForKey:@"status"];
        if (error == nil && [status isEqualToString:@"ok"])
        {
            NSString *logString = [NSString stringWithFormat:@"%@ error account changeUserInfo success",self.currentAccount.appleid];
            [self writeLog:logString];
        }
        else if (error == nil)
        {
            NSString *logString = [NSString stringWithFormat:@"%@ error account changeUserInfo fail %@",self.currentAccount.appleid,responseObject[@"message"]];
            [self writeLog:logString];
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:@"%@ error account changeUserInfo fail %@",self.currentAccount.appleid,error.localizedDescription];
            [self writeLog:logString];
        }
        if (complete)
        {
            complete();
        }
    }];
}

- (void)checksigninstatues
{
    self.bCheckSignin = YES;
    NSString *btnTitle = self.appleIDButton.titleLabel.text;
    if (![btnTitle isEqualToString:@"Sign In"])
    {
        self.statusLabel.text = [NSString stringWithFormat:@"sign in success %@",btnTitle];
        UITabBarController *tabbar = (UITabBarController*)self.tabBarVc;
        tabbar.selectedIndex = 3;
        self.keywodIndex = 0;
        self.bCheckSignin = NO;
        [self performSelector:@selector(begainSearch) withObject:nil afterDelay:5.0f];
    }
    else if(self.signcount > 50)
    {
        NSString *logString = [NSString stringWithFormat:@"%@ signin failed",self.currentAccount.appleid];
        [self writeLog:logString];
        self.statusLabel.text = [NSString stringWithFormat:@"sign in failed %@",self.currentAccount.appleid];
        self.signcount = 0;
        self.bCheckSignin = NO;
        [self writeErrorAccout:@"sign in failed"];
        [self signError];
    }
    else
    {
        self.signcount ++;
        self.statusLabel.text = [NSString stringWithFormat:@"chek signin %ld",(long)self.signcount];
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        NSString *alert = [[NSString alloc] initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        alert = [alert stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        alert = [alert stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if ([alert isEqualToString:@"Apple ID Verification"] || [alert isEqualToString:@"Verification Failed"])
        {
            self.signcount = 0;
            NSString *text = @"";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [self flagErrorAccount:2 complete:^{
                [self writeErrorAccout:@"Login Verification Failed"];
                [self signError];
            }];
        }
        else
        {
            NSLog(@"sigin alert---%@",alert);
            [self performSelector:@selector(checksigninstatues) withObject:nil afterDelay:5];
        }
    }
}
- (void)checksignoutstatues
{
    self.bCheckSignout = YES;
    NSString *btnTitle = self.appleIDButton.titleLabel.text;
    if ([btnTitle isEqualToString:@"Sign In"])
    {
        self.signoutcount = 0;
        self.statusLabel.text = @"sign out success";
        self.bCheckSignout = NO;
        [self performSelector:@selector(completesignout) withObject:nil afterDelay:2];
    }
    else if (self.signoutcount > 30)
    {
        NSString *logString = [NSString stringWithFormat:@"%@ checksignoutstatues failed",self.currentAccount.appleid];
        [self writeLog:logString];
        self.statusLabel.text = [NSString stringWithFormat:@"sign out failed %@",btnTitle];
        self.signoutcount = 0;
        self.bCheckSignout = NO;
        [self performSelector:@selector(completesignout) withObject:nil afterDelay:2];
    }
    else
    {
        self.signoutcount++;
        [self performSelector:@selector(checksignoutstatues) withObject:nil afterDelay:5];
    }
}

- (void)signError
{
    self.bLoadFeaturePage = NO;
    NSString *autoPath = @"/var/mobile/Media/AppRank/auto.txt";
    NSString *startString = @"done";
    [startString writeToFile:autoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    exit(0);
}

- (void)completesignout
{
   // [self removeAppStoreFile];
    self.bLoadFeaturePage = NO;
    if (self.currentapp.workType == 1 || self.currentapp.workType == 2)
    {
        notify_post("com.lotogram.doratedelaytime");
    }
    else if (self.currentapp.workType == 0)
    {
        // notify_post("com.lotogram.appstorechangedeviceinfo");
        
        NSString *autoPath = @"/var/mobile/Media/AppRank/auto.txt";
        NSString *startString = @"done";
        [startString writeToFile:autoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    exit(0);
}

- (void)removeAppStoreFile
{
    NSInteger logoutcount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LotoLogoutCount"] integerValue];
    if (logoutcount < 500)
    {
        logoutcount = logoutcount + 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:logoutcount] forKey:@"LotoLogoutCount"];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"LotoLogoutCount"];
    NSError *error = nil;
    if([[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/com.apple.itunesstored" error:&error])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:@"bRemoveiTunesFile"];
        [self writeLog:@"removeAppStoreFile com.apple.itunesstored remove success"];
        NSLog(@"removeAppStoreFile com.apple.itunesstored remove success");
        notify_post("com.lotogram.appstoredeleteitunesstoredfile");
    }
    else
    {
        NSString *logString = [NSString stringWithFormat:@"removeAppStoreFile com.apple.itunesstored remove failed %@",error];
        [self writeLog:logString];
        NSLog(@"removeAppStoreFile com.apple.itunesstored remove failed %@",error);
    }
    // error = nil;
    // if ([[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/com.apple.nsurlsessiond" error:&error])
    // {
    //     [self writeLog:@"removeAppStoreFile com.apple.nsurlsessiond remove success"];
    //     NSLog(@"removeAppStoreFile com.apple.nsurlsessiond remove success");
    // }
    // else
    // {
    //     NSString *logString = [NSString stringWithFormat:@"removeAppStoreFile com.apple.nsurlsessiond remove failed %@",error];
    //     [self writeLog:logString];
    //     NSLog(@"removeAppStoreFile com.apple.nsurlsessiond remove failed %@",error);
    // }

    // error = nil;

    // if ([[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Media/AppRank/com.apple.itunesstored" toPath:@"/var/mobile/Library" error:&error])
    // {
    //     [self writeLog:@"move appstore file com.apple.itunesstored success"];
    //     NSLog(@"move appstore file com.apple.itunesstored success");
    // }
    // else
    // {
    //     NSString *logString = [NSString stringWithFormat:@"move appstore file com.apple.itunesstored failed %@",error];
    //     [self writeLog:logString];
    //     NSLog(@"move appstore file com.apple.itunesstored failed %@",error);
    // }

    // error = nil;

    // if ([[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Media/AppRank/com.apple.nsurlsessiond" toPath:@"/var/mobile/Library" error:&error])
    // {
    //     [self writeLog:@"move appstore file com.apple.nsurlsessiond success"];
    //     NSLog(@"move appstore file com.apple.nsurlsessiond success");
    // }
    // else
    // {
    //     NSString *logString = [NSString stringWithFormat:@"move appstore file com.apple.nsurlsessiond failed %@",error];
    //     [self writeLog:logString];
    //     NSLog(@"move appstore file com.apple.nsurlsessiond failed %@",error);
    // }

    // float version =  [[UIDevice currentDevice].systemVersion floatValue];
    // if (version >= 10.0f)
    // {
    //     [self removeSystemCacheFile];
    // }
    // NSString *accountPath = @"/var/mobile/Library/Accounts";
    // NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:accountPath];
    // for (NSString *fileName in enumerator) {
    //     error = nil;
    //     if ([[NSFileManager defaultManager] removeItemAtPath:[accountPath stringByAppendingPathComponent:fileName] error:&error])
    //     {
    //         NSLog(@"removeAppStoreFile %@ Accounts remove success",fileName);
    //     }
    //     else
    //     {
    //         NSLog(@"removeAppStoreFile %@ Accounts remove failed %@",fileName,error);
    //     }
    // }
}

- (void)removeSystemCacheFile
{
    NSString *DocumentsPath = @"/var/containers/Data/System";
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
    for (NSString *fileName in enumerator) {
        NSString *path = [DocumentsPath stringByAppendingPathComponent:fileName];
        NSString *plistPath = [path stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSString *identifyString = [dic objectForKey:@"MCMMetadataIdentifier"];
        if ([identifyString isEqualToString:@"com.apple.appstored"])
        {
            path = [path stringByAppendingPathComponent:@"Documents"];
            NSDirectoryEnumerator *enumerator1 = [[NSFileManager defaultManager] enumeratorAtPath:path];
            for (NSString *fileName in enumerator1)
            {
                NSError *error = nil;
                if ([[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error])
                {
                    NSLog(@"removeAppStoreFile %@ remove success",fileName);
                }
                else
                {
                    NSLog(@"removeAppStoreFile %@ remove failed %@",fileName,error);
                }
            }
            break;
        }
    }
}

- (void)checkProgressStatues
{
    self.bCheckProgress = YES;
    if (self.progress > 0)
    {
        self.bCheckProgress = NO;
    }
    else if (self.progresscount >= 60)
    {
        self.bCheckProgress = NO;
        self.tabBarVc.selectedIndex = 0;
        self.statusLabel.text = @"self.progresscount >= 60 pause test";
    }
    else
    {
        self.progresscount ++;
        NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
        NSString *alert = [[NSString alloc] initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        alert = [alert stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        alert = [alert stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if ([alert isEqualToString:@"Apple Media Services Terms and Conditions have changed."])
        {
            //验证
            NSLog(@"self.progress 验证下 %@",alert);
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
        }
        else if ([alert isEqualToString:@"Verification Failed"])
        {
            //
            NSLog(@"self.progress action failed %@",alert);
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
            [self performSelector:@selector(doAppInfoPageDownload) withObject:nil afterDelay:0];
        }
        else if ([alert isEqualToString:@"Verification Required"])
        {
            NSLog(@"self.progress 帐号问题 %@",alert);
            //帐号问题
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
            [self flagErrorAccount:2 complete:^{
                [self writeErrorAccout:alert];
                [self doGetError];
            }];
        }
        else if([alert isEqualToString:@"Your Apple ID has been disabled."])
        {
            NSLog(@"self.progress disabled %@",alert);
            //帐号问题
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
            [self flagErrorAccount:0 complete:^{
                [self writeErrorAccout:alert];
                [self doGetError];
            }];
        }
        else if([alert isEqualToString:@"Apple ID Verification"])
        {
            NSLog(@"self.progress account %@",alert);
            //帐号问题
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
            [self flagErrorAccount:2 complete:^{
                [self writeErrorAccout:@"Download Verification Failed"];
                [self doGetError];
            }];
        }
        else if([alert isEqualToString:@"Cannot connect to iTunes Store"])
        {
            NSLog(@"self.progress action failed %@",alert);
            NSString *text = @"";
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            self.bCheckProgress = NO;
            [self performSelector:@selector(doAppInfoPageDownload) withObject:nil afterDelay:0];
        }
        else
        {
            NSLog(@"self.progress alerttitle---%@",alert);
            [self performSelector:@selector(checkProgressStatues) withObject:nil afterDelay:5];
        }
    }
}

- (void)setupProgressTimer
{
    NSLog(@"---------setupProgressTimer");
    NSString *text = @"";
    NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
    [text writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    self.progress = 0;
    self.progresscount = 0;
    if (self.bCheckProgress == NO)
    {
        [self checkProgressStatues];
    }
    else
    {
        self.statusLabel.text = @"already in checkProgress";
    }
}

// - (void)getSearchText
// {
// self.currentSearchText = [[NSUserDefaults standardUserDefaults] objectForKey:@"lotokeyword"];
// NSLog(@"---keyword---currentSearchText:%@",self.currentSearchText);
// if (self.currentSearchText == nil)
// {
//     self.currentSearchText = self.currentapp.searchTerms.firstObject;
// }
// NSArray *keywords = self.currentapp.searchTerms;
// NSInteger nextIndex = 0;
// for (int i = 0; i < keywords.count; ++i)
// {
//     NSString *keyword = keywords[i];
//     if ([keyword isEqualToString:self.currentSearchText])
//     {
//         nextIndex = i+1;
//         if (nextIndex >= keywords.count)
//         {
//             nextIndex = 0;
//         }
//         break;
//     }
// }
// NSString *nextKeyword = keywords[nextIndex];
// NSLog(@"---keyword---nextKeyword:%@",nextKeyword);
// [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lotokeyword"];
// [[NSUserDefaults standardUserDefaults] setObject:nextKeyword forKey:@"lotokeyword"];
// }

- (id)getchildViewController
{
    id childVC = nil;
    id selectedVC = self.tabBarVc.selectedViewController;
    if (selectedVC != nil && [selectedVC isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *naviVC = self.tabBarVc.selectedViewController;
        id visiVC = naviVC.visibleViewController;
        if (visiVC != nil)
        {
            NSString *className = NSStringFromClass([visiVC class]);
            if ([className isEqualToString:@"SKUIDocumentContainerViewController"])
            {
                SKUIDocumentContainerViewController *skdocumentVC = (SKUIDocumentContainerViewController *)naviVC.visibleViewController;
                childVC = [skdocumentVC childViewController];
            }
        }
    }
    return childVC;
}

- (BOOL)bSearchDidLoaded:(id)childVC
{
    NSString *childClass = NSStringFromClass([childVC class]);
    if ([childClass isEqualToString:@"SKUIStackDocumentViewController"])
    {
        return YES;
    }
    return NO;
}

- (UICollectionViewCell *)getSegmentedControlCell
{
    SKUIStorePageSectionsViewController *skpagesectionVC = self.currentVC;
    if (!skpagesectionVC)
    {
        return nil;
    }
    UICollectionViewCell *segmentCell = nil;
    UICollectionView *collection = skpagesectionVC.collectionView;
    NSInteger sections = [collection numberOfSections];
    for(int i=0; i<sections; i++)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:i];
        UICollectionViewCell *cell = [collection cellForItemAtIndexPath:index];
        NSString *className = NSStringFromClass([cell class]);
        if ([className isEqualToString:@"SKUISegmentedControlCollectionViewCell"])
        {
            segmentCell = cell;
            break;
        }
    }
    return segmentCell;
}

- (NSIndexPath *)getButtonCollectionViewCell
{
    SKUIStorePageSectionsViewController *skpagesectionVC = self.currentVC;
    if (!skpagesectionVC)
    {
        return nil;
    }
    NSIndexPath *buttonIndex = nil;
    UICollectionView *collection = skpagesectionVC.collectionView;
    NSInteger sections = [collection numberOfSections];
    for(int i=0; i<sections; i++)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:i];
        UICollectionViewCell *cell = [collection cellForItemAtIndexPath:index];
        NSString *className = NSStringFromClass([cell class]);
        if ([className isEqualToString:@"SKUIButtonCollectionViewCell"])
        {
            if ([self bReviewCell:cell])
            {
                buttonIndex = index;
                break;
            }
        }
    }
    return buttonIndex;
}

- (BOOL)bReviewCell:(UICollectionViewCell *)cell
{
    SKUIStyledButton *btn = nil;
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIButtonCollectionViewCell"), &numIvars);
    NSString *key = nil;
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if([key isEqualToString:@"_button"])
        {
            btn = object_getIvar(cell,thisIvar);
            break;
        }
    }
    free(vars);
    if (btn)
    {
        SKUIAttributedStringLayout *layout = btn.titleLayout;
        if ([layout.attributedString.string containsString:@"Write a Review"])
            return YES;
        else
            return NO;
    }
    return YES;
}

- (UICollectionViewCell *)getAppInfoPageDownloadCell
{
    SKUIStorePageSectionsViewController *skpagesectionVC = self.currentVC;
    if (!skpagesectionVC)
    {
        return nil;
    }
    UICollectionView *collection = skpagesectionVC.collectionView;
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewCell *lockupCell = [collection cellForItemAtIndexPath:index];
    NSString *className = NSStringFromClass([lockupCell class]);
    if ([className isEqualToString:@"SKUIProductLockupCollectionViewCell"])
    {
        return lockupCell;
    }
    else
    {
        if (collection)
        {
            NSInteger count = [collection.dataSource numberOfSectionsInCollectionView:collection];
            NSLog(@"find collection %ld",(long)count);
        }
        else
        {
            NSLog(@"not find collection");
        }
        NSLog(@"--------cannot find SKUIProductLockupCollectionViewCell:%@----%@----",className,NSStringFromClass([skpagesectionVC class]));
        self.statusLabel.text = @"cannot find SKUIProductLockupCollectionViewCell";
    }
    return nil;
}

- (UIView *)getOfferViewFromCell:(UICollectionViewCell *)cell
{
    UIView *offerview = nil;
    NSArray *subs = cell.subviews;
    if (subs == nil || subs.count == 0)
    {
        self.statusLabel.text = @"getOfferViewFromCell cell subviews nil";
        return nil;
    }
    UIView *cellContentView = cell.subviews.firstObject;
    NSArray *cellCvSubviews = cellContentView.subviews;
    for (id view in cellCvSubviews)
    {
        NSString *offerClassName = NSStringFromClass([view class]);
        if ([offerClassName isEqualToString:@"SKUIOfferView"])
        {
            NSLog(@"offerview not nil %@",view);
            offerview = (UIView *)view;
            break;
        }
    }
    if (!offerview)
    {
        NSLog(@"--------cannot find SKUIOfferView");
        self.statusLabel.text = @"cannot find SKUIOfferView";
    }
    return offerview;
}

- (SKUIItemOfferButton *)getOfferButtonFromOfferView:(UIView *)offerview
{
    SKUIItemOfferButton *offerBtn = nil;
    NSArray *offsubs = offerview.subviews;
    NSLog(@"offsubs not nil %@ %@",offsubs,offerview);
    for (id view in offsubs)
    {
        NSString *className = NSStringFromClass([view class]);
        if ([className isEqualToString:@"SKUIItemOfferButton"])
        {
            offerBtn = (SKUIItemOfferButton *)view;
            break;
        }
    }
    if (!offerBtn)
    {
        NSLog(@"--------cannot find SKUIItemOfferButton");
        self.statusLabel.text = @"cannot find SKUIItemOfferButton";
    }
    return offerBtn;
}

- (BOOL)checkIsOpen
{
    UICollectionViewCell *lockupCell = [self getAppInfoPageDownloadCell];
    if (lockupCell)
    {
        UIView *offerview = [self getOfferViewFromCell:lockupCell];
        if (offerview)
        {
            SKUIItemOfferButton *skbtn = [self getOfferButtonFromOfferView:offerview];
            if (skbtn)
            {
                NSMutableAttributedString *titleLabel = nil;
                unsigned int numIvars;
                Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIItemOfferButton"), &numIvars);
                NSString *key = nil;
                for(int i = 0; i < numIvars; i++) {
                    Ivar thisIvar = vars[i];
                    key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                    if([key isEqualToString:@"_titleAttributedString"])
                    {
                        titleLabel = object_getIvar(skbtn,thisIvar);
                        break;
                    }
                }
                free(vars);
                NSLog(@"checkIsOpen %@",titleLabel.string);
                if ([titleLabel.string isEqualToString:@"OPEN"])
                {
                    return YES;
                }
                else
                {
                    return NO;
                }
            }
        }
    }
    NSLog(@"checkIsOpen error");
    return NO;
}

- (BOOL)checkIsCloud
{
    UICollectionViewCell *lockupCell = [self getAppInfoPageDownloadCell];
    if (lockupCell)
    {
        UIView *offerview = [self getOfferViewFromCell:lockupCell];
        if (offerview)
        {
            SKUIItemOfferButton *skbtn = [self getOfferButtonFromOfferView:offerview];
            if (skbtn)
            {
                UIImage *cloudImage = nil;
                unsigned int numIvars;
                Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIItemOfferButton"), &numIvars);
                NSString *key = nil;
                for(int i = 0; i < numIvars; i++) {
                    Ivar thisIvar = vars[i];
                    key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                    if ([key isEqualToString:@"_cloudImage"])
                    {
                        cloudImage = object_getIvar(skbtn,thisIvar);
                        break;
                    }
                }
                free(vars);
                if (cloudImage)
                {
                    self.bHaveCloud = YES;
                }
                else
                {
                    self.bHaveCloud = NO;
                }
            }
        }
    }
    return self.bHaveCloud;
}

- (NSString *)newNickName
{
    if (self.currentAccount == nil)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/currentuser.plist"];
        self.currentAccount = [AppleAccountModel itemWithDictionary:dic];
        if (self.currentAccount == nil || self.currentAccount.appleid == nil || self.currentAccount.appleid.length == 0)
        {
            int NUMBER_OF_CHARS = 8;
            char data[NUMBER_OF_CHARS];
            for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('a' + (arc4random_uniform(26))));
            NSString *random = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
            return random;
        }
    }
    int NUMBER_OF_CHARS = 2;
    char data[NUMBER_OF_CHARS];
    for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('a' + (arc4random_uniform(26))));
    NSString *random = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    NSString *nickName = [NSString stringWithFormat:@"%@%@",self.currentRate.nickname,random];
    return nickName;
}

- (NSString *)getNickName
{
    if (self.currentAccount == nil)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/currentuser.plist"];
        self.currentAccount = [AppleAccountModel itemWithDictionary:dic];
        if (self.currentAccount == nil || self.currentAccount.appleid == nil || self.currentAccount.appleid.length == 0)
        {
            int NUMBER_OF_CHARS = 8;
            char data[NUMBER_OF_CHARS];
            for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('a' + (arc4random_uniform(26))));
            NSString *random = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
            return random;
        }
    }
    NSString *appleid = self.currentAccount.appleid;
    NSRange rang = [appleid rangeOfString:@"@"];
    NSString *total = [appleid substringToIndex:rang.location];
    return total;
}

- (void)doAppInfoPageDownload
{
    if (self.currentapp.workType == 0)
    {
        [self doDownload];
    }
    else if (self.currentapp.workType == 1 || self.currentapp.workType == 2)
    {
        [self doReview];
    }
    //[self doDownload];
}

- (void)doTouchWriteReview
{
    NSIndexPath *index = [self getButtonCollectionViewCell];
    if (index && self.currentVC)
    {
        SKUIStorePageSectionsViewController *skpagesectionVC = self.currentVC;
        [skpagesectionVC collectionView:skpagesectionVC.collectionView didSelectItemAtIndexPath:index];
    }
    else if (!self.haveSearchCellBtn)
    {
        self.haveSearchCellBtn = YES;
        [self performSelector:@selector(doTouchWriteReview) withObject:nil afterDelay:30];
    }
    else
    {
        [self writeLog:@"doTouchWriteReview search cell failed"];
        self.statusLabel.text = @"not find SKUIButtonCollectionViewCell";
    }
}

- (void)doReview
{
    UICollectionViewCell *segmentCell = [self getSegmentedControlCell];
    if (segmentCell)
    {
        SKUISegmentedControlViewElementController *segmentVC = nil;
        unsigned int numIvars;
        Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUISegmentedControlCollectionViewCell"), &numIvars);
        NSString *key = nil;
        for(int i = 0; i < numIvars; i++) {
            Ivar thisIvar = vars[i];
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            if ([key isEqualToString:@"_elementController"]) {
                segmentVC = object_getIvar(segmentCell,thisIvar);
                break;
            }
        }
        free(vars);
        if (segmentVC)
        {
            [self writeLog:@"segmentedControlView select index"];
            self.bSelectedReview = YES;
            [segmentVC segmentedControl:segmentVC.segmentedControlView didSelectSegmentIndex:1];
            [self performSelector:@selector(doTouchWriteReview) withObject:nil afterDelay:10];
        }
        else
        {
            [self writeLog:@"doRatingReview search SKUISegmentedControlViewElementController failed"];
            self.statusLabel.text = @"SKUISegmentedControlViewElementController find  failed";
        }
    }
    else
    {
        if (!self.bDoAppInfoDownload)
        {
            [self writeLog:@"doRatingReview search failed to continue find"];
            self.statusLabel.text = @"continue find  SKUISegmentedControlCollectionViewCell";
            self.bDoAppInfoDownload = YES;
            [self performSelector:@selector(doAppInfoPageDownload) withObject:nil afterDelay:5];
        }
        else
        {
            [self writeLog:@"doRatingReview search cell failed"];
            self.statusLabel.text = @"two not find SKUISegmentedControlCollectionViewCell";
        }
    }
}

- (void)doDownload
{
    UICollectionViewCell *lockupCell = [self getAppInfoPageDownloadCell];
    if (lockupCell)
    {
        UIView *offerview = [self getOfferViewFromCell:lockupCell];
        if (offerview)
        {
            SKUIItemOfferButton *skbtn = [self getOfferButtonFromOfferView:offerview];
            if (skbtn)
            {
                if (self.currentapp.allowCloudDownload)
                {
                    if (self.bSkip)
                    {
                        self.tabBarVc.selectedIndex = 0;
                        return;
                    }
                    [self setupProgressTimer];
                    [self allowCloudDownloadDo:skbtn withOfferView:offerview];
                }
                else
                {
                    [self checkIsCloudToDownload:skbtn withOfferView:offerview];
                }
            }
        }
    }
    else
    {
        if (!self.bDoAppInfoDownload)
        {
            [self writeLog:@"doDownload search failed to continue find"];
            self.statusLabel.text = @"continue find  SKUIProductLockupCollectionViewCell";
            self.bDoAppInfoDownload = YES;
            [self performSelector:@selector(doAppInfoPageDownload) withObject:nil afterDelay:5];
        }
        else
        {
            [self writeLog:@"doDownload search cell failed"];
            self.statusLabel.text = @"two not find SKUIProductLockupCollectionViewCell";
        }
    }
}

- (void)allowCloudDownloadDo:(SKUIItemOfferButton *)skbtn withOfferView:(UIView *)offerview
{
    UIImage *cloudImage = nil;
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIItemOfferButton"), &numIvars);
    NSString *key = nil;
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if ([key isEqualToString:@"_cloudImage"]) {
            cloudImage = object_getIvar(skbtn,thisIvar);
            break;
        }
    }
    free(vars);
    if (cloudImage)
    {
        self.bHaveCloud = YES;
    }
    else
    {
        self.bHaveCloud = NO;
    }
    [offerview performSelector:@selector(_buttonAction:) withObject:skbtn afterDelay:0];
}

- (void)checkIsCloudToDownload:(SKUIItemOfferButton *)skbtn withOfferView:(UIView *)offerview
{
    UIImage *cloudImage = nil;
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIItemOfferButton"), &numIvars);
    NSString *key = nil;
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if ([key isEqualToString:@"_cloudImage"])
        {
            cloudImage = object_getIvar(skbtn,thisIvar);
            break;
        }
    }
    free(vars);
    if (cloudImage)
    {
        self.bHaveCloud = YES;
        NSString *logString = [NSString stringWithFormat:@"rank:%i %@ have cloud",rankIndex,self.currentAccount.appleid];
        [self writeLog:logString];
        NSLog(@"%@",logString);
        self.statusLabel.text = logString;
        [self performSelector:@selector(completeDownload) withObject:nil afterDelay:1];
    }
    else
    {
        self.bHaveCloud = NO;
        NSString *logString = [NSString stringWithFormat:@"rank:%i %@ not have cloud",rankIndex,self.currentAccount.appleid];
        self.statusLabel.text = logString;
        [self writeLog:logString];
        NSLog(@"%@",logString);
        if (self.bSkip)
        {
            self.tabBarVc.selectedIndex = 0;
            return;
        }
        [self setupProgressTimer];
        [offerview performSelector:@selector(_buttonAction:) withObject:skbtn afterDelay:0];
    }
}

- (NSArray *)getViewElements:(SKUIStorePageSectionsViewController *)skpagesectionVC
{
    NSArray *viewElements = nil;
    if (skpagesectionVC)
    {
        NSArray *sections = skpagesectionVC.sections;
        id sectionObject = sections.firstObject;
        NSString *className = NSStringFromClass([sectionObject class]);
        if ([className isEqualToString:@"SKUIGridViewElementPageSection"])
        {
            SKUIGridViewElementPageSection *gridsection = (SKUIGridViewElementPageSection *)sectionObject;
            unsigned int numIvars;
            Ivar *vars = class_copyIvarList(NSClassFromString(@"SKUIGridViewElementPageSection"), &numIvars);
            NSString *key=nil;
            for(int i = 0; i < numIvars; i++) {
                Ivar thisIvar = vars[i];
                key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                if ([key isEqualToString:@"_viewElements"]) {
                    viewElements = object_getIvar(gridsection,thisIvar);
                    break;
                }
            }
            free(vars);
        }
        if (!viewElements)
        {
            NSLog(@"--------cannot find _viewElements");
            self.statusLabel.text = @"cannot find _viewElements";
        }
        NSLog(@"-----viewElements count %ld",(long)viewElements.count);
    }
    return viewElements;
}

- (void)searchListDoTotalApp
{
    if (self.bSkip)
    {
        self.tabBarVc.selectedIndex = 0;
        return;
    }
    id childVC = [self getchildViewController];
    if (childVC == nil)
    {
        [self writeErrorAccout:@"not find childViewController"];
        self.tabBarVc.selectedIndex = 0;
        return;
    }
    BOOL loaded = [self bSearchDidLoaded:childVC];
    if (loaded)
    {
        SKUIStackDocumentViewController *skstackVc = (SKUIStackDocumentViewController *)childVC;
        SKUIStorePageSectionsViewController *skpagesectionVC = skstackVc.sectionsViewController;
        UICollectionView *collection = skpagesectionVC.collectionView;
        [skpagesectionVC _reloadCollectionView];
        [skpagesectionVC _reloadRelevantEntityProviders];
        [collection reloadData];
        [self performSelector:@selector(doSearchCell:) withObject:skpagesectionVC afterDelay:1];
    }
    else
    {
        NSLog(@"searchListDoTotalApp not loaded");
        self.searchLoadCount ++;
        if (self.searchLoadCount > 12)
        {
            self.searchLoadCount = 0;
            [self performSelector:@selector(begainSearch) withObject:nil afterDelay:10];
        }
        else
        {
            [self performSelector:@selector(searchListDoTotalApp) withObject:nil afterDelay:5];
        }
        
    }
}

- (void)doSearchCell:(SKUIStorePageSectionsViewController *)skpagesectionVC
{
    if (self.bSkip)
    {
        self.tabBarVc.selectedIndex = 0;
        return;
    }
    BOOL bfindCell = NO;
    NSArray *viewElements = [self getViewElements:skpagesectionVC];
    UICollectionView *collection = skpagesectionVC.collectionView;
    NSInteger count = [collection numberOfItemsInSection:0];
    for (int i = 0; i < viewElements.count; i++)
    {
        SKUICardViewElement *cardElement = viewElements[i];
        NSDictionary *attributes = cardElement.attributes;
        NSString *appid = attributes[@"data-content-id"];
        if ([appid isEqualToString:self.currentapp.searchAppID])
        {
            rankIndex = i+1;
            self.statusLabel.text = [NSString stringWithFormat:@"searchs %ld find %@ rank %i",(long)count,appid,i+1];
            NSLog(@"----doSearchCell---%@",self.statusLabel.text);
            if (self.bSkip)
            {
                self.tabBarVc.selectedIndex = 0;
            }
            else
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                if (i < count)
                {
                    bfindCell = YES;
                    [collection scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                    self.bInAppInfoPage = YES;
                    if (self.keywodIndex >= self.currentapp.moreKeywords.count)
                    {
                        self.bDoAppInfoDownload = NO;
                    }
                    self.keywodIndex ++;
                    [collection.delegate collectionView:collection didSelectItemAtIndexPath:index];
                }
                else
                {
                    self.statusLabel.text = [NSString stringWithFormat:@"searchs i = %i count = %ld ",i,(long)count];
                }
            }
            break;
        }
    }
    if (!bfindCell)
    {
        NSString *logString = [NSString stringWithFormat:@"%@ searchs %ld count not find %@",self.currentAccount.appleid,(long)count,self.currentapp.searchAppID];
        self.statusLabel.text = logString;
        [self writeLog:logString];
        NSLog(@"----doSearchCell----%@",logString);
        [self doScrollBottom:skpagesectionVC];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSearchCell:) object:skpagesectionVC];
}

- (void)doScrollBottom:(SKUIStorePageSectionsViewController *)skpagesectionVC
{
    UICollectionView *collection = skpagesectionVC.collectionView;
    NSInteger count = [collection numberOfItemsInSection:0];
    if (count < 600)
    {
        if (self.searchResults == count)
        {
            self.commonResultsCount ++;
        }
        else
        {
            self.commonResultsCount = 0;
        }
        
        if (self.commonResultsCount > 6)
        {
            self.commonResultsCount = 0;
            NSString *logString = [NSString stringWithFormat:@"cannot load more search results to find %@",self.currentapp.searchAppID];
            self.statusLabel.text = logString;
            [self writeLog:logString];
            if (self.keywodIndex < self.currentapp.moreKeywords.count)
            {
                self.keywodIndex ++;
            }
            // else
            // {
            //     [self getSearchText];
            // }
            [self begainSearch];
        }
        else
        {
            self.searchResults = count;
            NSIndexPath *index = [NSIndexPath indexPathForRow:count-1 inSection:0];
            [collection scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            CGPoint offset = collection.contentOffset;
            offset.y = offset.y + 568;
            [collection.delegate scrollViewWillEndDragging:collection withVelocity:CGPointMake(0, 6.3) targetContentOffset:&offset];
            [self performSelector:@selector(reloadSearchData:) withObject:skpagesectionVC afterDelay:1];
        }
    }
    else
    {
        NSString *logString = [NSString stringWithFormat:@"not find %@ over 600",self.currentapp.searchAppID];
        self.statusLabel.text = logString;
        [self writeLog:logString];
        if (self.keywodIndex < self.currentapp.moreKeywords.count)
        {
            self.keywodIndex ++;
        }
        // else
        // {
        //     [self getSearchText];
        // }
        [self begainSearch];
    }
}

- (void)reloadSearchData:(SKUIStorePageSectionsViewController *)skpagesectionVC
{
    UICollectionView *collection = skpagesectionVC.collectionView;
    [skpagesectionVC _reloadCollectionView];
    [skpagesectionVC _reloadRelevantEntityProviders];
    [collection reloadData];
    [self performSelector:@selector(doSearchCell:) withObject:skpagesectionVC afterDelay:1];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadSearchData:) object:skpagesectionVC];
}

- (void)doGetError
{
    NSString *logString = [NSString stringWithFormat:@"%@ download failed progress %f",self.currentAccount.appleid,self.progress];
    [self writeLog:logString];
    self.tabBarVc.selectedIndex = 0;
}

- (void)completeReview
{
    NSString *logString = [NSString stringWithFormat:@"%@ review successfully",self.currentAccount.appleid];
    [self writeLog:logString];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.currentapp.workType == 2)
    {
        NSMutableArray *ratingAppids = [NSMutableArray arrayWithArray:self.currentAccount.ratingAppids];
        [ratingAppids addObject:self.currentapp.searchAppID];
        [dic setObject:ratingAppids forKey:@"ratingAppids"];
    }
    else if(self.currentapp.workType == 1)
    {
        NSMutableArray *ratedappids = [NSMutableArray arrayWithArray:self.currentAccount.ratedAppids];
        [ratedappids addObject:self.currentapp.searchAppID];
        [dic setObject:ratedappids forKey:@"rateAppids"];
    }
    [dic setObject:@"0" forKey:@"holdingtime"];
    [dic setObject:self.currentAccount.appleid forKey:@"appleid"];
    [self changeUserInfo:dic bSuccess:YES complete:^(id responseObject, NSError *error) {
        NSString *status = [responseObject objectForKey:@"status"];
        if (error == nil && [status isEqualToString:@"ok"])
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success rate changeUserInfo success",self.currentAccount.appleid];
            [self writeLog:logString];
        }
        else if (error == nil)
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success rate changeUserInfo fail %@",self.currentAccount.appleid,responseObject[@"message"]];
            [self writeLog:logString];
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success rate changeUserInfo fail %@",self.currentAccount.appleid,error.localizedDescription];
            [self writeLog:logString];
        }
        self.tabBarVc.selectedIndex = 0;
    }];
}

- (void)completeDownload
{
    if (self.bHaveCloud)
    {
        NSString *logString = [NSString stringWithFormat:@"%@ redownload successfully",self.currentAccount.appleid];
        [self writeLog:logString];
    }
    else
    {
        NSString *logString = [NSString stringWithFormat:@"%@ download successfully",self.currentAccount.appleid];
        [self writeLog:logString];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *appids = [NSMutableArray arrayWithArray:self.currentAccount.appids];
    [appids addObject:self.currentapp.searchAppID];
    [dic setObject:appids forKey:@"appids"];
    [dic setObject:@"0" forKey:@"holdingtime"];
    [dic setObject:self.currentAccount.appleid forKey:@"appleid"];
    if (self.currentAccount.devicename == nil)
    {
        NSString* userPhoneName = [[UIDevice currentDevice] name];
        [dic setObject:userPhoneName forKey:@"deviceName"];
    }
    [self changeUserInfo:dic bSuccess:YES complete:^(id responseObject, NSError *error) {
        NSString *status = [responseObject objectForKey:@"status"];
        if (error == nil && [status isEqualToString:@"ok"])
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success download changeUserInfo success",self.currentAccount.appleid];
            [self writeLog:logString];
        }
        else if (error == nil)
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success download changeUserInfo fail %@",self.currentAccount.appleid,responseObject[@"message"]];
            [self writeLog:logString];
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:@"%@ success download changeUserInfo fail %@",self.currentAccount.appleid,error.localizedDescription];
            [self writeLog:logString];
        }
        self.tabBarVc.selectedIndex = 0;
    }];
}

// - (void)begainSearch
// {
//     if (self.searchVC)
//     {
//         self.searchVC.searchBar.text = @"";
//         [self.searchVC searchBar:self.searchVC.searchBar textDidChange:@""];
//         [self.searchVC searchBarSearchButtonClicked:self.searchVC.searchBar];
//     }
//     else
//     {
//         self.statusLabel.text = @"searchVC nil not find";
//     }
// }

- (void)begainSearch
{
    self.searchBar = nil;
    UINavigationBar *bar = self.naviVC.navigationBar;
    NSArray *barsview = [bar subviews];
    for (UIView *view in barsview) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            UISearchBar *bar = (UISearchBar *)view;
            self.searchBar = bar;
            break;
        }
    }
    if (!self.bSkip)
    {
        if (self.searchBar)
        {
            self.searchBar.text = @"";
            SKUISearchFieldController *searchDelegate = (SKUISearchFieldController *)self.searchBar.delegate;
            [searchDelegate searchBar:self.searchBar textDidChange:@""];
            [searchDelegate performSelector:@selector(searchBarSearchButtonClicked:) withObject:self.searchBar afterDelay:1];
            // [self.searchBar.delegate searchBarSearchButtonClicked:self.searchBar];
            [self performSelector:@selector(searchListDoTotalApp) withObject:nil afterDelay:8];
        }
        else
        {
            self.statusLabel.text = @"searchBar nil not find";
            [self writeErrorAccout:@"not find searchBar"];
            notify_post("com.lotogram.changeappstorereopen");
        }
    }
    else
    {
        self.tabBarVc.selectedIndex = 0;
    }
}

@end
