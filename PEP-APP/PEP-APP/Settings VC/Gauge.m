#import "Gauge.h"
#import <QuartzCore/QuartzCore.h>

@interface Gauge ()
{
    float velocity;
    float distance;
    float time;
    float acceleration;// force/ mass
    BOOL  isaccelerating;
    float force;
    float mass;
    CADisplayLink *displayLink;
    NSDate *start;
    UIView  *animationObject;
    float h;
    float hm;
    float last_hm;
    float anim;
    float anim_delay;
    float weight;
    float bestDistance;
    bool setToInhale;
    bool currentlyExhaling;
    bool userBreathingCorrectly;
}

@end

@implementation Gauge

-(void)setMass:(float)value
{
    mass=value;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
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
        /** if (!animationRunning)
         {
         [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
         animationRunning = YES;
         }**/
    }
    return self;
}



- (id)initWithFrame:(CGRect)frame withOrientation:(NSString*)orientation
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if ([orientation isEqual: @"Vertical"]){
            NSLog(@"Initialising Vertical frame");
            // Initialization code
            [self setDefaults];
            displayLink = [CADisplayLink displayLinkWithTarget:self
                                                      selector:@selector(animate)];
            
            start=[NSDate date];
            animationObject=[[UIView alloc]initWithFrame:self.bounds];
            
            UIColor* customColour = RGB(00, 33, 66);
            [animationObject setBackgroundColor:customColour];
            animationObject.layer.cornerRadius=16;
            //animationObject.alpha = 0.01;
            [self addSubview:animationObject];
            
            isaccelerating=false;
            self.backgroundColor=[UIColor clearColor];
            self.layer.cornerRadius=16;
            
            mass=1;
            force=15;
            /** if (!animationRunning)
             {
             [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
             animationRunning = YES;
             }**/
        }else if ([orientation isEqual: @"Horizontal"]){
            NSLog(@"Initialising Horizontal frame");
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
    // mass=1;
    //force=15;
    h=0;
    hm=0;
    anim_delay=0;
    bestDistance=0;
    isaccelerating=NO;
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
        force-=force*0.03;
        acceleration-=acceleration*0.03;
    }
    
    if (force<1) {
        force=1;
    }
    
    acceleration= acceleration +( force/mass);
    velocity = distance / time;
    time = distance / velocity;
    distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    
    if (distance<GUAGE_HEIGHT) {
        CGRect frame=animationObject.frame;
        frame.origin.y=self.bounds.size.height-distance;
        frame.size.height= 1 + distance;
        [animationObject setFrame:frame];
    }else
    {
        distance=GUAGE_HEIGHT-30;
        [self stop];  //change
        [self fallQuickly];
    }
    [self setNeedsDisplay];
}

-(void)setArrowPos:(float)pforce
{
    force=(pforce/mass);
}

-(void)stop
{
    //change: stop animation when in other view
    // NSLog(@"MAIN GAUGE STOP");
    // if (_animationRunning) {
    //     [displayLink invalidate];
    //     _animationRunning=NO;
    // }
}

-(void)stopGauge
{
    //change: stop animation when in other view
    //  NSLog(@"MAIN GAUGE STOP");
   // if (_animationRunning) {
   //     [displayLink invalidate];
   //     _animationRunning=NO;
  //  }
}


-(void)start
{
    //  [self stop];
    NSLog(@"STARTING MAIN GAUGE ANIMATION");
    
    [self setDefaults];
    if (!_animationRunning)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animate)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _animationRunning = YES;
    }
}

-(void)fallQuickly
{
    /// NSLog(@"FALLING QUICKLY!");
}
@end
