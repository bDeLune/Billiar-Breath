#import <UIKit/UIKit.h>
#import "Balloon.h"
#import "AbstractGame.h"
#import "Game.h"
#import "GPUImage.h"

@interface BilliardBallViewController : UIViewController<BalloonProtocol>
-(id)initWithFrame:(CGRect)frame;
-(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount;
-(void)reset;
-(void)resetwithBallCount:(int)ballCount;
-(void)shootBallToTop:(int)ballIndex withAcceleration:(float)acceleration;
-(void)pushBallsWithVelocity:(float)velocity;
-(void)blowStarted: (int)currentBallNo atSpeed:(int)speed;
-(void)blowEnded;
-(void)timerFired:(NSTimer *)timer;
- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight;
//-(void)startBallsPowerGame;
//-(void)endBallsPowerGame;
//-(void)startDurationPowerGame;
//-(void)endDurationPowerGame;
//-(void)setAudioMute:(BOOL) muteSettings;
//@property(nonatomic,weak)PowerGame  *powerGame;
//@property(nonatomic,weak)DurationGame  *durationGame;
@property gameType  currentGameType;
@end
