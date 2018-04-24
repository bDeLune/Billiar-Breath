#import "BilliardBall.h"
#import "GCDQueue.h"

@interface BilliardBall()
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
    float currentYPosition;
    BOOL  isstopping;
}

@end

@implementation BilliardBall

-(void)setMass:(float)value
{
    mass=value;
}

-(void)setDefaults
{
    velocity=0.0;
    distance=0.1;
    time=0.1;
    acceleration=0.1;
    isaccelerating=NO;
    mass=1;
    force=15;
    [self addObserver:self forKeyPath:@"currentYPosition" options:0 context:NULL];
}
#pragma mark -
#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"currentYPosition"]) {
        
        if (currentYPosition<=self.bounds.size.width/2) {
            
            [self.delegate ballReachedFinalTarget:self];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)setForce:(float)pforce
{
    force=(pforce/mass);
}

-(void)blowingBegan
{
    isstopping=NO;
    isaccelerating=YES;
}

-(void)blowingEnded
{
    isaccelerating=NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        [self setDefaults];
        currentYPosition=frame.origin.y;
        UIImageView  *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Ball"]];
        [self addSubview:img];
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self setCenter:self.targetPoint];
}

-(void)animationDidStart:(CAAnimation *)ani
{
    self.alpha=1.0;
}

-(void)stop
{
    CGRect frame=self.frame;
    frame.origin.y=0;
    self.frame=frame;
    [self setNeedsDisplay];
   /// [[GCDQueue mainQueue]queueBlock:^{
        if (_animationRunning) {
            [displayLink invalidate];
            _animationRunning=NO;
        //added
        [[GCDQueue mainQueue]queueBlock:^{
                [self.delegate ballReachedFinalTarget:self];
            } afterDelay:0.1];
        }
  ///  NSLog(@"Stopped!!");
   /// }];
}

-(void)start
{
    // [self stop];
    //ADDED
    [self setDefaults];
    if (!_animationRunning)
    {
        displayLink = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(animateForPower)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _animationRunning = YES;
    }
}

-(void)animateForPower
{
    // [self setForce:_midiSource.velocity*100];
    ///NSLog(@"FORCE %f", force);

    if (isaccelerating) {
        // force+=500;
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
    CGRect frame=self.frame;

    
    if (frame.origin.y>self.bounds.size.height/2) {
        frame.origin.y=(self.gaugeHeight-self.bounds.size.height) -distance;
        
        [self setFrame:frame];
    }else
    {
       // distance=GUAGE_HEIGHT;
        NSLog(@"POWER %f", force);
        frame.origin.y=0;
        self.frame=frame;
        [self setNeedsDisplay];
        if (isstopping) {
          //  return;
        }
        
      /// [[GCDQueue mainQueue]queueBlock:^{
            [self stop];
      ///  } afterDelay:0.01];
        //isstopping=YES;
    }
    //[self setNeedsDisplay];
    //1/2*a*t2
}
@end
