//
//  AppleAccountModel.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppleAccountModel : NSObject
@property (nonatomic, strong) NSString *lotoid;
@property (nonatomic, strong) NSArray *appids;
@property (nonatomic, strong) NSString *serial;
@property (nonatomic, strong) NSString *ECID;
@property (nonatomic, strong) NSString *IMEI;
@property (nonatomic, strong) NSString *wifiMac;
@property (nonatomic, strong) NSString *bluetoothMac;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *appleid;
@property (nonatomic, strong) NSString *applepwd;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) long long holdingtime;
@property (nonatomic, strong) NSString *devicename;
@property (nonatomic, strong) NSArray *ratedAppids;
@property (nonatomic, strong) NSArray *ratingAppids;

+ (AppleAccountModel *)itemWithDictionary:(NSDictionary *)dic;
- (id)toDictionary;
@end
