#import "Game.h"
#import "User.h"

@implementation Game
@dynamic gameType;
@dynamic gameDate;
@dynamic duration;
@dynamic power;
@dynamic bestStrength;
@dynamic bestDuration;
@dynamic user;
@dynamic gameDirection;
@dynamic durationString;
@dynamic gamePointString;

@dynamic requiredBalloons;
@dynamic achievedBalloons;
@dynamic achievedBreathLength;
@dynamic requiredBreathLength;

//@dynamic gameRequiredBalloons;
//@dynamic gameAchievedBalloons;
//@dynamic gameRequiredBreathLength;
//@dynamic gameAchievedBreathLength;
//change - enable dynamic getters and setters

//@synthesize gameRequiredBalloons;
//@synthesize gameAchievedBalloons;
//@synthesize gameRequiredBreathLength;
//@synthesize gameAchievedBreathLength;
/*
-(void) setGameRequiredBalloons: (NSNumber*)val{
    NSLog(@"Setting required balloons %@", val);
    self.gameRequiredBalloons = val;
}

-(void) setGameAchievedBalloons:(NSNumber*)val{
    NSLog(@"Setting achieved balloons %@", val);
    self.gameAchievedBalloons = val;
}

-(void) setGameRequiredBreathLength:(NSNumber*)val{
    NSLog(@"Setting required breath %@", val);
    self.gameRequiredBreathLength = val;
}

-(void) setGameAchievedBreathLength:(NSNumber*)val{
    NSLog(@"Setting achieved breath %@", val);
    self.gameAchievedBreathLength = val;
}

-(void) setCurrentGameRequiredBalloons: (NSNumber*)val{
    NSLog(@"Setting required balloons %@", val);
    self.gameRequiredBalloons = val;
}

-(void) setCurrentGameAchievedBalloons:(NSNumber*)val{
    NSLog(@"Setting achieved balloons %@", val);
    self.gameAchievedBalloons = val;
}

-(void) setCurrentGameRequiredBreathLength:(NSNumber*)val{
    NSLog(@"Setting required breath %@", val);
    self.gameRequiredBreathLength = val;
}

-(void) setCurrentGameAchievedBreathLength:(NSNumber*)val{
    NSLog(@"Setting achieved breath %@", val);
    self.gameAchievedBreathLength = val;
}*/

//@property (nonatomic, retain) NSNumber * gameAchievedBalloons;
//@property (nonatomic, retain) NSNumber * gameRequiredBreathLength;
//@property (nonatomic, retain) NSNumber * gameAchievedBreathLength;
@end
