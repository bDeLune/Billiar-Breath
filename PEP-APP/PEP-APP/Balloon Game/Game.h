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
@property (nonatomic, retain) NSString * durationString;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * bestStrength;
@property (nonatomic, retain) NSString * gameDirection;
@property (nonatomic, retain) NSNumber * requiredBalloons;
@property (nonatomic, retain) NSNumber * achievedBalloons;
@property (nonatomic, retain) NSNumber * achievedBreathLength;
@property (nonatomic, retain) NSNumber * requiredBreathLength;

//@property (nonatomic, retain) NSNumber* gameRequiredBalloons;
//@property (nonatomic, retain) NSNumber* gameAchievedBalloons;
//@property (nonatomic, retain) NSNumber* gameRequiredBreathLength;
//@property (nonatomic, retain) NSNumber* gameAchievedBreathLength;

///-(void) setGameRequiredBalloons:(NSNumber*)val;
//-(void) setGameAchievedBalloons:(NSNumber*)val;
//-(void) setGameRequiredBreathLength:(NSNumber*)val;
//-(void) setGameAchievedBreathLength:(NSNumber*)val;

//-(void) setCurrentGameRequiredBalloons:(NSNumber*)val;
//-(void) setCurrentGameAchievedBalloons:(NSNumber*)val;
//-(void) setCurrentGameRequiredBreathLength:(NSNumber*)val;
//-(void) setCurrentGameAchievedBreathLength:(NSNumber*)val;

//@property(nonatomic,retain)NSNumber *gameTestType;
@property(nonatomic,retain)NSString *gamePointString;
@property (nonatomic, retain) User *user;
@end
