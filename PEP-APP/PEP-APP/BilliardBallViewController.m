//
//  BilliardBallViewController.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "BilliardBallViewController.h"
#import "BilliardBall.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "EasingDeclarations.h"
#import "easing.h"
#import "GCDQueue.h"

#define NUM_BALLS  8
#define BALL_RADIUS  80
@interface BilliardBallViewController ()<UICollisionBehaviorDelegate>
{
    CGPoint  topPoint;
    NSMutableArray *activeBallsForPower;
    
    int ballGameCount;
    AVAudioPlayer *audioPlayer;
    BOOL muteAudio;
    
}
@property(nonatomic,strong)    NSMutableArray  *balls;
@property(nonatomic,strong)NSMutableArray  *animators;
@property int currentBallININdex;
@end

@implementation BilliardBallViewController
//| ----------------------------------------------------------------------------
//  This method is called when square1 begins contacting a collision boundary.
//  In this demo, the only collision boundary is the bounds of the reference
//  view (self.view).
//
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    // Lighten the tint color when the view is in contact with a boundary.
    [(UIView*)item setTintColor:[UIColor lightGrayColor]];
}


//| ----------------------------------------------------------------------------
//  This method is called when square1 stops contacting a collision boundary.
//  In this demo, the only collision boundary is the bounds of the reference
//  view (self.view).
//
/**- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    // Restore the default color when ending a contcact.
    [(UIView*)item setTintColor:[UIColor darkGrayColor]];
    NSLog(@"in");
    
    NSLog(@"INdex == %i",self.currentBallININdex);
    

    
    [[GCDQueue highPriorityGlobalQueue]queueBarrierBlock:^{
        
            [[GCDQueue mainQueue]queueBlock:^{
                self.currentBallININdex++;
                if (self.currentBallININdex<[self.balls count]) {

                [self animateBallStart:[self.balls objectAtIndex:self.currentBallININdex]];
                }
                
            } afterDelay:0.1];
        
       
    }];

     
     
    
}**/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame

{
    self=[super init];
    if (self) {
        //887 * 100
        UIView  *view=[[UIView alloc]initWithFrame:frame];
        self.view=view;
        self.view.backgroundColor=[UIColor  clearColor];
        self.balls=[NSMutableArray new];
        self.animators=[NSMutableArray new];
        // Set the timing functions that should be used to calculate interpolation between the first two keyframes
       // [self makeBalls];
    }
    
    return self;
}

-(void)makeBalls
{
    self.currentBallININdex=0;
   __block int  startx=0;
    for (int i=0; i<8; i++) {
        
        BilliardBall *ball=[[BilliardBall alloc]initWithFrame:CGRectMake(startx, 0, BALL_RADIUS, BALL_RADIUS)];
            
        [self.balls addObject:ball];
        ball.gaugeHeight=self.view.bounds.size.height;
        ball.delegate=self;
        // [self addFallAnimationForLayer:ball.layer];
        [self.view addSubview:ball];
        startx+=BALL_RADIUS+10;
    }
    
    NSLog(@"Creating Balls");
    
    [self animateBallStart];
   // [self animateBallStart:[self.balls objectAtIndex:self.currentBallININdex]];
    
}

-(void)animateBallStart
{

    for (ItemCount i=0; i<[self.balls count]; i++) {
        
      //  NSLog(@"ANIMATE BALL START i %lu", i);
    ///    NSLog(@"[self.balls count] %lu", (unsigned long)[self.balls count]);
        
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        ball.alpha=0;
  /// [[GCDQueue mainQueue]queueBlock:^{
        
        CALayer *layer= ball.layer;
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CGPoint targetCenter=CGPointMake(ball.center.x,self.view.bounds.size.height-BALL_RADIUS/2 );
        // ball.animation = [CAKeyframeAnimation animationWithKeyPath:@"position"
         //                                                     function:BounceEaseOut
         //                                                    fromPoint:ball.center
         //                                                      toPoint:targetCenter];
        
        ball.animation = [self dockBounceAnimationWithIconHeight:150];
        
    
        ball.targetPoint=targetCenter;
        [ball.animation setDelegate:ball];
        ball.animation.beginTime = CACurrentMediaTime()+(0.1*i); ///WAS 0.1
        
        [layer addAnimation:ball.animation forKey:@"position"];
        
       [CATransaction commit];
       [ball setCenter:targetCenter];
   ///    } afterDelay:0.1];
    }
    
  ///   NSLog(@"COMPLETED ANIMATION!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reset        //MAY BE OK TO REMOVE ENTIRELY
{
    NSLog(@"BIG RESET");
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Croquet ball drop bounce cement_BLASTWAVEFX_29317" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        
        NSLog(@"SOUND: reset all %hhd", muteAudio);
        
        if (muteAudio == 1){
            NSLog(@"AUDIO MUTED");
        }else{
             [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
    
    
    for (BilliardBall *ball in self.balls) {
        
     //   NSLog(@"STOPPING BALLS");
        [ball stop];
        [ball blowingEnded];
        [ball removeFromSuperview];
    }
    
     NSLog(@"TRYING TO REMOVE ALL BALLS");
    
    [self.balls removeAllObjects];
    
    [self makeBalls];

    //ADDED THESE TWO LINES
   //self.powerGame=nil;
    //self.durationGame=nil;
    

}

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight
{
 //   NSLog(@"beginning animation");
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i=0; i<32; i++)
    {
        CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        
        CATransform3D transform = CATransform3DMakeTranslation(0, -positionOffset, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f/30.0f;///32.0f/30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES; // final stage is equal to starting stage
    animation.autoreverses = NO;
    
   //  NSLog(@"ending animation");
    
    return animation;
}

-(void)shootBallToTop:(int)ballIndex withAcceleration:(float)acceleration
{
    ///NSLog(@"Shooting balls to top BALLINDEX %d", ballIndex);
   ///  NSLog(@"Shooting balls to top [self.balls count] %d", [self.balls count]);
     NSLog(@"trying to shoot balls to top1");
    if (ballIndex>=[self.balls count]) {
        return;
    }
    BilliardBall  *ball=[self.balls objectAtIndex:ballIndex];
    CGPoint  point=CGPointMake(ball.center.x,BALL_RADIUS/2);
   // CGPoint  point=CGPointMake(0,0);
   // float  duration=5/acceleration;
    
    if(acceleration<0.1)
    {
        acceleration=0.05;
    }
    [UIView animateWithDuration:0.1 animations:^{
        [ball setCenter:point];
    }];
    NSLog(@"trying to shoot balls to top2");
}

- (void)bounce
{
  ///  CAKeyframeAnimation *animation = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:150];
 //   [_bounceView.layer addAnimation:animation forKey:@"jumping"];
}


-(void)pushBallsWithVelocity:(float)velocity
{
    float maxVelocity=30;
    
    NSString * difficulty=[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"];
    
    NSLog(@"PUSHING BALLS - - -  NSString DIFFICULTY IS %@", difficulty);
    
    int difficultyAsInt = [difficulty intValue];
    
    switch (difficultyAsInt) {
        case 0:
            maxVelocity=15;
            NSLog(@"POWER small");
           break;
        case 1:
            maxVelocity=50;
            NSLog(@"POWER medium");
           break;
        case 2:
            maxVelocity=65;
            NSLog(@"POWER hard");
          break;
            
        default:
            break;
    }
    
    if (velocity>maxVelocity) {
        velocity=maxVelocity;
    }
    
    int  perBall=maxVelocity/8;

    float perBallCount=0;
    
    int numberOfBallsToMove=(velocity/maxVelocity)*8;
    
    for (int i=0; i<numberOfBallsToMove; i++) {
        
        if (perBallCount<=maxVelocity) {
            
            //NSLog(@" inner BLOWING began  %d!!!", i);
            BilliardBall  *ball=[self.balls objectAtIndex:i];
            [ball blowingBegan];
            [ball setForce:velocity*80];
            perBallCount+=perBall;
            

        }
    }
    
    for (int i=numberOfBallsToMove; i<[self.balls count]; i++) {
        BilliardBall  *ball=[self.balls objectAtIndex:i];
       // NSLog(@" inner BLOWING ENDED  %d!!!", i);
        [ball blowingEnded];
    }
    
     //NSLog(@"BLOWING ENDED maxvelocity %f!!!", maxVelocity);

}
-(void)startBallsPowerGame
{
    ballGameCount=0;
    
    
    NSLog(@"Started ball power game!");
    
    for (int i=0; i<[self.balls count]; i++) {
        
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        
        [ball start];
        [ball blowingBegan];
    }
}

-(void)endBallsPowerGame
{
    
    for (int i=0; i<[self.balls count]; i++) {
        
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        
      //  [ball stop]; ///maybe uncomment added
        [ball blowingEnded];
      ///  NSLog(@"POWER GAME BLOWING ENDED!!!");
    }
}
-(void)startDurationPowerGame
{    
    NSLog(@"STARTING DURATION GAME");
    self.durationGame.ballsCopy=[self.balls mutableCopy];
    [self.durationGame startGame];
}

-(void)endDurationPowerGame
{
    
    NSLog(@"END DURATION GAME");
    
    for (int i=0; i<[self.balls count]; i++) {
        
        BilliardBall  *ball=[self.balls objectAtIndex:i];
        
         [ball stop];
        [ball blowingEnded];
        
    }
    [self.durationGame endGame];
}

-(void)playHitTop
{
    
    NSLog(@"BALLS HITTING TOP");
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        
        NSLog(@"SOUND:AUDIO HIT TOP");
        if (muteAudio == 1){
            NSLog(@"AUDIO MUTED");
        }else{
            [audioPlayer play];
        }
       // [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
}
-(void)ballReachedFinalTarget:(BilliardBall *)ball

{
  //  [[GCDQueue highPriorityGlobalQueue]queueBlock:^{
   // [[GCDQueue mainQueue]queueBlock:^{
        [self playHitTop];

   // }];

    
  // }];
    ballGameCount++;
    
    
    if (self.currentGameType==gameTypePowerMode) {
        if (ballGameCount>=[self.balls count]) {
            NSLog(@"POWER GAME WON");
            [self.powerGame.delegate gameWon:self.powerGame];
        }
    }else if (self.currentGameType==gameTypeDurationMode)
    {
       int result= [self.durationGame nextBall];
        
        if (result==-1) {
            NSLog(@"COMPLETED DURATION MODE");
            [self.durationGame.delegate gameWon:self.durationGame];
        }
    }
   
    NSLog(@"a ball is done");
}

-(void)setAudioMute: (BOOL) muteSetting{
    
    NSLog(@"setting inner audio mute %hhd", muteSetting);

    muteAudio = muteSetting;
}

@end
