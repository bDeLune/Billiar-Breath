//
//  DurationGame.h
//  BilliardBreath
//
//  Created by barry on 11/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

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
