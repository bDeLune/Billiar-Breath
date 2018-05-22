#import <UIKit/UIKit.h>
#import "BilliardBall.h"
#import "Balloon.h"
//#import "PowerGame.h"
//#import "DurationGame.h"
#import "AbstractGame.h"    //change: 
#import "Game.h"
#import "GPUImage.h"

@interface BilliardBallViewController : UIViewController<BilliardBallProtocol, BalloonProtocol>
-(id)initWithFrame:(CGRect)frame;
-(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount;
-(void)reset;
-(void)resetwithBallCount:(int)ballCount;
-(void)shootBallToTop:(int)ballIndex withAcceleration:(float)acceleration;
-(void)pushBallsWithVelocity:(float)velocity;
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
