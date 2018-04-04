#import <UIKit/UIKit.h>
#define GAUGE_WIDTH  100
#import "Draggable.h"
#define GUAGE_HEIGHT 575
@protocol GaugeProtocol <NSObject>
-(void)maxDistanceReached;

@end

@interface Gauge : UIView

@property(nonatomic,unsafe_unretained)id<GaugeProtocol>gaugedelegate;
@property BOOL animationRunning;
@property(nonatomic,weak)Draggable  *arrow;

-(void)start;
-(void)stop;
-(void)setForce:(float)pforce;
-(void)blowingBegan;
-(void)blowingEnded;
-(void)setArrowPos:(float)pforce;
-(void)setMass:(float)value;
-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;
-(void)setBestDistanceWithY:(float)yValue;
@end
