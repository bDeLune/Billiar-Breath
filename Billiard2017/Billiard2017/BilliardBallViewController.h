//
//  BilliardBallViewController.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BilliardBall.h"
#import "PowerGame.h"
#import "DurationGame.h"
#import "Game.h"

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
@property(nonatomic,weak)PowerGame  *powerGame;
@property(nonatomic,weak)DurationGame  *durationGame;
@property gameType  currentGameType;


@end
