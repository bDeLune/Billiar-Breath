#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//typedef enum
//{
 //   gameTestTypeFlatInhale,
 ///   gameTestTypeFlatExhale,
//    gameTestTypeHillInhale,
 ///   gameTestTypeHillExhale,
 //   gameTestTypeMountainInhale,
//    gameTestTypeMountainExhale
//}kGameTestType;

@class User;
@interface Game : NSManagedObject

@property (nonatomic, retain) NSNumber * gameType;//difficulty
@property (nonatomic, retain) NSDate   * gameDate;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * bestDuration;
@property (nonatomic,retain)  NSString * durationString;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * bestStrength;
@property (nonatomic, retain) NSString * gameDirection;

@property (nonatomic, retain) NSNumber * gameRequiredBalloons;
@property (nonatomic,retain)  NSNumber * gameAchievedBalloons;
@property (nonatomic, retain) NSNumber * gameRequiredBreathLength;
@property (nonatomic, retain) NSNumber * gameAchievedBreathLength;

@property(nonatomic,retain)NSNumber *gameTestType;
@property(nonatomic,retain)NSString  *gamePointString;
@property (nonatomic, retain) User *user;
@end
