//
//  SpringBoardHeader.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//
#ifndef SpringBoardHeader_h
#define SpringBoardHeader_h

@interface SBAlertItem : NSObject
-(id)_alertController;
-(id)alertController;
@end

@interface SBSIMLockAlertItem : SBAlertItem
@end

@interface SBUserNotificationAlert : SBAlertItem
@property (retain) NSString * alertHeader;
@property (retain) NSString * alertMessage;
@property (retain) NSString * alertMessageDelimiter;
@property (retain) NSString * lockScreenAlertHeader;
@property (retain) NSString * lockScreenAlertMessage;
@end

@interface SBUserNotificationAlertSheet:UIAlertView
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)path withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
- (BOOL)applicationIsInstalled:(NSString *)appIdentifier;
- (NSArray *)allInstalledApplications;
- (NSArray *)allApplications;
- (NSArray *)applicationsOfType:(unsigned int)appType;
- (BOOL)openApplicationWithBundleID:(id)arg1;
@end

@interface LSApplicationProxy : NSObject
+ (LSApplicationProxy *)applicationProxyForIdentifier:(id)appIdentifier;
@property(readonly) NSString * applicationIdentifier;
@property(readonly) NSString * bundleVersion;
@property(readonly) NSString * bundleExecutable;
@property(readonly) NSArray * deviceFamily;
@property(readonly) NSURL * bundleContainerURL;
@property(readonly) NSString * bundleIdentifier;
@property(readonly) NSURL * bundleURL;
@property(readonly) NSURL * containerURL;
@property(readonly) NSURL * dataContainerURL;
@property(readonly) NSString * localizedShortName;
@property(readonly) NSString * localizedName;
@property(readonly) NSString * shortVersionString;
@end

@interface _UIAlertControllerShimPresenter : NSObject
@property (assign,nonatomic) UIAlertController * alertController;
@property (assign,nonatomic) UIAlertView * legacyAlert;
@end

@interface SBBacklightController : NSObject
+(id)sharedInstance;
-(void)cancelLockScreenIdleTimer;
-(void)turnOnScreenFullyWithBacklightSource:(int)arg1 ;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(BOOL)attemptUnlockWithPasscode:(id)arg1;
@end

#endif /* SpringBoardHeader_h */
