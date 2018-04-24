#import <UIKit/UIKit.h>
#import "BilliardBall.h"
#import "PowerGame.h"
#import "DurationGame.h"
#import "Game.h"
#import "GPUImage.h"

@interface BilliardBallViewController : UIViewController<BilliardBallProtocol>
-(id)initWithFrame:(CGRect)frame;
-(void)reset;
-(void)shootBallToTop:(int)ballIndex withAcceleration:(float)acceleration;
-(void)pushBallsWithVelocity:(float)velocity;
- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight;
-(void)startBallsPowerGame;
-(void)endBallsPowerGame;
-(void)startDurationPowerGame;
-(void)endDurationPowerGame;
-(void)setAudioMute:(BOOL) muteSettings;
@property(nonatomic,weak)PowerGame  *powerGame;
@property(nonatomic,weak)DurationGame  *durationGame;
@property gameType  currentGameType;
@end
