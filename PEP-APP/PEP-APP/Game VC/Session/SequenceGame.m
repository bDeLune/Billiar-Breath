#import "SequenceGame.h"
#import <AVFoundation/AVFoundation.h>

@interface SequenceGame()
{
    BOOL gamewon;
    AVAudioPlayer *audioPlayer;
    BOOL muteAudio;
    int currentGameBallCount;
}

@end

@implementation SequenceGame
-(id)init
{
    if (self==[super init]) {
        self.currentBall=0;
        self.totalBalls=8;      //total balls
        self.totalBallsRaised=0;
        self.totalBallsAttempted=0;
        gamewon=NO;
        self.saveable=NO;
        self.halt=NO;
        self.time=0;
        
        NSLog(@"INIT! initialised balloon game ballcount %d", self.totalBalls);
    }
    
    return self;
}

-(id)initWithBallCount: (int)ballCount
{
    if (self==[super init]) {
        self.currentBall=0;
        self.totalBalls= ballCount;      //total balls
        self.totalBallsRaised=0;
        self.totalBallsAttempted=0;
        gamewon=NO;
        self.saveable=NO;
        self.halt=NO;
        self.time=0;
        
        NSLog(@"INIT BALLCOUNT! initialised balloon game ballcount %d", self.totalBalls);
    }
    
    return self;
}

-(void)setBallCount: (float)ballCount{
    
    NSLog(@"setting sequence game ballcount to %f", ballCount);
    self.totalBalls = ballCount;
}


-(void)playHitTop
{
    //remove
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                               error:&error];
    audioPlayer.volume=0.3;
    [audioPlayer prepareToPlay];
    NSLog(@"SOUND: playing hit top SEQ %hhd", muteAudio);
    if (muteAudio == 0){
        //[audioPlayer play];
    }
}

-(int)nextBall{
    NSLog(@"next ball");
    self.halt=NO;
    //[self playHitTop];
    self.currentBall++;
    NSLog(@"Current ball is %d", self.currentBall);
    
    self.totalBallsAttempted++;
       // [self.delegate gameEnded:self];
       // return -1;
        if (self.totalBallsRaised>=self.totalBalls) {
       //     [[GCDQueue mainQueue]queueBlock:^{
                if (!gamewon) {
                    [self.delegate gameWon:self];
                    gamewon=YES;
                }
         //   } afterDelay:1.0];
            return -1;
        }
    if (!gamewon) {
        if (self.totalBallsAttempted>=self.totalBalls) {
            [self.delegate gameEnded:self];
            
            NSLog(@"Game was completed but not won");
            return -1;
        }
    }
    return self.currentBall;
}

-(void)setAudioMute: (BOOL) muteSetting{
    NSLog(@"setting inner audio mute SEQ %hhd", muteSetting);
    muteAudio = muteSetting;
}
@end
