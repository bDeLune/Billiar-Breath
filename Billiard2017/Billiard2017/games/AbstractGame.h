//
//  Game.h
//  BilliardBreath
//
//  Created by barry on 10/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum gameType
{
    gameTypeSequence,
    gameTypePowerMode,
    gameTypeDurationMode
    
}gameType;

typedef enum
{
    gameDifficultyEasy,
    gameDifficultMedium,
    gameDifficultyHard
}gameDifficulty;

@class AbstractGame;
@protocol GameProtocol <NSObject>

-(void)gameEnded:(AbstractGame*)game;
-(void)gameStarted:(AbstractGame*)game;
-(void)gameWon:(AbstractGame*)game;

@end

@interface AbstractGame : NSObject
{
    NSTimer  *timer;
    NSDate *startdate;
}
@property(nonatomic,unsafe_unretained)id<GameProtocol>delegate;
@property  int currentBall;
@property  int totalBalls;
@property BOOL  saveable;
-(void)startGame;
-(void)endGame;
-(int)nextBall;
@property float time;
-(void)startTimer;
-(void)killTimer;
@end
