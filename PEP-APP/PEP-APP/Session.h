#import <Foundation/Foundation.h>

@interface Session : NSObject<NSCoding>
@property(nonatomic,strong)NSNumber  *sessionStrength;
@property(nonatomic,strong)NSNumber  *sessionDuration;
@property(nonatomic,strong)NSNumber  *sessionSpeed;
@property(nonatomic,strong)NSNumber  *sessionType;
@property(nonatomic,strong)NSNumber  *sessionRequiredBalloons;
@property(nonatomic,strong)NSNumber  *sessionAchievedBalloons;
@property(nonatomic,strong)NSNumber  *sessionRequiredBreathLength;
@property(nonatomic,strong)NSNumber  *sessionAchievedBreathLength;
@property(nonatomic,strong)NSNumber  *sessionBreathDirection;
@property(nonatomic,strong)NSNumber  *sessionAppMode;
@property(nonatomic,strong)NSDate    *sessionDate;
@property(nonatomic,strong)NSString  *username;
-(void)updateStrength:(float)pvalue;
@end
