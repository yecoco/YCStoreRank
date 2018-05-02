//
//  RankAppModel.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RankAppModel : NSObject

@property (nonatomic, strong) NSString *taskID;
@property (nonatomic, strong) NSString *searchAppID;
@property (nonatomic, strong) NSString *bundldID;
@property (nonatomic, assign) BOOL allowCloudDownload;
@property (nonatomic, strong) NSString *searchTerms;
// @property (nonatomic, strong) NSArray *currentSearchTerms;
@property (nonatomic, strong) NSArray *moreKeywords;
@property (nonatomic, assign) BOOL shouldOpen;
@property (nonatomic, assign) NSInteger workType;

+ (RankAppModel *)itemWithDictionary:(NSDictionary *)dic;
- (id)toDictionary;

@end
