//
//  AppleAccountModel.m
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "AppleAccountModel.h"

@implementation AppleAccountModel
+ (AppleAccountModel *)itemWithDictionary:(NSDictionary *)dic
{
    AppleAccountModel *account = [[AppleAccountModel alloc] init];
    account.serial = [dic objectForKey:@"sn"];
    account.ECID = [dic objectForKey:@"ecid"];
    account.IMEI = [dic objectForKey:@"imei"];
    account.wifiMac = [dic objectForKey:@"wifiMac"];
    account.bluetoothMac = [dic objectForKey:@"bluetoothMac"];
    account.uuid = [dic objectForKey:@"uuid"];
    account.appleid = [dic objectForKey:@"appleid"];
    account.applepwd = [dic objectForKey:@"applepwd"];
    account.lotoid = [dic objectForKey:@"_id"];
    account.appids = [dic objectForKey:@"appids"];
    account.status = [[dic objectForKey:@"status"] integerValue];
    account.holdingtime = [[dic objectForKey:@"holdingtime"] longLongValue];
    account.devicename = [dic objectForKey:@"deviceName"];
    account.ratedAppids = [dic objectForKey:@"rateAppids"];
    account.ratingAppids = [dic objectForKey:@"ratingAppids"];
    return account;
}

- (id)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.serial) {
        [dict setObject:self.serial forKey:@"sn"];
    }
    if (self.ECID) {
        [dict setObject:self.ECID forKey:@"ecid"];
    }
    if (self.IMEI){
        [dict setObject:self.IMEI forKey:@"imei"];
    }
    if (self.wifiMac) {
        [dict setObject:self.wifiMac forKey:@"wifiMac"];
    }
    if (self.bluetoothMac) {
        [dict setObject:self.bluetoothMac forKey:@"bluetoothMac"];
    }
    if (self.uuid) {
        [dict setObject:self.uuid forKey:@"uuid"];
    }
    if (self.appleid) {
        [dict setObject:self.appleid forKey:@"appleid"];
    }
    if (self.applepwd) {
        [dict setObject:self.applepwd forKey:@"applepwd"];
    }
    if (self.appids){
        [dict setObject:self.appids forKey:@"appids"];
    }
    if (self.ratedAppids){
        [dict setObject:self.ratedAppids forKey:@"rateAppids"];
    }
    if (self.ratingAppids){
        [dict setObject:self.ratingAppids forKey:@"ratingAppids"];
    }
    if (self.lotoid){
        [dict setObject:self.lotoid forKey:@"_id"];
    }
    return dict;
}
@end
