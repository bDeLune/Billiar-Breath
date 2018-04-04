//
//  PowerGame.h
//  BilliardBreath
//
//  Created by barry on 10/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "AbstractGame.h"
#import <AVFoundation/AVFoundation.h>

@interface PowerGame : AbstractGame
-(void)distributePower:(float)velocity;
@property int power;
@property BOOL allowPowerUpdate;
@property BOOL readyForSave;
@end
