#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@interface Game : NSManagedObject

@property (nonatomic, retain) NSNumber * gameType;
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
@property (nonatomic, retain) User *user;
@end
