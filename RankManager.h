//
//  RankManager.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "ImportHeader.h"

@interface RankManager : NSObject
+ (RankManager *)sharedInstance;
@property (nonatomic, strong) UITabBarController *tabBarVc;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UINavigationController *naviVC;
@property (nonatomic, strong) NSMutableArray *appLists;
@property (nonatomic, strong) RankAppModel *currentapp;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIButton *appleIDButton;
@property (nonatomic, assign) NSInteger signcount;
@property (nonatomic, assign) NSInteger signoutcount;
@property (nonatomic, strong) SKUIAccountButtonsViewController *accountVC;
@property (nonatomic, assign) NSInteger progresscount;
@property (nonatomic, assign) BOOL bSkip;
// @property (nonatomic, strong) NSString *currentSearchText;
@property (nonatomic, assign) BOOL bHaveCloud;
@property (nonatomic, assign) BOOL bDoAppInfoDownload;
@property (nonatomic, assign) BOOL bLoadFeaturePage;
@property (nonatomic, assign) NSInteger keywodIndex;
@property (nonatomic, strong) SKUIStorePageSectionsViewController *currentVC;
@property (nonatomic, assign) BOOL bInAppInfoPage;
@property (nonatomic, assign) NSInteger searchResults;
@property (nonatomic, assign) NSInteger commonResultsCount;
@property (nonatomic, assign) BOOL bCheckSignin;
@property (nonatomic, assign) BOOL bCheckSignout;
@property (nonatomic, assign) BOOL bCheckProgress;
@property (nonatomic, strong) AppleAccountModel *currentAccount;
@property (nonatomic, assign) BOOL bDownloadSuccess;
@property (nonatomic, assign) NSInteger searchLoadCount;
@property (nonatomic, strong) RateModel *currentRate;
@property (nonatomic, assign) BOOL haveSearchCellBtn;
@property (nonatomic, assign) BOOL bSelectedReview;
@property (nonatomic, assign) BOOL bInDownloading;
@property (nonatomic, strong) NSArray *disableAccounts;
// @property (nonatomic, strong) SKUISearchFieldController *searchVC;
// @property (nonatomic, assign) BOOL bSendRequest;

- (NSString *)queryDictionaryToString:(NSDictionary *)dic;
- (void)getUserFromServer:(BOOL)bHaveDeviceName complete:(void (^)(id responseObject, NSError *error))complete;
- (void)changeUserInfo:(NSDictionary *)para bSuccess:(BOOL)bsuccess complete:(void (^)(id responseObject, NSError *error))complete;
- (void)writeErrorAccout:(NSString *)alerttitle;
- (void)writeLog:(NSString *)logString;
- (void)flagErrorAccount:(NSInteger)status complete:(void (^)())complete;
- (void)checksigninstatues;
- (void)checksignoutstatues;
- (void)completesignout;
- (void)removeAppStoreFile;
- (void)checkProgressStatues;
- (void)setupProgressTimer;
- (id)getchildViewController;
- (BOOL)bSearchDidLoaded:(id)childVC;
- (UICollectionViewCell *)getAppInfoPageDownloadCell;
- (UIView *)getOfferViewFromCell:(UICollectionViewCell *)cell;
- (SKUIItemOfferButton *)getOfferButtonFromOfferView:(UIView *)offerview;
- (BOOL)checkIsOpen;
- (BOOL)checkIsCloud;
- (void)doAppInfoPageDownload;
- (void)doReview;
- (void)doTouchWriteReview;
- (void)doDownload;
- (NSString *)newNickName;
- (NSString *)getNickName;
- (void)allowCloudDownloadDo:(SKUIItemOfferButton *)skbtn withOfferView:(UIView *)offerview;
- (void)checkIsCloudToDownload:(SKUIItemOfferButton *)skbtn withOfferView:(UIView *)offerview;
- (NSArray *)getViewElements:(SKUIStorePageSectionsViewController *)skpagesectionVC;
- (void)searchListDoTotalApp;
- (void)doSearchCell:(SKUIStorePageSectionsViewController *)skpagesectionVC;
- (void)doScrollBottom:(SKUIStorePageSectionsViewController *)skpagesectionVC;
- (void)reloadSearchData:(SKUIStorePageSectionsViewController *)skpagesectionVC;
- (void)doGetError;
- (void)completeDownload;
- (void)completeReview;
- (void)begainSearch;

@end
