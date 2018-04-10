//
//  Game.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
// inhale == 0
//exhale ==1
typedef enum
{
    gameTestTypeFlatInhale,
    gameTestTypeFlatExhale,
    gameTestTypeHillInhale,
    gameTestTypeHillExhale,
    gameTestTypeMountainInhale,
    gameTestTypeMountainExhale
}kGameTestType;

@class User;

@interface Game : NSManagedObject

@property (nonatomic, retain) NSNumber * gameType;//difficulty
@property (nonatomic, retain) NSDate * gameDate;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * bestDuration;
@property(nonatomic,retain)NSString *durationString;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * bestStrength;
@property (nonatomic, retain) NSString * gameDirection;


@property(nonatomic,retain)NSNumber  *gameAngle;
@property(nonatomic,retain)NSNumber  *gameWind;
@property(nonatomic,retain)NSNumber  *gameDistance;

@property (nonatomic, retain) NSNumber * gameHillType;
@property (nonatomic, retain) NSNumber * gameAbilityType;
@property(nonatomic,retain)NSNumber *gameTestType;
@property(nonatomic,retain)NSNumber  *gameDirectionInt;
@property(nonatomic,retain)NSString  *gamePointString;

@property (nonatomic, retain) User *user;

@end
