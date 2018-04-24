#import "AbstractGame.h"
#import <AVFoundation/AVFoundation.h>

@interface DurationGame : AbstractGame
@property  float secondsPerballEasy;
@property  float secondsPerballMedium;
@property  float secondsPerballHard;
@property BOOL isRunning;
@property(nonatomic,strong)NSMutableArray  *ballsCopy;
-(void)pushBall;
@end
