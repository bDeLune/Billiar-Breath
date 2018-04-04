//
//  GameViewController.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Game.h"
#import "AbstractGame.h"
#import "MidiController.h"



@protocol GameViewProtocol <NSObject>

-(void)gameViewExitGame;

@end

@interface GameViewController : UIViewController<MidiControllerProtocol,GameProtocol>

@property(nonatomic,weak)IBOutlet  UIButton  *backToLoginButton;
@property(nonatomic,weak)IBOutlet  UIButton *toggleDirectionButton;
@property(nonatomic,weak)IBOutlet  UIButton *toggleGameModeButton;
@property(nonatomic,weak)IBOutlet  UIButton *resetGameButton;
@property(nonatomic,weak)IBOutlet  UIButton  *settingsButton;

@property(nonatomic,weak)IBOutlet  UIButton  *testDurationButton;


@property(nonatomic,weak)IBOutlet  UIImageView  *background;


@property(nonatomic,weak)IBOutlet  UILabel  *targetLabel;
@property(nonatomic,weak)IBOutlet  UILabel  *durationLabel;
@property(nonatomic,weak)IBOutlet  UILabel  *speedLabel;
@property(nonatomic,weak)IBOutlet  UILabel  *strenghtLabel;
@property(nonatomic,weak)IBOutlet  UILabel *currentUsersNameLabel;
@property(nonatomic,weak)IBOutlet  UITextView *debugtext;
@property(nonatomic,weak)IBOutlet  UIButton  *usersButton;



@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *gameUser;
@property(nonatomic,unsafe_unretained)id<GameViewProtocol>delegate;


-(void)setLabels;

-(IBAction)exitGameScreen:(id)sender;
-(IBAction)toggleDirection:(id)sender;
-(IBAction)toggleGameMode:(id)sender;
-(IBAction)presentSettings:(id)sender;
-(IBAction)resetGame:(id)sender;


-(IBAction)testButtonDown:(id)sender;
-(IBAction)testButtonUp:(id)sender;


@end
