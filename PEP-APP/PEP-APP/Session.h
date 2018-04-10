//
//  Session.h
//  FairHammer
//
//  Created by barry on 11/07/2013.
//  Copyright (c) 2013 barry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject<NSCoding>
@property(nonatomic,strong)NSNumber  *sessionStrength;
@property(nonatomic,strong)NSNumber  *sessionDuration;
@property(nonatomic,strong)NSNumber  *sessionSpeed;
@property(nonatomic,strong)NSNumber  *sessionType;

@property(nonatomic,strong)NSDate    *sessionDate;
@property(nonatomic,strong)NSString  *username;
-(void)updateStrength:(float)pvalue;
@end
