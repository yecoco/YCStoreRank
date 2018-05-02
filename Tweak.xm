#import "RankManager.h"
#import "SBAutoManager.h"
#import "LotoDeviceManager.h"

%group WorkAppRank

/*------------------------------------SpringBoard Hook------------------------------------*/
void LogEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [SBAutoManager sharedInstance].bAppStoreLive = YES;
    NSLog(@"-----------------------------LogEvent------------------------------");
}

void rateEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [SBAutoManager sharedInstance].bDelayRate = YES;
    [[SBAutoManager sharedInstance] randomVerifySerialNumber];
    int time = arc4random_uniform(6) + 10;
    float delayTime = time * 60.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // system("killall -9 StoreKitUIService");
        // system("killall -9 itunesstored");
        [[SBAutoManager sharedInstance] delayDoNext];
    });
    NSLog(@"-----------------------------rateEvent------------------------------");
}

void ChangeSNEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [[SBAutoManager sharedInstance] randomVerifySerialNumber];
    [[SBAutoManager sharedInstance] performSelector:@selector(delayDoNext) withObject:nil afterDelay:5];
    //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //      // system("killall -9 StoreKitUIService");
    //      // system("killall -9 itunesstored");
    //     [[SBAutoManager sharedInstance] delayDoNext];
    // });
    NSLog(@"-----------------------------ChangeSNEvent------------------------------");
}

void DeleteEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/applist.plist"];
    NSString *bundleid = [dic objectForKey:@"bundleid"];
    [[SBAutoManager sharedInstance] uninstallApp:bundleid];
    NSLog(@"-----------------------------DeleteEvent------------------------------");
}

void itunesStoredEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    system("killall -9 itunesstored");
    NSLog(@"-----------------------------itunesStoredEvent------------------------------");
}

void reopenEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    system("killall -9 AppStore");
    [[SBAutoManager sharedInstance] delayDoNext];
    NSLog(@"-----------------------------reopenEvent------------------------------");
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    NSLog(@"---------applicationDidFinishLaunching");
    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            LogEvent,
            (CFStringRef)@"com.lotogram.appstore_to_springboard",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            rateEvent,
            (CFStringRef)@"com.lotogram.doratedelaytime",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            ChangeSNEvent,
            (CFStringRef)@"com.lotogram.appstorechangedeviceinfo",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            DeleteEvent,
            (CFStringRef)@"com.lotogram.appstoredeleteapp",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            itunesStoredEvent,
            (CFStringRef)@"com.lotogram.appstoredeleteitunesstoredfile",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            reopenEvent,
            (CFStringRef)@"com.lotogram.changeappstorereopen",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);
    //[[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/AppRank/applist.plist" error:nil];
    %orig(application);
}
%end

//ios9解锁屏幕
%hook SBLockScreenViewController
-(void)viewDidAppear:(BOOL)arg1
{
    NSLog(@"SpringBoard---------SBLockScreenViewController");
    %orig(arg1);
    [SBAutoManager sharedInstance].bAutoCheck = YES;
    [self performSelector:@selector(attemptToUnlockUIFromNotification) withObject:nil afterDelay:2];
    [[SBAutoManager sharedInstance] performSelector:@selector(checkAutoTxt) withObject:nil afterDelay:5];
}
%end

//ios9 AppStore输入账号密码提示框及各种提示的弹窗
%hook SBUserNotificationAlertSheet
-(void)dismissWithClickedButtonIndex:(long long)arg1 animated:(BOOL)arg2
{
    if (arg1 == 1 || arg1 == 0)
    {
        %orig(arg1,arg2);
    }
    else
    {
        %orig(1,arg2);
    }
}

- (void)setDelegate:(id)delegate
{
    NSString *className = NSStringFromClass([delegate class]);
    if ([className isEqualToString:@"SBUserNotificationAlert"])
    {
        SBUserNotificationAlert *sbalert = (SBUserNotificationAlert *)delegate;
        NSString *ahead = sbalert.alertHeader;
        NSString *txtPath = @"/var/mobile/Media/AppRank/currentuser.plist";
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:txtPath];
        NSArray *objectArray = [NSArray arrayWithObjects:delegate,self, nil];
        if (dic != nil)
        {
            if ([ahead isEqualToString:@"Sign In to iTunes Store"])
                [[SBAutoManager sharedInstance] performSelector:@selector(alertdo:) withObject:objectArray afterDelay:2];
            else
                [[SBAutoManager sharedInstance] performSelector:@selector(alertdo:) withObject:objectArray afterDelay:1];
        }
        else
        {
            NSLog(@"------SBUserNotificationAlertSheet----currentuser.plist--nil");
        }
    }
    %orig(delegate);
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    NSString *alertTitle = [self title];
    NSString *alertMessage = [self message];
    NSString *txtPath = @"/var/mobile/Media/AppRank/currentuser.plist";
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:txtPath];
    NSString *appleid = [dic objectForKey:@"appleid"];
    NSString *applepwd = [dic objectForKey:@"applepwd"];
    NSLog(@"Current Login User %@ alert title:%@ message:%@",appleid,alertTitle,alertMessage);
    UITextField *currentTF = %orig(textFieldIndex);
    if (textFieldIndex == 0)
    {
        if ((alertMessage == nil || alertMessage.length == 0) && [alertTitle isEqualToString:@"Sign In to iTunes Store"])
        {
            currentTF.text = appleid;
        }
        else if (([alertTitle isEqualToString:@"Sign In to iTunes Store"]||[alertTitle isEqualToString:@"Sign-In Required"])&& alertMessage !=nil)
        {
            currentTF.text = applepwd;
        }
    }
    else if (textFieldIndex == 1)
    {
        currentTF.text = applepwd;
    }
    return currentTF;
}
%end

//iOS9 账号密码输入框的AlertView点击方法
%hook SBUserNotificationAlert
-(void)alertView:(id)arg1 clickedButtonAtIndex:(long long)arg2 
{
    if (arg2 == 1 || arg2 == 0)
    {
        %orig(arg1,arg2);
    }
    else 
    {
        %orig(arg1,1);
    }
}
%end

//iOS9 用来自动关闭No SIM Card Installed提示框
%hook _UIAlertControllerShimPresenter
%new
- (void)doOkAction
{
    UIAlertController *alert = self.alertController;
    if ([alert.title isEqualToString:@"No SIM Card Installed"])
    {
        typedef void (^actionHandle)(UIAlertAction *action);
        actionHandle handle = nil;
        UIAlertAction *action = alert.actions.firstObject;
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
            [self.legacyAlert dismissWithClickedButtonIndex:0 animated:NO];
            [self.legacyAlert.delegate alertView:self.legacyAlert clickedButtonAtIndex:0];
            handle(action);
        }
        else
        {
            NSLog(@"handle nil");
        }
    }
}

-(void)_presentAlertControllerAnimated:(BOOL)arg1 completion:(void (^)(void))arg2
{
    NSLog(@"_UIAlertControllerShimPresenter _presentAlertControllerAnimated");
    %orig(arg1,arg2);
    [self performSelector:@selector(doOkAction) withObject:nil afterDelay:1];
}
%end

//iOS10 解锁屏幕
%hook SBDashBoardViewController
%new
- (void)lotounlockScreen
{
    [(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:nil];
}
%new
- (void)lotolightScreen
{
    [(SBBacklightController *)[%c(SBBacklightController) sharedInstance] turnOnScreenFullyWithBacklightSource:1];
}

-(void)viewDidAppear:(BOOL)arg1
{
    NSLog(@"SBDashBoardViewController viewDidAppear");
    %orig(arg1);
    [SBAutoManager sharedInstance].bAutoCheck = YES;
    [(SBBacklightController *)[%c(SBBacklightController) sharedInstance] cancelLockScreenIdleTimer];
    [self performSelector:@selector(lotolightScreen) withObject:nil afterDelay:1];
    [self performSelector:@selector(lotounlockScreen) withObject:nil afterDelay:2];
    [[SBAutoManager sharedInstance] performSelector:@selector(checkAutoTxt) withObject:nil afterDelay:5];
}
%end

//iOS10 AppStore输入账号密码提示框及各种提示的弹窗包括No SIM Card Installed
%hook SBSharedModalAlertItemPresenter
%new
- (void)doOkSimAlert:(SBSIMLockAlertItem *)alertItem
{
    typedef void (^actionHandle)(UIAlertAction *action);
    actionHandle handle = nil;
    UIAlertController *alert = [alertItem _alertController];
    if (alert == nil)
    {
        NSLog(@"SBSIMLockAlertItem _alertController nil");
        return;
    }
    UIAlertAction *action = alert.actions.firstObject;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doOkSimAlert:) object:alertItem];
}

-(void)presentAlertItem:(id)arg1 isLocked:(BOOL)arg2 animated:(BOOL)arg3
{
    [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"SBSharedModalAlertItemPresenter presentAlertItem %@",arg1]];
    %orig(arg1,arg2,arg3);
    NSString *className = NSStringFromClass([arg1 class]);
    if ([className isEqualToString:@"SBSIMLockAlertItem"])
    {
        NSLog(@"className %@",className);
        SBSIMLockAlertItem *alertItem = (SBSIMLockAlertItem *)arg1;
        [self performSelector:@selector(doOkSimAlert:) withObject:alertItem afterDelay:1];
        return;
    }
    else if (![className isEqualToString:@"SBUserNotificationAlert"])
    {
        return;
    }
    SBUserNotificationAlert *alertItem = (SBUserNotificationAlert *)arg1;
    UIAlertController *alert = [alertItem _alertController];
    if (!alert)
    {
        NSLog(@"alertController nil");
        return;
    }
    else
    {
        NSString *alerttitle = alertItem.alertHeader;
        NSString *logString = [NSString stringWithFormat:@"alert %@",alerttitle];
        [[SBAutoManager sharedInstance] writeLog:logString];
        if ([alerttitle isEqualToString:@"Sign In to iTunes Store"]||[alerttitle isEqualToString:@"Sign-In Required"])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/currentuser.plist";
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:txtPath];
            if (dic != nil)
            {
                NSString *appleid = [dic objectForKey:@"appleid"];
                NSString *applepwd = [dic objectForKey:@"applepwd"];
                NSLog(@"%@ do 1111111",alerttitle);
                NSArray *textFields = alert.textFields;
                if (textFields.count == 0 || textFields == nil)
                {
                    NSLog(@"alertController not nil but textFields nil");
                }
                else if(textFields.count == 1)
                {
                    UITextField *textField = textFields.firstObject;
                    textField.text = applepwd;
                }
                else if(textFields.count == 2)
                {
                    UITextField *textField = textFields.firstObject;
                    textField.text = appleid;
                    textField = textFields.lastObject;
                    textField.text = applepwd;
                }
                else
                {
                    NSLog(@"over 3 count textFields");
                }
                NSArray *objectArray = [NSArray arrayWithObjects:alertItem,@(1),nil];
                [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:2];
            }   
        }
        else if ([alerttitle isEqualToString:@"Sign in to write a Customer Review."])
        {
            NSLog(@"%@ do 1111111",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem,@(1),nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:2];
        }
        else if ([alerttitle isEqualToString:@"Require password for additional purchases on this device?"])
        {
            NSLog(@"%@ do 000000",alerttitle);
            [SBAutoManager sharedInstance].bShowAgree = NO;
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if ([alerttitle isEqualToString:@"You've already purchased this, so it will be downloaded now at no additional charge."])
        {
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
            notify_post("com.lotogram.springboard_purchased_tips");
        }
        else if ([alerttitle isEqualToString:@"Apple Media Services Terms and Conditions have changed."])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if ([SBAutoManager sharedInstance].bShowAgree == NO)
            {
                [SBAutoManager sharedInstance].bShowAgree = YES;
                NSLog(@"%@ do 1111111",alerttitle);
                NSArray *objectArray = [NSArray arrayWithObjects:alertItem,@(1),nil];
                [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
            }
            else
            {
                NSLog(@"%@ do 000000",alerttitle);
                NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
                [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
            }
        }
        else if ([alerttitle isEqualToString:@"Verification Failed"])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if([alerttitle isEqualToString:@"Your Apple ID has been disabled."])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if([alerttitle isEqualToString:@"Verification Required"])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if([alerttitle isEqualToString:@"Apple ID Verification"])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if([alerttitle isEqualToString:@"Cannot connect to iTunes Store"])
        {
            NSString *txtPath = @"/var/mobile/Media/AppRank/alert.txt";
            [alerttitle writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        }
        else if([alerttitle isEqualToString:@"This nickname is taken. Enter another and try again."])
        {
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
            notify_post("com.lotogram.changenickname");
        }
        else 
        {
            NSLog(@"%@ do 000000",alerttitle);
            NSArray *objectArray = [NSArray arrayWithObjects:alertItem, nil];
            [[SBAutoManager sharedInstance] performSelector:@selector(doContinue:) withObject:objectArray afterDelay:1];
        } 
    }
}
%end

/*------------------------------------硬件信息 Hook------------------------------------*/
%hook SSLockdown
-(CFStringRef)copyDeviceGUID
{
    NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (guidstring == nil)
    {
        return %orig;
    }
    const char *a =[guidstring UTF8String];
    CFStringRef strRef = __CFStringMakeConstantString(a);
    if (strRef == nil)
    {
        strRef = %orig;
    }
    //CFStringRef strRef = %orig;
    NSLog(@"----SSLockdown---copyDeviceGUID--%@",strRef);
    return strRef;
}
%end
%hook NSUUID
+ (id)UUID
{
    // NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    // NSLog(@"NSUUID---UUID---%@",guidstring);
    NSUUID *uuid = %orig;
    return uuid;
}

- (NSString *)UUIDString
{
    NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (!guidstring)
    {
        return %orig;
    }
    NSLog(@"NSUUID---UUIDString---%@",guidstring);
    return guidstring;
}
- (id)initWithUUIDString:(id)arg1
{
    NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (!guidstring)
    {
        return %orig;
    }
    NSLog(@"NSUUID---initWithUUIDString---%@",guidstring);
    return %orig(guidstring);
}
%end

%hook UIDevice
- (NSUUID *)identifierForVendor
{
    NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (!guidstring)
    {
        return %orig;
    }
    NSLog(@"UIDevice---identifierForVendor---%@",guidstring);
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:guidstring];
    return uuid;
}
%end

%hook AKDevice
- (NSString *)userChosenName
{
    NSString *userChosen= %orig;
    NSLog(@"------AKDevice-----userChosenName:%@",userChosen);
    return userChosen;
}

- (NSString *)serialNumber
{
    NSString *serialstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"serial"];
    if (serialstring == nil)
    {
        serialstring = %orig;
    }
    NSLog(@"------AKDevice-----serialNumber:%@",serialstring);
    return serialstring;
}

- (NSString *)internationalMobileEquipmentIdentity
{
    NSString *internationalMobile = [[LotoDeviceManager sharedInstance] currentuserobject:@"IMEI"];
    if (!internationalMobile)
    {
        internationalMobile = %orig;
    }
    NSLog(@"------AKDevice-----internationalMobileEquipmentIdentity:%@",internationalMobile);
    return internationalMobile;
}

- (NSString *)mobileEquipmentIdentifier
{
    NSString *mobileEquipment = %orig;
    NSLog(@"------AKDevice-----mobileEquipmentIdentifier:%@",mobileEquipment);
    return mobileEquipment;
}

- (NSString *)uniqueDeviceIdentifier
{
    NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (!guidstring)
    {
        guidstring = %orig;
    }
    NSLog(@"------AKDevice-----uniqueDeviceIdentifier:%@",guidstring);
    return guidstring;
}

- (NSString *)integratedCircuitCardIdentifier
{
    NSString *integratedCircuitCard = %orig;
    NSLog(@"------AKDevice-----integratedCircuitCardIdentifier:%@",integratedCircuitCard);
    return integratedCircuitCard;
}
%end

%hook SSDevice
- (NSString *)serialNumber
{
    NSString *serialstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"serial"];
    if (serialstring == nil)
    {
        serialstring = %orig;
    }
    NSLog(@"------SSDevice-----serialNumber:%@",serialstring);
    return serialstring;
}

- (NSString *)uniqueDeviceIdentifier
{
     NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (guidstring == nil)
    {
        guidstring = %orig;
    }
    NSLog(@"------SSDevice-----guid:%@",guidstring);
    return guidstring;
}

%end

%hook ISDevice
- (NSString *)serialNumber
{
    NSString *serialstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"serial"];
    if (serialstring == nil)
    {
        serialstring = %orig;
    }
    NSLog(@"------ISDevice-----serialNumber:%@",serialstring);
    return serialstring;
}

- (NSString *)guid
{
     NSString *guidstring = [[LotoDeviceManager sharedInstance] currentuserobject:@"uuid"];
    if (guidstring == nil)
    {
        guidstring = %orig;
    }
    NSLog(@"------ISDevice-----guid:%@",guidstring);
    return guidstring;
}
%end

/*------------------------------------Rate Hook------------------------------------*/
%hook SKUIComposeReviewFormViewController
-(id)initWithReviewMetadata:(id)arg1
{
    [[RankManager sharedInstance] writeLog:@"SKUIComposeReviewFormViewController initWithReviewMetadata"];
    SKUIReviewMetadata *metaData = (SKUIReviewMetadata *)arg1;
    NSDictionary *rankdic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/applist.plist"];
    RankAppModel *rankApp = [RankAppModel itemWithDictionary:rankdic];
    if (metaData.nickname != nil && metaData.nickname.length >0 && metaData.body != nil && metaData.body.length >0 && metaData.title != nil && metaData.title.length >0)
    {
        [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"%@ have rate before",metaData.nickname]];
    }
    else if (rankApp.workType == 2)
    {
        if (metaData.nickname == nil || metaData.nickname.length == 0)
        {
            metaData.nickname = [[RankManager sharedInstance] getNickName];
        }
        metaData.rating = 4;
    }
    else if (rankApp.workType == 1)
    {
        RateModel *rate = nil;
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/currentrate.plist"];
        rate = [RateModel itemWithDictionary:dic];
        if (rate == nil)
        {
            [[RankManager sharedInstance] writeLog:@"currentrate nil pause"];
            return %orig(arg1);
        }
        if (metaData.nickname == nil || metaData.nickname.length == 0)
        {
            metaData.nickname = rate.nickname;
        }
        metaData.title = rate.title;
        metaData.rating = rate.rating;
        metaData.body = rate.body;
    }
    return %orig(metaData);
}

- (void)viewDidAppear:(_Bool)arg1
{
    [[RankManager sharedInstance] writeLog:@"SKUIComposeReviewFormViewController viewDidAppear"];
    %orig(arg1);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(_submit) withObject:nil afterDelay:4];
    });
}
%end

%hook SKComposeReviewViewController
-(void)_didFinishWithResult:(BOOL)arg1 error:(id)arg2
{
    [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"SKComposeReviewViewController _didFinishWithResult %i %@",arg1,arg2]];
    notify_post("com.lotogram.ratesubmitclicked");
    %orig(arg1,arg2);
}
%end

/*------------------------------------AppStore Hook------------------------------------*/
%hook SUStorePageViewController
- (void)_finishWebViewLoadWithResult:(bool)arg1 error:(id)arg2
{
    NSLog(@"----_finishWebViewLoadWithResult----");
    %orig(arg1,arg2);
    UINavigationController *storeNaviVC = self.navigationController;
    UIToolbar *bar = storeNaviVC.toolbar;
    NSArray *items = bar.items;
    for (int i = 0; i < items.count; i++)
    {
        UIBarButtonItem *item = items[i];
        if ([item.title isEqualToString:@"Agree"])
        {
            [item.target performSelector:item.action withObject:item afterDelay:0];
            break;
        }
    }
}
%end

%hook UIAlertView
%new 
- (void)completeAgreeDo
{
    NSLog(@"UIAlertView completeAgreeDo");
    [self.delegate alertView:self didDismissWithButtonIndex:0];
    [self dismissWithClickedButtonIndex:1 animated:NO];
}
%new
- (void)agreedonext
{
    NSLog(@"UIAlertView agreedonext");
    [self.delegate alertView:self clickedButtonAtIndex:1];
    [self dismissWithClickedButtonIndex:1 animated:NO];
}

- (void)show
{
    NSLog(@"UIAlertView show message%@",self.message);
    if ([self.message isEqualToString:@"I have read and agree to the Apple Media Services Terms & Conditions."])
    {
        [self performSelector:@selector(agreedonext) withObject:nil afterDelay:2];
    }
    else if([self.message rangeOfString:@"now begin to download."].location !=NSNotFound)//_roaldSearchText
    {
        [self performSelector:@selector(completeAgreeDo) withObject:nil afterDelay:2];
    }
    else
    {
        [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"UIAlertView show message:%@",self.message]];
    }
    %orig;
}
%end

%hook UIAlertController
%new
- (void)doContinue:(NSNumber *)bcontinue
{
    typedef void (^actionHandle)(UIAlertAction *action);
    actionHandle handle = nil;
    UIAlertAction *action = self.actions.firstObject;
    if (bcontinue)
    {
        action = self.actions.lastObject;
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
       [self dismissViewControllerAnimated:NO completion:nil];

    }
    else
    {
        NSLog(@"handle nil");
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doContinue:) object:bcontinue];
}

- (void)viewDidAppear:(_Bool)arg1
{
    %orig(arg1);
    NSLog(@"UIAlertController viewDidAppear title:%@ message:%@",self.title,self.message);
    if ([self.title isEqualToString:@"Item Not Available"])
    {
        [self performSelector:@selector(doContinue:) withObject:nil afterDelay:1];
    }
}
%end


%hook SKUIAccountButtonsView
- (void)layoutSubviews
{
    [RankManager sharedInstance].appleIDButton = self.appleIDButton;
    %orig;
}
%end

%hook SKUIStorePageSectionsViewController
%new
- (void)doSuccessGetUser:(NSDictionary *)user
{
    AppleAccountModel *account = [AppleAccountModel itemWithDictionary:user];
    [RankManager sharedInstance].currentAccount = account;
    NSDictionary *accountdic = [account toDictionary];
    NSString *logString = [NSString stringWithFormat:@"success getuser %@",account.appleid];
    [[RankManager sharedInstance] writeLog:logString];
    if([accountdic writeToFile:@"/var/mobile/Media/AppRank/currentuser.plist" atomically:YES])
    {
        [RankManager sharedInstance].statusLabel.text = @"check sign in.....";
        [[RankManager sharedInstance].appleIDButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        if ([RankManager sharedInstance].bCheckSignin == NO)
        {
            [[RankManager sharedInstance] checksigninstatues];
        }
        else
        {
            [RankManager sharedInstance].statusLabel.text = @"already in checksigninstatues";
        }
    }
    else
    {
        [RankManager sharedInstance].statusLabel.text = @"getUserToLogin writeToFile fail";
    }
}

%new
- (void)getUserToLogin
{    
    [[RankManager sharedInstance] getUserFromServer:YES complete:^(id responseObject, NSError *error) {
        NSString *status = [responseObject objectForKey:@"status"];
        if (error == nil && [status isEqualToString:@"ok"])
        {   
            NSDictionary *user = responseObject[@"user"];
            NSDictionary *task = responseObject[@"task"];
            NSDictionary *rate = responseObject[@"rate"];
            if (rate)
            {
                [RankManager sharedInstance].currentRate = [RateModel itemWithDictionary:rate];
                NSDictionary *ratedic = [[RankManager sharedInstance].currentRate toDictionary];
                [ratedic writeToFile:@"/var/mobile/Media/AppRank/currentrate.plist" atomically:YES];
            }
            [RankManager sharedInstance].currentapp = [RankAppModel itemWithDictionary:task];
            NSDictionary *dic = [[RankManager sharedInstance].currentapp toDictionary];
            [dic writeToFile:@"/var/mobile/Media/AppRank/applist.plist" atomically:YES];
            [self performSelector:@selector(doSuccessGetUser:) withObject:user afterDelay:0];
        }
        else
        {
            NSString *logString = @"";
            if (error != nil)
            {
                logString = [NSString stringWithFormat:@"have devicename fail getuser %@",error.localizedDescription];
            }
            else
            {
                logString = [NSString stringWithFormat:@"have devicename fail getuser %@",responseObject[@"message"]];
            }
            [[RankManager sharedInstance] writeLog:logString];
            [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"%@",logString];
        }
    }];
}

%new
- (void)doLogoutAction
{
    if ([RankManager sharedInstance].accountVC)
    {
        NSString *logString = [NSString stringWithFormat:@"%@ second sign out",[RankManager sharedInstance].currentAccount.appleid];
        [[RankManager sharedInstance] writeLog:logString];
        [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"%@ sign out.......",[RankManager sharedInstance].currentAccount.appleid];
        [[RankManager sharedInstance].accountVC _signOut];
        [RankManager sharedInstance].signoutcount = 0;
        if ([RankManager sharedInstance].bCheckSignout == NO)
        {
            [[RankManager sharedInstance] checksignoutstatues];
        }
        else
        {
            [RankManager sharedInstance].statusLabel.text = @"already in checksignoutstatues";
        }
    }
    else
    {
        NSString *logString = [NSString stringWithFormat:@"%@ still signout not found SKUIAccountButtonsViewController",[RankManager sharedInstance].currentAccount.appleid];
        [[RankManager sharedInstance] writeLog:logString];
        [RankManager sharedInstance].statusLabel.text = @"still sign out not found SKUIAccountButtonsViewController";
    }
}

%new 
- (void)bottomTodoNext
{
    if ([RankManager sharedInstance].appleIDButton == nil)
    {
        [RankManager sharedInstance].bLoadFeaturePage = YES;
        [RankManager sharedInstance].statusLabel.text = @"please wait scrollToBottom";
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:2];
    }
    else
    {
        NSString *txtPath = @"/var/mobile/Media/AppRank/auto.txt";
        NSString *autoString = [[NSString alloc] initWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        autoString = [autoString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        autoString = [autoString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        autoString = [autoString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *btnTitle = [RankManager sharedInstance].appleIDButton.titleLabel.text;
        if (![btnTitle isEqualToString:@"Sign In"] && [autoString isEqualToString:@"complete"])
        {
            [[RankManager sharedInstance].accountVC _signOut];
            [RankManager sharedInstance].statusLabel.text =[NSString stringWithFormat:@"auto.txt = %@",autoString];
            [RankManager sharedInstance].bLoadFeaturePage = YES;
        }
        else if(![btnTitle isEqualToString:@"Sign In"])
        {
            if ([RankManager sharedInstance].bLoadFeaturePage && [RankManager sharedInstance].currentapp.shouldOpen)
            {
                NSString *autoPath = @"/var/mobile/Media/AppRank/auto.txt";
                NSString *startString = @"opendone";
                [startString writeToFile:autoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                exit(0);
            }
            else
            {
                [RankManager sharedInstance].bLoadFeaturePage = YES;
                if ([RankManager sharedInstance].accountVC)
                {
                    [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"%@ sign out.......",[RankManager sharedInstance].currentAccount.appleid];
                    [[RankManager sharedInstance].accountVC _signOut];
                    [RankManager sharedInstance].signoutcount = 0;
                    if ([RankManager sharedInstance].bCheckSignout == NO)
                    {
                        [[RankManager sharedInstance] checksignoutstatues];
                    }
                    else
                    {
                        [RankManager sharedInstance].statusLabel.text = @"already in checksignoutstatues";
                    }
                }
                else
                {
                    [RankManager sharedInstance].statusLabel.text = @"sign out not found SKUIAccountButtonsViewController";
                    [self performSelector:@selector(doLogoutAction) withObject:nil afterDelay:5];
                }
            }
        }
        else if ([btnTitle isEqualToString:@"Sign In"] &&([autoString isEqualToString:@"start"] || [autoString hasPrefix:@"restart"] || [autoString hasPrefix:@"openstart"]))
        {
            [RankManager sharedInstance].bLoadFeaturePage = YES;
            [RankManager sharedInstance].signcount = 0;
            [RankManager sharedInstance].statusLabel.text = @"get user from server...";
            [self performSelector:@selector(getUserToLogin) withObject:nil afterDelay:0];
        } 
        else
        {
            [RankManager sharedInstance].statusLabel.text =[NSString stringWithFormat:@"auto.txt = %@",autoString];
            [RankManager sharedInstance].bLoadFeaturePage = YES;
        }
    }
}

%new
- (void)scrollToBottom
{
    id view = self.view.subviews.firstObject;
    if ([view isKindOfClass:[UICollectionView class]])
    {
        UICollectionView *collection = (UICollectionView *)view;
        NSInteger sections = [collection numberOfSections];
        NSInteger cellcount = [collection numberOfItemsInSection:sections-1];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(cellcount-1) inSection:sections-1];
        [collection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        [self performSelector:@selector(bottomTodoNext) withObject:nil afterDelay:2.0f];
    }
    else
    {
        [RankManager sharedInstance].statusLabel.text = @"featured page no find UICollectionView";
    }  
}

%new
- (void)doBackToSearchList
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(_Bool)arg1
{
    %orig(arg1);
    notify_post("com.lotogram.appstore_to_springboard");
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleID isEqualToString:@"com.apple.AppStore"])
    {
        notify_post("com.lotogram.changeappstorereopen");
        [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"reopen appstore bundleid:%@",bundleID]];
        return;
    }
    UITabBarController *tabbarvc = self.tabBarController;
    if ([RankManager sharedInstance].bInDownloading)
    {
        [[RankManager sharedInstance] writeLog:@"bInDownloading do select 3"];
        tabbarvc.selectedIndex = 3;
        return;
    }
    if (tabbarvc == nil || ![tabbarvc isKindOfClass:[UITabBarController class]])
    {
        [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"self.tabBarController is nil %@",NSStringFromClass([tabbarvc class])];
        return;
    }
    [RankManager sharedInstance].tabBarVc = tabbarvc;
    if (tabbarvc.selectedIndex == 0) 
    {
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:2.0f];
        [RankManager sharedInstance].bInAppInfoPage = NO;
    }
    else if(tabbarvc.selectedIndex == 3 && [RankManager sharedInstance].progress >= 0.9)
    {
        [RankManager sharedInstance].bInDownloading = NO;
        tabbarvc.selectedIndex = 0;
    }
    else if([RankManager sharedInstance].bInAppInfoPage && tabbarvc.selectedIndex == 3)
    {
        [RankManager sharedInstance].bInAppInfoPage = NO;
        [RankManager sharedInstance].currentVC = self;
        if ([RankManager sharedInstance].keywodIndex > [RankManager sharedInstance].currentapp.moreKeywords.count)
        {
            NSLog(@"SKUIStorePageSectionsViewController viewDidAppear doAppInfoPageDownload");
            if ([[RankManager sharedInstance] checkIsOpen])
            {
                [RankManager sharedInstance].statusLabel.text = @"find OPEN";
                [[RankManager sharedInstance] writeLog:@"find OPEN"];
                tabbarvc.selectedIndex = 0;
                return;
            } 
            [[RankManager sharedInstance] performSelector:@selector(doAppInfoPageDownload) withObject:nil afterDelay:1];
        }
        else if ([RankManager sharedInstance].keywodIndex == 1)
        {
            NSLog(@"SKUIStorePageSectionsViewController viewDidAppear doBackAndSearch keywodIndex 1");
            if ([[RankManager sharedInstance] checkIsOpen])
            {
                [RankManager sharedInstance].statusLabel.text = @"find OPEN";
                [[RankManager sharedInstance] writeLog:@"find OPEN"];
                tabbarvc.selectedIndex = 0;
                return;
            }
            if([[RankManager sharedInstance] checkIsCloud])
            {
                [self.navigationController popViewControllerAnimated:YES]; 
                [[RankManager sharedInstance] completeDownload];
            }
            else
            {
                [self performSelector:@selector(doBackToSearchList) withObject:nil afterDelay:1.0f];
                [[RankManager sharedInstance] performSelector:@selector(begainSearch) withObject:nil afterDelay:2];
            }
        }
        else 
        {
            NSLog(@"SKUIStorePageSectionsViewController viewDidAppear doBackAndSearch keywodIndex %ld",(long)[RankManager sharedInstance].keywodIndex);  
            [self performSelector:@selector(doBackToSearchList) withObject:nil afterDelay:1.0f];
            [[RankManager sharedInstance] performSelector:@selector(begainSearch) withObject:nil afterDelay:2];
        }
    }
}

// -(void)_endAllPendingActiveImpression
// {
//     %orig;
//     NSLog(@"SKUIStorePageSectionsViewController _endAllPendingActiveImpression");
//     [[RankManager sharedInstance] writeLog:@"_endAllPendingActiveImpression"];
//     if ([RankManager sharedInstance].bSelectedReview)
//     {
//         [self performSelector:@selector(doTouchWriteReview) withObject:nil afterDelay:5];
//     }
// }
%end

%hook SKUIItemOfferButton
- (void)setProgress:(double)arg1 animated:(_Bool)arg2
{
    // %orig(arg1,arg2);
    // [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"rank:%i progress %f",rankIndex,arg1];
    // if (arg1 > 0)
    // {
    //     [RankManager sharedInstance].progress = arg1;
    //     [RankManager sharedInstance].bInDownloading = YES;
    // }
    // if (arg1 > 0.2 && ![RankManager sharedInstance].bDownloadSuccess)
    // {
    //     NSLog(@"---------setProgress > 0.2 pause download");
    //     [RankManager sharedInstance].bDownloadSuccess = YES;
    //     [self.delegate performSelector:@selector(_buttonAction:) withObject:self afterDelay:0];
    //     // [[RankManager sharedInstance] performSelector:@selector(completeDownload) withObject:nil afterDelay:2];
    //     if ([RankManager sharedInstance].currentapp.workType == 0)
    //     {
    //         [RankManager sharedInstance].bInDownloading = NO;
    //         [[RankManager sharedInstance] performSelector:@selector(completeDownload) withObject:nil afterDelay:2];
    //     }
    //     else if ([RankManager sharedInstance].currentapp.workType == 1 || [RankManager sharedInstance].currentapp.workType == 2)
    //     {
    //         [[RankManager sharedInstance] performSelector:@selector(doReview) withObject:nil afterDelay:2];
    //     }
    // }

    %orig(arg1,arg2);
    [RankManager sharedInstance].statusLabel.text = [NSString stringWithFormat:@"rank:%i progress %f",rankIndex,arg1];
    if (arg1 >= 1 && [RankManager sharedInstance].progress != arg1)
    {
        [RankManager sharedInstance].bInDownloading = NO;
        [[RankManager sharedInstance] performSelector:@selector(completeDownload) withObject:nil afterDelay:3];
    }
    if (arg1 > 0)
    {
        [RankManager sharedInstance].progress = arg1;
        if (arg1 < 0.8)
        {
            [RankManager sharedInstance].bInDownloading = YES;
        }
    }
}
%end

%hook SKUIAccountButtonsViewController
- (void)viewDidAppear:(bool)arg1
{
    [RankManager sharedInstance].accountVC = self;
    %orig(arg1);
}
%end

%hook SKUITrendingSearchDocumentViewController
- (void)viewDidAppear:(bool)arg1
{
    %orig(arg1);
    [RankManager sharedInstance].naviVC = [self navigationController];
    UINavigationBar *bar = [[self navigationController] navigationBar];
    NSArray *barsview = [bar subviews];
    for (UIView *view in barsview) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            UISearchBar *bar = (UISearchBar *)view;
            [RankManager sharedInstance].searchBar = bar;
            break;
        }
    }
}
%end

%hook SKUISearchFieldController
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([RankManager sharedInstance].keywodIndex >= [RankManager sharedInstance].currentapp.moreKeywords.count)
    {
        searchBar.text = [RankManager sharedInstance].currentapp.searchTerms;
    }
    else
    {
        NSString *keyword = [[RankManager sharedInstance].currentapp.moreKeywords objectAtIndex:[RankManager sharedInstance].keywodIndex];
        searchBar.text = keyword;
    }
    %orig(searchBar);
}
%end


// %hook SKUISearchFieldController
// //common
// - (instancetype)init
// {
//     [RankManager sharedInstance].searchVC = self;
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController init"];
//     return %orig;
// }

// - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
// {
//     if ([RankManager sharedInstance].keywodIndex >= [RankManager sharedInstance].currentapp.moreKeywords.count)
//     {
//         // searchBar.text = [RankManager sharedInstance].currentapp.searchTerms;
//         searchBar.text = @"photo color";
//     }
//     else
//     {
//         // NSString *keyword = [[RankManager sharedInstance].currentapp.moreKeywords objectAtIndex:[RankManager sharedInstance].keywodIndex];
//         // searchBar.text = keyword;
//         searchBar.text = @"photo color";
//     }
//     %orig(searchBar);
// }

// -(id)initWithContentsController:(id)arg1
// {
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController initWithContentsController"];
//     [RankManager sharedInstance].searchVC = self;
//     return %orig(arg1);
// }

// -(void)setDisplaysSearchBarInNavigationBar:(BOOL)arg1
// {
//     %orig(arg1);
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController setDisplaysSearchBarInNavigationBar"];
//     [RankManager sharedInstance].searchVC = self;
// }

// -(BOOL)displaysSearchBarInNavigationBar
// {
//     [RankManager sharedInstance].searchVC = self;
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController displaysSearchBarInNavigationBar"];
//     return %orig;
// }

// -(void)_loadResultsForSearchRequest:(id)arg1
// {
//     if (arg1 != nil)
//     {
//         [RankManager sharedInstance].bSendRequest = YES;
//     }
//     %orig(arg1);
//     [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"SKUISearchFieldController _loadResultsForSearchRequest %@",arg1]];
// }

// -(void)searchDisplayController:(id)arg1 didLoadSearchResultsTableView:(id)arg2
// {
//     if ([RankManager sharedInstance].bSendRequest)
//     {
//         [NSObject cancelPreviousPerformRequestsWithTarget:[RankManager sharedInstance] selector:@selector(searchListDoTotalApp) object:nil];
//         [[RankManager sharedInstance] performSelector:@selector(searchListDoTotalApp) withObject:nil afterDelay:5];
//     }
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController didLoadSearchResultsTableView"];
//     %orig(arg1,arg2);
// }

// //ios 10
// -(id)initWithContentsController:(id)arg1 clientContext:(id)arg2
// {
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController initWithContentsController clientContext"];
//     [RankManager sharedInstance].searchVC = self;
//     return %orig(arg1,arg2);
// }

// -(void)updateSearchResultsForSearchController:(id)arg1
// {
//     [[RankManager sharedInstance] writeLog:@"SKUISearchFieldController updateSearchResultsForSearchController"];
//     %orig(arg1);
// }

// %end


%hook SKUITabBarController
%new
- (void)checkLoadSuccess
{
    if (![RankManager sharedInstance].bLoadFeaturePage)
    {
        NSString *autoPath = @"/var/mobile/Media/AppRank/auto.txt";
        NSString *startString = @"done";
        [startString writeToFile:autoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *logString = @"120s featured page load failed";
        [[RankManager sharedInstance] writeLog:logString];
        exit(0);
    }
}
- (void)viewDidAppear:(bool)arg1
{
    %orig(arg1);
    NSLog(@"------SKUITabBarController viewDidAppear");
    self.selectedIndex = 0;
    [RankManager sharedInstance].tabBarVc = self;
    [self performSelector:@selector(checkLoadSuccess) withObject:nil afterDelay:120];
}
%end

void RateSubmitEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[RankManager sharedInstance] selector:@selector(completeReview) object:nil];
    [[RankManager sharedInstance] performSelector:@selector(completeReview) withObject:nil afterDelay:30];
    NSLog(@"-----------------------------RateSubmitEvent------------------------------");
}

void PurchasedEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[RankManager sharedInstance] selector:@selector(checkProgressStatues) object:nil];
    [[RankManager sharedInstance] completeDownload];
    NSLog(@"-----------------------------PurchasedEvent------------------------------");
}

void ReviewDownloadEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[RankManager sharedInstance] selector:@selector(completeReview) object:nil];
    [[RankManager sharedInstance] performSelector:@selector(doDownload) withObject:nil afterDelay:4];
    NSLog(@"-----------------------------ReviewDownloadEvent------------------------------");
}

void ChangeNickNameEvent(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo)
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[RankManager sharedInstance] selector:@selector(completeReview) object:nil];
    if ([RankManager sharedInstance].currentRate == nil)
    {
        NSDictionary *ratedic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/currentrate.plist"];
        [RankManager sharedInstance].currentRate = [RateModel itemWithDictionary:ratedic];
    }
    [RankManager sharedInstance].currentRate.nickname = [[RankManager sharedInstance] newNickName];
    NSDictionary *dic = [[RankManager sharedInstance].currentRate toDictionary];
    [dic writeToFile:@"/var/mobile/Media/AppRank/currentrate.plist" atomically:YES];
    [[RankManager sharedInstance] writeLog:[NSString stringWithFormat:@"ChangeNickNameEvent %@",dic]];
    [[RankManager sharedInstance] performSelector:@selector(doTouchWriteReview) withObject:nil afterDelay:5];
    NSLog(@"-----------------------------ChangeNickNameEvent------------------------------");
}

%hook ASAppDelegate
%new
- (void)btnSkipClicked:(id)sender
{
    NSString *logString = [NSString stringWithFormat:@"%@ skip download",[RankManager sharedInstance].currentAccount.appleid];
    [[RankManager sharedInstance] writeLog:logString];
    if (![RankManager sharedInstance].bCheckProgress)
    {
        [RankManager sharedInstance].bSkip = YES;
    }
}

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            RateSubmitEvent,
            (CFStringRef)@"com.lotogram.ratesubmitclicked",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            ReviewDownloadEvent,
            (CFStringRef)@"com.lotogram.downloadapptoreview",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            ChangeNickNameEvent,
            (CFStringRef)@"com.lotogram.changenickname",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            PurchasedEvent,
            (CFStringRef)@"com.lotogram.springboard_purchased_tips",
            NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    BOOL didfinish = %orig(arg1,arg2);
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window makeKeyAndVisible];
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.y = frame.size.height - 100;
    frame.size.height = 50;
    UIView *polygonView = [[UIView alloc] initWithFrame: frame];
    polygonView.backgroundColor = [UIColor redColor];
    [window addSubview:polygonView];

    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 320, 30)];
    statusLabel.font = [UIFont systemFontOfSize:12];
    [polygonView addSubview:statusLabel];

    UIButton *skipBtn = [[UIButton alloc] init];
    skipBtn.frame = CGRectMake(0, 0, 80, 50);
    [skipBtn setTitle:@"Skip" forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(btnSkipClicked:) forControlEvents:UIControlEventTouchUpInside];
    [polygonView addSubview:skipBtn];

    [RankManager sharedInstance].statusLabel = statusLabel;
    [RankManager sharedInstance].tabBarVc = nil;
    [RankManager sharedInstance].searchBar = nil;
    [RankManager sharedInstance].naviVC = nil;
    [RankManager sharedInstance].appleIDButton = nil;
    [RankManager sharedInstance].accountVC = nil;
    [RankManager sharedInstance].currentVC = nil;
    [RankManager sharedInstance].bDownloadSuccess = NO;
    [RankManager sharedInstance].bInDownloading = NO;
    //notify_post("com.lotogram.appstoredeleteapp");
    // [[RankManager sharedInstance] getSearchText];
    return didfinish;
}

%end

%hook SSAuthenticationContext
-(BOOL)canCreateNewAccount
{
    return NO;
}
%end

// %hook SSDownloadMetadata
// -(id)init
// {
//     return %orig;
// }
// -(BOOL)isRedownloadDownload
// {
//     return NO;
// }
// -(void)setRedownloadDownload:(BOOL)arg1
// {
//     %orig(NO);
// }
// %end

// %hook SSPurchase
// -(void)setUsesLocalRedownloadParametersIfPossible:(BOOL)arg1
// {
//     %orig(NO);
// }
// -(BOOL)usesLocalRedownloadParametersIfPossible
// {
//     return NO;
// }
// -(NSString *)buyParameters
// {
//     NSString *para = %orig;
//     return para;
// }
// -(void)setBuyParameters:(NSString *)arg1
// {
//     NSArray *temps = [arg1 componentsSeparatedByString:@"&"];
//     NSString *searchString = nil;
//     for (NSString *para in temps) {
//         if ([para rangeOfString:@"mtSearchTerm"].location != NSNotFound) {
//             searchString = para;
//             break;
//         }
//     }
//     NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Media/AppRank/applist.plist"];
//     NSString *searchterms = [dic objectForKey:@"searchterms"];
//     NSArray *moreKeywords = [dic objectForKey:@"morekeywords"];
//     NSMutableArray *keyWords = [NSMutableArray arrayWithArray:moreKeywords];
//     [keyWords insertObject:searchterms atIndex:0];
//     // NSArray *moreKeywords = @[@"reflection",@"zoom app",@"photo brush",@"types",@"pattern"];
//     NSString *newSeatchTerm = @"";
//     for (NSString *keyword in keyWords) {
//         if (newSeatchTerm.length == 0) {
//             newSeatchTerm = [newSeatchTerm stringByAppendingString:@"mtSearchTerm="];
//             newSeatchTerm = [newSeatchTerm stringByAppendingString:keyword];
//         }
//         else
//         {
//             newSeatchTerm = [newSeatchTerm stringByAppendingString:@","];
//             newSeatchTerm = [newSeatchTerm stringByAppendingString:keyword];
//         }
//     }
//     if (searchString != nil)
//     {
//         NSString *paras = [arg1 stringByReplacingOccurrencesOfString:searchString withString:@"mtSearchTerm=pink"];
//         %orig(paras);
//     }
//     else
//         %orig(arg1);
// }
// %end
%end

%ctor {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lotogram.lotosettings.plist"];
    NSInteger work = [dic[@"work"] integerValue];
    if (work == 1)
    {
        %init(WorkAppRank);
        printf("---------work apprank-----------");
    }
    else
    {
        printf("---------work other-----------");
    }
}