//
//  BilliardBall.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BilliardBall;
@protocol BilliardBallProtocol <NSObject>

-(void)ballReachedFinalTarget:(BilliardBall*)ball;

@end
@interface BilliardBall : UIView <NSObject, CAAnimationDelegate>//ADDED
@property (nonatomic,strong)NSNumber  *weight;
@property(nonatomic,strong)UIDynamicAnimator *animator;
@property(nonatomic,strong)CAAnimation *animation;
@property(nonatomic)CGPoint  targetPoint;
@property(nonatomic,unsafe_unretained)id<BilliardBallProtocol>delegate;

@property BOOL animationRunning;
@property(nonatomic,weak)UIImageView  *arrow;
@property int gaugeHeight;
-(void)start;
-(void)stop;
-(void)setForce:(float)pforce;
-(void)setMass:(float)value;
-(void)blowingBegan;
-(void)blowingEnded;

@end
