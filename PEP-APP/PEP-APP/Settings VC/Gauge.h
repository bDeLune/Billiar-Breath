#import <UIKit/UIKit.h>
#define GAUGE_WIDTH  330
#import "Draggable.h"
#define GUAGE_HEIGHT 730
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]
//change should be background colour

@protocol GaugeProtocol <NSObject>
-(void)maxDistanceReached;
@end

@interface Gauge : UIView
@property(nonatomic,unsafe_unretained)id<GaugeProtocol>GaugeDelegate;
@property BOOL animationRunning;
@property(nonatomic,weak)Draggable  *arrow;

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
