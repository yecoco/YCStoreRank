//
//  RateModel.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/27.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateModel : NSObject
@property (nonatomic, strong) NSString *rateID;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) float rating;

+ (RateModel *)itemWithDictionary:(NSDictionary *)dic;
- (id)toDictionary;
+ (RateModel *)testModel;
@end
