//
//  LotoDeviceManager.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#import "ImportHeader.h"

@interface LotoDeviceManager : NSObject

+ (LotoDeviceManager *)sharedInstance;
- (NSString *)currentuserobject:(NSString *)key;

@end
