#import "AbstractGame.h"
#import <AVFoundation/AVFoundation.h>

@interface PowerGame : AbstractGame
-(void)distributePower:(float)velocity;
@property int power;
@property BOOL allowPowerUpdate;
@property BOOL readyForSave;
@end
