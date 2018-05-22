#import "DurationGame.h"
#import "BilliardBall.h"
#import "Balloon.h"
@interface DurationGame ()
{
    AVAudioPlayer *audioPlayer;
}
@property(nonatomic,strong)NSDate  *startTime;
@property(nonatomic,weak)BilliardBall  *currentBilliardBall;
@property(nonatomic,weak)BilliardBall  *currentBalloon;
@end

@implementation DurationGame
-(id)init
{
    if (self==[super init]) {
        
        self.currentBall=0;
        self.totalBalls=8;
        self.secondsPerballEasy=30;// equate to .5 seconds;
        self.secondsPerballMedium=20;// equate to .5 seconds;
        self.secondsPerballHard=8;// equate to .5 seconds;
        self.isRunning=NO;
    }
    return self;
}

-(void)startGame
{
    [super startGame];
    self.startTime=[NSDate date];
    self.currentBilliardBall=[self.ballsCopy objectAtIndex:self.currentBall];
    [self.currentBilliardBall start];
    [self.currentBilliardBall blowingBegan];
}

-(void)playHitTop
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    audioPlayer.volume=0.3;
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
}

-(int)nextBall
{
    [self playHitTop];
    self.currentBall++;
    if (self.currentBall<[self.ballsCopy count]) {
        //[self.delegate gameEnded:self];
        [self.currentBilliardBall stop];
        [self.currentBilliardBall blowingEnded];
        self.currentBilliardBall=[self.ballsCopy objectAtIndex:self.currentBall];
        [self.currentBilliardBall start];
        [self.currentBilliardBall blowingBegan];
        return self.currentBall;
    }else
    {
       // self.isRunning=NO;
        return -1;
    }
}

-(void)pushBall
{
     if (self.currentBall>=[self.ballsCopy count])
     {
        // self.isRunning=NO;
     }
    float amount=0;
    
    gameDifficulty  difficulty=[[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"]floatValue];

    switch (difficulty) {
        case gameDifficultyEasy:
            amount=self.secondsPerballEasy;
            break;
        case gameDifficultMedium:
            amount=self.secondsPerballMedium;

            break;
        case gameDifficultyHard:
            amount=self.secondsPerballHard;

            break;
            
        default:
            break;
    }
    [self.currentBilliardBall setForce:amount*50];
}
-(void)endGame
{
   // self.isRunning=NO;
    [self.currentBilliardBall stop];
}
@end
