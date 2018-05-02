//
//  RankAppModel.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "RankAppModel.h"

@implementation RankAppModel

+ (RankAppModel *)itemWithDictionary:(NSDictionary *)dic
{
    RankAppModel *rank = [[RankAppModel alloc] init];
    rank.taskID = [dic objectForKey:@"_id"];
    rank.searchTerms = [dic objectForKey:@"searchterms"];
    // rank.currentSearchTerms = [dic objectForKey:@"currentSearchTerms"];
    id appid = [dic objectForKey:@"appid"];
    if ([appid isKindOfClass:[NSNumber class]])
        rank.searchAppID = [NSString stringWithFormat:@"%@",appid];
    else
        rank.searchAppID = appid;
    rank.bundldID = [dic objectForKey:@"bundleid"];
    rank.allowCloudDownload = [[dic objectForKey:@"allowcloud"] boolValue];
    rank.moreKeywords = [dic objectForKey:@"morekeywords"];
    rank.shouldOpen = [[dic objectForKey:@"open"] boolValue];
    rank.workType = [[dic objectForKey:@"type"] integerValue];
    return rank;
}
- (id)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.taskID){
        [dict setObject:self.taskID forKey:@"_id"];
    }
    if (self.searchTerms) {
        [dict setObject:self.searchTerms forKey:@"searchterms"];
    }
    if (self.searchAppID) {
        [dict setObject:self.searchAppID forKey:@"appid"];
    }
    if (self.bundldID){
        [dict setObject:self.bundldID forKey:@"bundleid"];
    }
    if (self.moreKeywords) {
        [dict setObject:self.moreKeywords forKey:@"morekeywords"];
    }
    // if (self.currentSearchTerms){
    //     [dict setObject:self.currentSearchTerms forKey:@"currentSearchTerms"];
    // }
    [dict setObject:@(self.allowCloudDownload) forKey:@"allowcloud"];
    [dict setObject:@(self.shouldOpen) forKey:@"open"];
    [dict setObject:@(self.workType) forKey:@"type"];
    return dict;
}

@end
