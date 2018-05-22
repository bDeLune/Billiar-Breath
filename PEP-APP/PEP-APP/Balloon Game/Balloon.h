//
//  Balloon.h
//  GPUImage
//
//  Created by Brian Dillon on 22/05/2018.

#import <UIKit/UIKit.h>

@class Balloon;
@protocol BalloonProtocol <NSObject>
-(void)balloonReachedFinalTarget:(Balloon*)ball;
//-(void)setAudioMute:(BOOL) muteSettings;
@end
@interface Balloon : UIView <NSObject, CAAnimationDelegate>//ADDED
@property (nonatomic,strong)NSNumber  *weight;
@property(nonatomic,strong)UIDynamicAnimator *animator;
@property(nonatomic,strong)CAAnimation *animation;
@property(nonatomic)CGPoint  targetPoint;
@property(nonatomic,unsafe_unretained)id<BalloonProtocol>delegate;
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
