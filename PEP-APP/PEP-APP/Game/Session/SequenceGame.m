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

-(id)initWithBallCount: (int)ballCount
{
    if (self==[super init]) {
        self.currentBall=0;
        self.totalBalls= ballCount;
        self.totalBallsRaised=0;
        self.totalBallsAttempted=0;
        gamewon=NO;
        self.saveable=NO;
        self.halt=NO;
        self.time=0;
    }
    return self;
}

-(void)setBallCount: (float)ballCount{
    self.totalBalls = ballCount;
}

-(int)nextBall{
    self.halt=NO;
    self.currentBall++;
    self.totalBallsAttempted++;
        if (self.totalBallsRaised>=self.totalBalls) {
            if (!gamewon) {
                [self.delegate gameWon:self];
                    gamewon=YES;
                }
            return -1;
        }
    if (!gamewon) {
        if (self.totalBallsAttempted>=self.totalBalls) {
            [self.delegate gameEnded:self];
            return -1;
        }
    }
    return self.currentBall;
}
@end
