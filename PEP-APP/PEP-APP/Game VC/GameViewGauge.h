#import <UIKit/UIKit.h>
#define MAINGAUGE_WIDTH  310
#define MAINGUAGE_HEIGHT 330
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]

@protocol MainGaugeProtocol <NSObject>
-(void)maxDistanceReached;
@end

@interface GameViewGauge : UIView
@property(nonatomic,unsafe_unretained)id<MainGaugeProtocol>MainGaugeDelegate;
@property BOOL animationRunning;

-(void)start;
-(void)stop;
-(void)stopGauge;
-(void)setForce:(float)pforce;
-(void)blowingBegan;
-(void)blowingEnded;
-(void)setArrowPos:(float)pforce;
-(void)setMass:(float)value;
-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;
-(void)setBestDistanceWithY:(float)yValue;
@end
