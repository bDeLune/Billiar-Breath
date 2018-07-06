#import "GameViewGauge.h"
#import <QuartzCore/QuartzCore.h>

@interface GameViewGauge ()
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
@implementation GameViewGauge

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
            // Initialization code
            [self setDefaults];
            displayLink = [CADisplayLink displayLinkWithTarget:self
                                                      selector:@selector(animate)];
            
            start=[NSDate date];
            animationObject=[[UIView alloc]initWithFrame:self.bounds];
            
            UIColor* customColour = RGB(00, 33, 66);
            [animationObject setBackgroundColor:customColour];
            animationObject.layer.cornerRadius=16;
            animationObject.alpha = 0.01;
            [self addSubview:animationObject];
            
            isaccelerating=false;
            self.backgroundColor=[UIColor clearColor];
            self.layer.cornerRadius=16;
            
            mass=1;
            force=15;
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
   // NSLog(@"TS - currentlyExhaling %d", currentlyExhaling);
  //  NSLog(@"TS - setToInhale %d", setToInhale);
    
    if ((currentlyExhaling == 1 && setToInhale == 0) || (currentlyExhaling == 0 && setToInhale == 1)){
  //      NSLog(@"CORRECT");
        userBreathingCorrectly = true;
        //   isaccelerating=YES;
    }else{
        userBreathingCorrectly = false;
        isaccelerating=NO;
    }
}

-(void)setForce:(float)pforce
{
  //  NSLog(@"distancE %f - MAINGUAGE_HEIGHT %d", distance, MAINGUAGE_HEIGHT);
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
        // force+=500;
    }else
    {
        force-=force*0.09;
        acceleration-=acceleration*0.09;
    }
    
    if (force<1) {
        force=1;
    }
    
    acceleration= acceleration +( force/mass);
    velocity = distance / time;
    time = distance / velocity;
    distance= ceilf((0.5)* (acceleration * powf(time, 2)));
    
    if (distance > MAINGUAGE_HEIGHT){
        distance = MAINGUAGE_HEIGHT;
    }
    
    if (distance<MAINGUAGE_HEIGHT) {
        CGRect frame=animationObject.frame;
        frame.origin.x=0;
        frame.size.height=90;
        frame.size.width=distance;
        
        if (distance>bestDistance) {
            bestDistance=distance;
        }
        
        //NSLog(@"DISTANCE LESS THAN");
        //NSLog(@"distance %f", distance );
        [animationObject setFrame:frame];
    }else
    {
        NSLog(@"DISTANCE ELSE");
        distance = MAINGUAGE_HEIGHT - 30;
    }
    [self setNeedsDisplay];
}

//-(void)setArrowPos:(float)pforce
//{
//    force=(pforce/mass);
//    NSLog(@"SETTING PFORCE %f", pforce);
///    CGRect frame=animationObject.frame;
//    frame.origin.y=self.bounds.size.height-distance;
//}

-(void)stop
{
    //change: stop animation when in other view
   NSLog(@"MAIN GAUGE STOP");
    if (_animationRunning) {
        [displayLink invalidate];
       _animationRunning=NO;
    }
}

-(void)start
{
    NSLog(@"STARTING ANIMATION");
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
