//
//  SBAutoManager.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//


#import "ImportHeader.h"

@interface SBAutoManager : NSObject
@property (nonatomic, strong) NSMutableArray *appLists;
@property (nonatomic, strong) RankAppModel *currentRankApp;
@property (nonatomic, assign) BOOL bUninstall;
@property (nonatomic, assign) BOOL bOpenedAppStore;
@property (nonatomic, strong) NSMutableArray *accountLists;
@property (nonatomic, assign) BOOL bShowAgree;
@property (nonatomic, assign) BOOL bAutoCheck;
@property (nonatomic, assign) BOOL bFirstOpen;
@property (nonatomic, assign) BOOL bAppStoreLive;
@property (nonatomic, assign) BOOL bDelayRate;

+ (SBAutoManager *)sharedInstance;
- (void)writeLog:(NSString *)logString;
- (void)checkAppStoreStatues;
- (void)lotoUninstallApplication;
- (void)uninstallApp:(NSString *)bundleID;
- (void)openDownloadApplication;
- (void)openApplication;
- (void)checkAutoTxt;
- (void)doContinue:(NSArray *)objectArray;
- (void)alertdo:(NSArray *)alertObject;
- (void)delayDoNext;
- (void)randomVerifySerialNumber;

@end


