//
//  RateModel.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/27.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "RateModel.h"

@implementation RateModel
+ (RateModel *)itemWithDictionary:(NSDictionary *)dic
{
    RateModel *item = [[RateModel alloc] init];
    item.nickname = [dic objectForKey:@"nickname"];

    NSString *title = [dic objectForKey:@"title"];
    if (title.length >= 100)
        item.title = [title substringToIndex:99];
    else
        item.title = title;

    item.rateID = [dic objectForKey:@"_id"];
    
    NSString *body = [dic objectForKey:@"content"];
    if (body.length >= 600)
        item.body = [body substringToIndex:599];
    else
        item.body = body;
    
    float rating = [[dic objectForKey:@"star"] floatValue] - 1;
    if (rating > 4 || rating < 0)
        rating = 4;
    else
        item.rating = rating;
    return item;
}

+ (RateModel *)testModel
{
    RateModel *item = [[RateModel alloc] init];
    item.nickname = @"stormyoverholttt";
    item.title = @"nice app";
    item.body = @"great app i love it";
    item.rating = 4;
    return item;
}

- (id)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.nickname) {
        [dict setObject:self.nickname forKey:@"nickname"];
    }
    if (self.title) {
        [dict setObject:self.title forKey:@"title"];
    }
    if (self.body){
        [dict setObject:self.body forKey:@"content"];
    }
    if (self.rateID){
        [dict setObject:self.rateID forKey:@"_id"];
    }
    [dict setObject:[NSNumber numberWithFloat:(self.rating + 1)] forKey:@"star"];
    return dict;

}
@end
