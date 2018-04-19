//
//  SequenceGame.h
//  BilliardBreath
//
//  Created by barry on 10/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "AbstractGame.h"

@interface SequenceGame : AbstractGame

@property BOOL allowNextBall;
@property int totalBallsRaised;
@property int totalBallsAttempted;
@property int currentSpeed;
@property BOOL  halt;

-(void)playHitTop;
-(void)setAudioMute: (BOOL) muteSetting;
@end
