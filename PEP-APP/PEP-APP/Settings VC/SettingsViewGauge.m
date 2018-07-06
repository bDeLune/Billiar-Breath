#import "SettingsViewGauge.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewGauge ()
{
    float velocity;
    float distance;
    float time;
    float acceleration;
    BOOL  isaccelerating;
    float force;
    float mass;
    CADisplayLink *displayLink;
    NSDate *start;
    UIView  *animationObject;
    float h;
    float hm;
    float anim;
    float anim_delay;
    float bestDistance;
    bool setToInhale;
    bool currentlyExhaling;
    bool userBreathingCorrectly;
}

@end

@implementation SettingsViewGauge

-(void)setMass:(float)value
{
    mass=value;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animate)];
        start=[NSDate date];
        animationObject=[[UIView alloc]initWithFrame:self.bounds];
        
        UIColor* customColour = RGB(00, 33, 66);
        [animationObject setBackgroundColor:customColour];
        animationObject.layer.cornerRadius=16;
        [self addSubview:animationObject];
        [self sendSubviewToBack:animationObject];
        isaccelerating=false;
        self.backgroundColor=[UIColor clearColor];
        self.layer.cornerRadius=16;
        mass=1;
        force=15;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withOrientation:(NSString*)orientation
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if ([orientation isEqual: @"Vertical"]){
            NSLog(@"Initialising Vertical frame");
            [self setDefaults];
            displayLink = [CADisplayLink displayLinkWithTarget:self
                                                      selector:@selector(animate)];
            
            start=[NSDate date];
            animationObject=[[UIView alloc]initWithFrame:self.bounds];
            
            UIColor* customColour = RGB(00, 33, 66);
            [animationObject setBackgroundColor:customColour];
            animationObject.layer.cornerRadius=16;
            [self addSubview:animationObject];
            isaccelerating=false;
            self.backgroundColor=[UIColor clearColor];
            self.layer.cornerRadius=16;
            mass=1;
            force=15;
        }
    }
    return self;
}


-(void)setDefaults
{
    velocity=0.0;
    distance=0.1;
    time=0.1;
    acceleration=0.1;
    h=0;
    hm=0;
    anim_delay=0;
    bestDistance=0;
    isaccelerating=NO;
    
    distance=0.01; //0.01
    // distance=100;
    time=0.01;///0.2
    acceleration=0.01; //was 0.1
}



-(void)setBestDistanceWithY:(float)yValue
{
    bestDistance= yValue;
    NSLog(@"new dist == %f",bestDistance);
}

-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;{
    
    currentlyExhaling = value2;
    setToInhale = value;
    
    if ((currentlyExhaling == 1 && setToInhale == 0) || (currentlyExhaling == 0 && setToInhale == 1)){
        userBreathingCorrectly = true;
    }else{
        userBreathingCorrectly = false;
        isaccelerating=NO;
    }
}

-(void)setForce:(float)pforce
{
    force=(pforce/mass);
}

-(void)blowingBegan
{
    isaccelerating=YES;
    
}

-(void)blowingEnded
{
    isaccelerating=NO;
}

-(void)animate
{
    if (isaccelerating) {

    }else
    {
        force-=force*0.1;
        acceleration-=acceleration*0.1;
    }
    
    if (force<1) {
        force=1;
    }
    
    //acceleration= acceleration +( force/mass);
    //velocity = distance / time;
   // time = distance / velocity;
    //distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    
    //710 height
    acceleration= 8500 * ( force/mass);
    //acceleration= acceleration + ( force/mass);
    
    velocity = distance / time;
    time = distance / velocity;
    // distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    // distance = force/10;
    //distance = ceilf((.01)*force/10);
    //distance = ceilf((0.8)* (myForce * powf(time, 2)));
    distance = ceilf((0.3)* (acceleration * powf(time, 2)));
    
    //NSLog(@"GUAGE_HEIGHT %d", GUAGE_HEIGHT);
   // NSLog(@"distance %f", distance);
    
    if (distance<GUAGE_HEIGHT) {
        CGRect frame=animationObject.frame;
        frame.origin.y=self.bounds.size.height-distance;
        frame.size.height= 1 + distance;
        [animationObject setFrame:frame];
    }else
    {
        distance=GUAGE_HEIGHT-30;
    }
    [self setNeedsDisplay];
}

-(void)stop
{
     NSLog(@"MAIN GAUGE STOP");
     if (_animationRunning) {
         [displayLink invalidate];
         _animationRunning=NO;
     }
}

-(void)start
{
    [self setDefaults];
    if (!_animationRunning)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animate)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _animationRunning = YES;
    }
}
@end
