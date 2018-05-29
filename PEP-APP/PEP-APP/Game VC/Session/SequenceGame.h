#import "AbstractGame.h"

@interface SequenceGame : AbstractGame
@property BOOL allowNextBall;
@property int totalBallsRaised;
@property int totalBallsAttempted;
@property int currentSpeed;
@property BOOL  halt;
-(void)playHitTop;
-(id)initWithBallCount: (int)ballCount;
-(void)setAudioMute: (BOOL) muteSetting;
@end
