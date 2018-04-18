#import "GameViewController.h"
#import "User.h"
#import "BilliardBallViewController.h"
#import "BilliardBall.h"
#import "Session.h"
#import "SequenceGame.h"
#import "PowerGame.h"
#import "DurationGame.h"
#import "Game.h"
#import "AddNewScoreOperation.h"
#import "UIEffectDesignerView.h"
#import "GCDQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "BTLEManager.h"
#import "UserListViewController.h"

@interface GameViewController ()<BTLEManagerDelegate, UITabBarDelegate,UITabBarControllerDelegate, SETTINGS_DELEGATE>
{
    int threshold;
    CADisplayLink *testDurationDisplayLink;
    gameDifficulty  currentDifficulty;
    AVAudioPlayer  *audioPlayer;
    UIEffectDesignerView *particleEffect;
    NSTimer  *effectTimer;
    bool wasExhaling;
    
    //all maybe
    GPUImagePicture *sourcePicture;
    GPUImageFilter *stillImageFilter;
    GPUImageView *imageView;
    CGFloat  defaultRadius;
    CGFloat  defaultScale;
    CGFloat  targetRadius;
    CGFloat  targetScale;
    CADisplayLink *displayLink;
    BOOL animationRunning;
    NSTimeInterval drawDuration;
    CFTimeInterval lastDrawTime;
    CGFloat drawProgress;
    int inorout;
    //  MIDIPortRef inPort ;
    //  MIDIPortRef outPort ;
    UIButton  *picselect;
    UIPopoverController *popover;
    UIImagePickerController *imagePickerController;
    UIButton  *togglebutton;
    BOOL   toggleIsON;
    float mass;
    BOOL isaccelerating;
    float acceleration;// force/ mass
    float distance;
    float time;
    float sketchamount;
    BOOL ledTestIsOn;
}

@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic, retain) NSMutableArray *capturedImages;
@property(nonatomic,strong)BTLEManager  *btleMager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSOperationQueue  *addGameQueue;
@property(nonatomic,strong)BilliardBallViewController  *billiardViewController;
@property(nonatomic,strong)MidiController  *midiController;
@property(nonatomic)gameType  currentGameType;
@property(nonatomic,strong)Session  *currentSession;
@property(nonatomic,strong)SequenceGame  *sequenceGameController;
@property(nonatomic,strong)PowerGame  *powerGameController;
@property(nonatomic,strong)DurationGame  *durationGameController;
@property(nonatomic,strong)BTLEManager  *btleManager;
@property(nonatomic,strong)UIImageView  *btOnOfImageView;
@property(nonatomic,strong)UserListViewController  *userList;
@property (weak, nonatomic) IBOutlet UIImageView *imageFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *billiardBallView;
@property(nonatomic,strong)UINavigationController *navcontroller;
@property (strong, nonatomic) UITabBarController *tabBarController;
@end

@implementation GameViewController

-(void)userListDismissRequest:(UserListViewController *)caller
{
    [[GCDQueue mainQueue]queueBlock:^{
        [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
            self.userList.sharedPSC=self.sharedPSC;
            self.userList.delegate=self;
        }];
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    NSLog(@"CLICKED TAB BAR ITEM");
    NSLog(@"%@", item);
}

-(void)btleManagerConnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
    });
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
    });
}

#pragma mark -
#pragma mark - Session

-(void)startSession
{
    NSLog(@"START Session");
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
}

#pragma mark -
#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.midiController && [keyPath isEqualToString:@"numberOfSources"]) {
        
        if (self.midiController.numberOfSources == 0) {
            // [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
            NSLog(@"No Midi Sources!!!");
            UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Midi Message" message:@"No Midi Device Detected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [[GCDQueue mainQueue]queueBlock:^{
                [alert show];
            }];
            //[self.delegate LoginSucceeded:self user:[self user:self.usernameTextField.text]];
        }else
        {
            NSLog(@" Midi Sources Detected!!!");
            
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 260, 650, 325)];
        self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 160, 450, 225)];
       // self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 260, 650, 325)];
        self.midiController=[[MidiController alloc]init];
        self.midiController.delegate=self;
        [self.midiController addObserver:self forKeyPath:@"numberOfSources" options:0 context:NULL];
        // [self.midiController setup];
        self.currentGameType=gameTypeSequence;
        
        currentDifficulty=gameDifficultyEasy;
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:currentDifficulty] forKey:@"difficulty"];
        
        NSLog(@"CURRENT DIFFICULTY %u", currentDifficulty);
        wasExhaling = true;
        
        self.addGameQueue=[[NSOperationQueue alloc]init];
        self.btleManager=[BTLEManager new];
        self.btleManager.delegate=self;
        [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
        [self.btleManager setRangeReduction:2];
        [self.btleManager setTreshold:60];
        [self startSession];
        
        self.btOnOfImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-230, 30, 100, 100)];
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
        [self.view addSubview:self.btOnOfImageView];
        
        ///image
        sketchamount=0;
        self.title = @"Groov";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        _animationrate=1;
        picselect=[UIButton buttonWithType:UIButtonTypeCustom];
        picselect.frame=CGRectMake(0, self.view.frame.size.height-120, 108, 58);
        [picselect addTarget:self action:@selector(photoButtonLibraryAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:picselect];
        
        [picselect setBackgroundImage:[UIImage imageNamed:@"PickPhotoButton.png"] forState:UIControlStateNormal];
        
        self.capturedImages = [NSMutableArray array];
        
        /*   AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:
         [[NSBundle mainBundle] pathForResource:@"tick"
         ofType:@"aiff"]],
         &_tickSound);*/
        
        imagePickerController = [[UIImagePickerController alloc] init] ;
        imagePickerController.delegate = self;
        
        //  [self.view addSubview:imagePickerController.view];
        
        //  togglebutton=[UIButton buttonWithType:UIButtonTypeCustom];
        // togglebutton.frame=CGRectMake(110, self.view.frame.size.height-120, 108, 58);
        // [togglebutton addTarget:self action:@selector(toggleDirection:) forControlEvents:UIControlEventTouchUpInside];
        // [self.view addSubview:togglebutton];
        
        //  [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_EXHALE.png"] forState:UIControlStateNormal];
        //  toggleIsON=NO;
        // threshold=0;
        
        // self.btOnOfImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
        //  [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
        //  [self.view addSubview:self.btOnOfImageView];
        //  self.ledTestButton=[[UIButton alloc]initWithFrame:CGRectMake(110, 10, 100, 100)];
        //  [self.ledTestButton setBackgroundColor:[UIColor greenColor]];
        //  [self.ledTestButton addTarget:self action:@selector(testLed:) forControlEvents:UIControlEventTouchUpInside];
        //dead [self.view addSubview:self.ledTestButton];
    }
    
    return self;
}

//FIND ALLOW BREATH FUNCTION
-(void)btleManagerBreathBegan:(BTLEManager*)manager{
    
    /// NSLog(@"allow == %i",[self.midiController allowBreath]);
    if ([self.midiController allowBreath]==NO) {
        return;
    }
    
    if ((self.midiController.toggleIsON == 0 && wasExhaling == 1) || (self.midiController.toggleIsON == 1 && wasExhaling == 0)){
        
        [self midiNoteBegan:nil];
        
    }else{
        
        NSLog(@"FIRST MIDI NOTE BEGAN DISALLOWED!");
    }
}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    /// NSLog(@"allow == %i",[self.midiController allowBreath]);
    if ([self.midiController allowBreath]==NO) {
        return;
    }
    
    [self midiNoteStopped:nil];
    isaccelerating=NO;
}


-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    
    wasExhaling = false;
    
    if (self.midiController.toggleIsON==NO) {
        
        
        NSLog(@"INHALING AND RETURNING");
        return;
    }
   // currentdirection=midiinhale;
    //self.velocity=(percentOfmax/10.0)*127.0;
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    //  NSLog(@"inhaleWithValue %f",percentOfmax);
    
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
    
    [self midiNoteContinuing: self.midiController];
}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    wasExhaling = true;
    
    if (self.midiController.toggleIsON==YES) {
        NSLog(@"EXHALING AND RETURNING");
        return;
    }
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
    [self midiNoteContinuing: self.midiController];
    
  //  currentdirection=midiexhale;
    //self.velocity=(percentOfmax/10.0)*127.0;
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    if (self.sharedPSC != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    
    
    return _managedObjectContext;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.billiardViewController.view];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
    self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    self.userList.sharedPSC=self.sharedPSC;
    
    self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];
    
    CGRect frame = self.view.frame;
    [self.navcontroller.view setFrame:frame];
    
    midiinhale=61;
    midiexhale=73;
    velocity=0;
    midiIsOn=false;
    targetRadius=0;
    defaultScale=1.5;
    defaultRadius=0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setLabels
{
    [self managedObjectContext];
    [[GCDQueue mainQueue]queueBlock:^{
        self.currentUsersNameLabel.text=[self.gameUser valueForKey:@"userName"];
        // [self setTargetScore];
        
    }];
}
#pragma - UIControls

-(IBAction)exitGameScreen:(id)sender
{
    [self.delegate gameViewExitGame];
}

- (IBAction)toSettingsScreen:(id)sender {
    
    NSLog(@"Go to settings screen");
    [self.delegate toSettingsScreen];
}

-(IBAction)toggleDirection:(id)sender
{
    
    switch (self.midiController.toggleIsON) {
        case 0:
            self.midiController.toggleIsON=YES;
            //  midiController.currentdirection=midiinhale;
            [self.toggleDirectionButton setBackgroundImage:[UIImage imageNamed:@"BreathDirectionINHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
            wasExhaling = false;
            break;
        case 1:
            self.midiController.toggleIsON=NO;
            
            [self.toggleDirectionButton setBackgroundImage:[UIImage imageNamed:@"BreathDirectionEXHALE.png"] forState:UIControlStateNormal];
            //  midiController.currentdirection=midiexhale;
            
            [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
            wasExhaling = true;
            break;
            
        default:
            break;
    }
}

-(IBAction)toggleGameMode:(id)sender
{
    int mode=self.currentGameType;
    
    mode++;
    
    if (mode>2) {
        mode=gameTypeSequence;
    }
    
    self.currentGameType=mode;
    self.billiardViewController.currentGameType=  self.currentGameType;
    
    NSLog(@"Current game mode %u", self.currentGameType);
    
    [self.toggleGameModeButton setBackgroundImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    
    //[self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonLOW"] forState:UIControlStateNormal];
    /// [self setThreshold:0];
    
    [self resetGame:nil];
}

-(NSString*)stringForMode:(int)mode
{
    NSString  *modeString;
    
    switch (mode) {
        case gameTypeDurationMode:
            modeString=@"ModeButtonDURATION";
            break;
            
        case gameTypePowerMode:
            modeString=@"ModeButtonPOWER";
            
            break;
            
        case gameTypeSequence:
            modeString=@"ModeButtonSEQUENCE";
            
            break;
            
        default:
            break;
    }
    
    return modeString;
}

-(IBAction)presentSettings:(id)sender
{
    int mode=currentDifficulty;
    
    mode++;
    
    if (mode>2) {
        mode=gameDifficultyEasy;
    }
    
    currentDifficulty=mode;
    // int presentDifficulty = [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:currentDifficulty] forKey:@"difficulty"];
    
    int setDifficulty = [[[NSUserDefaults standardUserDefaults] objectForKey:@"difficulty"] intValue];
    ///  int savedValue = [highScore IntValue];
    
    //NSLog(@"THISDIFF: %d", setDifficulty);
    
    
    if (setDifficulty == 2 || setDifficulty > 2){
        setDifficulty = 0;
    }else{
        setDifficulty++;
    }
    
    /// NSLog(@"THISDIFF1: %d", setDifficulty);
    
    /** [self.toggleGameModeButton setBackgroundImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];**/
    
    switch (setDifficulty) {
        case 0:
            [self setThreshold:0];
            NSLog(@"set SMALL");
            break;
            
        case 1:
            [self setThreshold:1];
            NSLog(@"set MEDIUM");
            
            break;
        case 2:
            [self setThreshold:2];
            NSLog(@"set LARGE");
            
            
            break;
            
        default:
            break;
    }
    
}
-(IBAction)resetGame:(id)sender
{
    
    NSLog(@"RESETTING GAME");
    
    self.sequenceGameController=[SequenceGame new];
    self.sequenceGameController.delegate=self;
    self.powerGameController=[PowerGame new];
    self.powerGameController.delegate=self;
    self.durationGameController=[DurationGame new];
    self.durationGameController.delegate=self;
    //[self setThreshold:0];
    [self.billiardViewController reset];
    //[self test];
}

#pragma - Midi Delegate

-(void)midiNoteBegan:(MidiController*)midi
{
    // NSLog(@"MIDI NOTES BEGAN");
    // NSLog(@"self.midiController.toggleIsON %hhd", self.midiController.toggleIsON);
    // NSLog(@"wasExhaling %d", wasExhaling);
    
    if ((self.midiController.toggleIsON == 0 && wasExhaling == 1) || (self.midiController.toggleIsON == 1 && wasExhaling == 0)){
        
        [self.sequenceGameController startTimer];
        
        switch (self.currentGameType) {
            case gameTypeDurationMode:
                self.durationGameController.isRunning=YES;
                self.billiardViewController.currentGameType=gameTypeDurationMode;
                [self midiNoteBeganForDuration:midi];
                break;
            case gameTypePowerMode:
                [self midiNoteBeganForPower:midi];
                self.billiardViewController.currentGameType=gameTypePowerMode;
                
                break;
            case gameTypeSequence:
                
                [self midiNoteBeganForSequence:midi];
                self.billiardViewController.currentGameType=gameTypeSequence;
                
                break;
            default:
                break;
        }
        
    }else{
        ///     NSLog(@"DISALLOWING MIDI NOTES BEGAN!");
    }
}

-(void)midiNoteStopped:(MidiController*)midi
{
    // NSLog(@"Midi Stopped\n");
    
    if ((self.midiController.toggleIsON == false && wasExhaling == true) || (self.midiController.toggleIsON == true && wasExhaling == false)){
        
        
        
        // NSLog(@"MIDI NOTES STOPPED HERE");
        
        switch (self.currentGameType) {
            case gameTypeDurationMode:
                self.durationGameController.isRunning=NO;
                [self midiNoteStoppedForDuration:midi];
                break;
            case gameTypePowerMode:
                [self midiNoteStoppedForPower:midi];
                break;
            case gameTypeSequence:
                
                [self midiNoteStoppedForSequence:midi];
                
                break;
            default:
                break;
        }
        /// wasExhaling = nil;
    }else{
        //  NSLog(@"DISALLOWING MIDI NOTES STOPPED!");
    }
}

-(void)midiNoteContinuing:(MidiController*)midi
{
    
    if (midi.velocity==127) {
        return;
    }
    /// NSLog(@"Midi Continue\n");
    if (midi.velocity>[self.currentSession.sessionStrength floatValue]) {
        
        if (midi.velocity!=127) {
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:midi.velocity];
            
        }
        // [gaugeView setArrowPos:0];
    }
    
    if(self.currentGameType==gameTypeDurationMode)
    {
        if (self.durationGameController.isRunning) {
            self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];
            
        }
    }else
    {
        self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];
        
    }
    self.currentSession.sessionSpeed=[NSNumber numberWithFloat:midi.speed];
    
    NSString  *durationtext=[NSString stringWithFormat:@"%0.1f",self.sequenceGameController.time];
    
    [[GCDQueue mainQueue]queueBlock:^{
        if (midi.velocity!=127) {
            
        }
        // if (midi.speed!=0) {
        //  [self.speedLabel setText:[NSString stringWithFormat:@"%0.0f",midi.speed]];
    }];
    
    if (midi.velocity>self.powerGameController.power) {
        self.powerGameController.power=midi.velocity;
    }
    
    [[GCDQueue mainQueue]queueBlock:^{
        
        
        switch (self.currentGameType) {
            case gameTypeDurationMode:
                [self midiNoteContinuingForDuration:midi];
                
                // if (self.durationGameController.isRunning) {
                [self.durationLabel setText:durationtext];
                
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.01f",midi.velocity]];
                // }
                
                
                break;
            case gameTypePowerMode:
                [self midiNoteContinuingForPower:midi];
                [self.durationLabel setText:durationtext];
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%i",self.powerGameController.power]];
                
                break;
            case gameTypeSequence:
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
                
                [self midiNoteContinuingForSequence:midi];
                
                break;
            default:
                break;
        }
    }];
}

#pragma - Sequence

-(void)midiNoteBeganForSequence:(MidiController *)midi
{
    
    self.sequenceGameController.currentSpeed=-1;
    
    // if (self.sequenceGameController.currentBall==0) {
    [self.sequenceGameController startTimer];
    // }//ADDED
    
}
-(void)midiNoteStoppedForSequence:(MidiController *)midi
{
    [self.sequenceGameController nextBall];
}

-(void)midiNoteContinuingForSequence:(MidiController*)midi
{
    // if (self.sequenceGameController.currentSpeed==-1) {
    self.sequenceGameController.currentSpeed=midi.speed;
    /** [[GCDQueue mainQueue]queueBlock:^{
     [self.debugtext setText:[NSString stringWithFormat:@"%@%0.0f",self.debugtext.text,midi.speed]];
     
     }];**/
    
    gameDifficulty  difficulty=[[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"]intValue];
    
    
    NSLog(@"self.sequenceGameController.currentSpeed %d", self.sequenceGameController.currentSpeed);
    ///   NSLog(@"MIDI NOITE CONTINUING WITH difficulty %u", difficulty);
    
    switch (difficulty) {
        case 0: //was gameDifficultyEasy:
            // NSLog(@"MIDI NOTE BLOWING difficulty 0");
            [self.sequenceGameController setAllowNextBall:YES];
            NSLog(@"Sequence small");
            break;
        case 1: //added was gameDifficultMedium:
            /// NSLog(@"MIDI NOTE BLOWING difficulty 1");
            if (self.sequenceGameController.currentSpeed>15) {       //was 1
                [self.sequenceGameController setAllowNextBall:YES];
                NSLog(@"Sequence medium");
            }else
            {
                [self.sequenceGameController setAllowNextBall:NO];
                
            }
            
            break;
        case 2: //added was gameDifficultyHard:
            ///  NSLog(@"MIDI NOTE BLOWING difficulty 2");
            if (self.sequenceGameController.currentSpeed>50) {       ///was 2
                [self.sequenceGameController setAllowNextBall:YES];
                NSLog(@"Sequence hard");
            }else
            {
                [self.sequenceGameController setAllowNextBall:NO];
                
            }
            
            break;
            
        default:
            break;
    }
    
    
    if (self.sequenceGameController.halt) {
        return;
    }
    
    if (self.sequenceGameController.allowNextBall) {
        self.sequenceGameController.halt=YES;
        
        
        [[GCDQueue mainQueue]queueBlock:^{
            NSString  *durationtext=[NSString stringWithFormat:@"%0.1f",self.sequenceGameController.time];
            [self.durationLabel setText:durationtext];
            
            if (midi.velocity!=127) {
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
                
            }
            if (midi.speed!=0) {
                NSLog(@"trying to shoot balls to top");
                [self.billiardViewController shootBallToTop:self.sequenceGameController.currentBall withAcceleration:midi.speed];
                self.sequenceGameController.totalBallsRaised++;
                [self.sequenceGameController playHitTop];
                
            }//added
        }];
    }
    // }
}
#pragma - Duration
-(void)midiNoteBeganForDuration:(MidiController *)midi
{
    ///  NSLog(@"MIDI NOTES midiNoteBeganForDuration");
    self.billiardViewController.durationGame=self.durationGameController;
    [self.billiardViewController startDurationPowerGame];
    
}
-(void)midiNoteStoppedForDuration:(MidiController *)midi
{
    ///NSLog(@"MIDI NOTES midiNoteStoppedForDuration");
    [[GCDQueue mainQueue]queueBlock:^{
        
        [self.billiardViewController endDurationPowerGame];
        
        [self resetGame:nil];
    }];
    
    [self saveCurrentSession];
    
    
}
-(void)midiNoteContinuingForDuration:(MidiController*)midi
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self.durationGameController pushBall];
        
    }];
}


#pragma - Power

-(void)midiNoteBeganForPower:(MidiController *)midi
{
    
    ///   NSLog(@"MIDI NOTES BEGAN FOR POWER");
    self.billiardViewController.powerGame=self.powerGameController;
    [self.billiardViewController startBallsPowerGame];
    
}


-(void)midiNoteStoppedForPower:(MidiController *)midi
{
    if ((self.midiController.toggleIsON == false && wasExhaling == true) || (self.midiController.toggleIsON == true && wasExhaling == false)){
        
        NSLog(@"MIDI NOTES STOPPED FOR POWER");
        
        
        
        [[GCDQueue mainQueue]queueBlock:^{
            [self.billiardViewController endBallsPowerGame];
            
            ///  [self saveCurrentSession];
            [self resetGame:nil];
        }];
        
        /// [self saveCurrentSession];
        
        
        
    }else{
        NSLog(@"MIDI NOTE DISALLOWED - B");
        
    }
    
}

-(void)test
{
    // [self.billiardViewController startDurationPowerGame];
    
    // [self.billiardViewController pushBallsWithVelocity:40];
    
    [self addTestScores];
    
}
-(void)midiNoteContinuingForPower:(MidiController*)midi
{
    
    float  vel=midi.velocity;
    // vel=30;
    
    if (vel<threshold) {
        return;
    }
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self.billiardViewController pushBallsWithVelocity:vel];
    }];
}

-(void)sendLogToOutput:(NSString*)log

{
    [[GCDQueue  mainQueue]queueBlock:^{
        [self.debugtext setText:log];
    }];
}

-(void)setThreshold:(int)pvalue
{
    
    switch (pvalue) {
        case 0:
            threshold=10;
            NSLog(@"SETTING DIFFICULTY THRESHOLD TO 0 or %d", threshold);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"difficulty"];
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonLOW"] forState:UIControlStateNormal];
            break;
            
        case 1:
            threshold=25;
            NSLog(@"SETTING DIFFICULTY THRESHOLD TO 1 or %d", threshold);
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonMEDIUM"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"difficulty"];
            break;
        case 2:
            threshold=50;
            NSLog(@"SETTING DIFFICULTY THRESHOLD TO 2 or %d", threshold);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"difficulty"];
            [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"DifficultyButtonHIGH"] forState:UIControlStateNormal];
            break;
            
            // case 3:
            //       threshold=50;
            //       NSLog(@"SETTING DIFFICULTY THRESHOLD TO %d", threshold); //added
            //       break;
            
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)gameEnded:(AbstractGame *)game
{
    self.durationGameController.isRunning=NO;
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame:nil];
    }];
    
    //if (game.saveable) {
    [self saveCurrentSession]; ///addded
    
    ///}
    
    [self.sequenceGameController killTimer];
}
-(void)gameStarted:(AbstractGame *)game
{
    
}
/*
 
 
 -(void)gameWon:(AbstractGame *)game
 {
 if (particleEffect) {
 return;
 }
 
 // if (game.saveable) {
 
 if (self.currentGameType==gameTypeDurationMode) {
 [[GCDQueue mainQueue]queueBlock:^{
 [self playSound];
 [self startEffects];
 // [self resetGame:nil];
 
 }];
 
 }else
 {
 [self saveCurrentSession];
 self.durationGameController.isRunning=YES;
 
 [[GCDQueue mainQueue]queueBlock:^{
 [self playSound];
 [self startEffects];
 [self resetGame:nil];
 
 }];
 
 
 }
 
 // }
 
 
 
 // UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
 // [self.view addSubview:effectView];
 
 
 [self.sequenceGameController killTimer];
 }
 */

-(void)gameWonDuration
{
    
    if (particleEffect) {
        return;
    }
    
    // self.durationGameController.isRunning=NO;
    [[GCDQueue mainQueue]queueBlock:^{
        [self playSound];
        [self startEffects];
        /// [self resetGame:nil];
        
    }];
    
    
    // UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
    // [self.view addSubview:effectView];
    // if (game.saveable) {
    //[self saveCurrentSession];
    
    // }
    
    [self.sequenceGameController killTimer];
}
-(void)gameWon:(AbstractGame *)game
{
    
    NSLog(@"GAME WON");
    
    if (self.currentGameType==gameTypeDurationMode) {
        
        [self gameWonDuration];
        return;
    }
    
    if (particleEffect) {
        return;
    }
    
    self.durationGameController.isRunning=NO;
    
    
    [[GCDQueue mainQueue]queueBlock:^{
        [self playSound];
        [self startEffects];
        [self resetGame:nil];
        
    }];
    
    
    // [[GCDQueue mainQueue]queueBlock:^{
    //  [self resetGame:nil];
    //  } afterDelay:1.0];
    
    
    
    
    //UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
    // [self.view addSubview:effectView];
    
    if (self.currentGameType==gameTypePowerMode) {
        [[GCDQueue mainQueue]queueBlock:^{
            [self saveCurrentSession];  //added kung
        }];
        return;
    }
    
    if (game.saveable) {
        ///
    }
    
    [self.sequenceGameController killTimer];
}
-(void)startEffects
{
    
    particleEffect = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
    //  CGRect frame=particleEffect.frame;
    particleEffect.frame=self.view.frame;
    CGRect frame=particleEffect.frame;
    frame.origin.x+=100;
    frame.origin.y-=50;
    particleEffect.frame=frame;
    [self.view addSubview:particleEffect];
    effectTimer=[NSTimer timerWithTimeInterval:2 target:self selector:@selector(killSparks) userInfo:nil repeats:NO];///timer was 2
    [[NSRunLoop mainRunLoop] addTimer:effectTimer forMode:NSDefaultRunLoopMode];
    
}

-(void)killSparks
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [particleEffect removeFromSuperview];
        particleEffect=nil;
        [effectTimer invalidate];
        effectTimer=nil;
        
    });
}

-(void)saveCurrentSession
{
    //NSLog(@"Save Current Session");
    
    self.currentSession.sessionType=[NSNumber numberWithInt:self.currentGameType];
    
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    
    
    NSLog(@"SAVING CURRENT SESSION");
    
    [self.addGameQueue addOperation:operation];
    
    [self startSession];
    
}

-(void)setTargetScore
{
    NSString   *name=self.gameUser.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
        //  NSArray *sortedArray;
        /**sortedArray = [games sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
         NSNumber *first = [(Game*)a power];
         NSNumber *second = [(Game*)b power];
         return [first compare:second];
         }];**/
        
        float highestNumber=0;
        
        for (Game *game in games)
        {
            if ([game.power floatValue] > highestNumber) {
                highestNumber = [game.power floatValue];
            }
        }
        
        
        float value=highestNumber;
        [[GCDQueue mainQueue]queueBlock:^{
            [self.targetLabel setText:[NSString stringWithFormat:@"%0.0f",value]];
            
        }];
        
    }
    
}
-(IBAction)testButtonDown:(id)sender
{
    
    // [self midiNoteBeganForDuration:nil];
    // [self testContinueStart];
    //  [self startSession];
    [self addTestScores];
}
-(IBAction)testButtonUp:(id)sender

{
    // [self saveCurrentSession];
    // [self midiNoteStoppedForDuration:nil];
    // [self testContinueStop];
    
    
}

-(void)testContinueStop
{
    [testDurationDisplayLink invalidate];
    testDurationDisplayLink=nil;
    
}
-(void)testContinueStart
{
    //  [self stop];
    [self midiNoteBeganForPower:Nil];
    testDurationDisplayLink = [CADisplayLink displayLinkWithTarget:self
                                                          selector:@selector(animateForTestDuration)];
    [testDurationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}
-(void)animateForTestDuration
{
    //[self midiNoteContinuingForDuration:nil];
    [self midiNoteContinuingForPower:nil];
}

-(void) playSound {
    
    NSLog(@"Should be playing sound!!!!!");
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Crowd_cheer6" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        //[audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=1.0;
        [audioPlayer play];
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    @finally {
        
    }
    
    
    //[soundPath release];
    // NSLog(@"soundpath retain count: %d", [soundPath retainCount]);
}

/*
 @property(nonatomic,strong)NSNumber  *sessionStrength;
 @property(nonatomic,strong)NSNumber  *sessionDuration;
 @property(nonatomic,strong)NSNumber  *sessionSpeed;
 @property(nonatomic,strong)NSNumber  *sessionType;
 
 @property(nonatomic,strong)NSDate    *sessionDate;
 @property(nonatomic,strong)NSString  *username;
 */
-(void)addTestScores

{
    
    
    for (int i=0; i<30; i++) {
        
        Session  *sess=[[Session alloc]init];
        sess.sessionDuration=[NSNumber numberWithInt:50];
        sess.sessionSpeed=[NSNumber numberWithInt:10];
        sess.sessionType=[NSNumber numberWithInt:self.currentGameType];
        sess.username=self.gameUser.userName;
        
        
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:i+1];
        [comps setMonth:4];
        [comps setYear:2014];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *date = [gregorian dateFromComponents:comps];
        sess.sessionDate=date;
        
        AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:sess sharedPSC:self.sharedPSC];
        
        [self.addGameQueue addOperation:operation];
        
    }
}


//// SIMPLEIMAGE

-(void)background

{
    //self.btleMager.delegate=nil;
    // self.btleMager=nil;
    // [displayLink invalidate];
    // displayLink=nil;
}

-(void)foreground
{
    //  self.btleMager=[BTLEManager new];
    //  self.btleMager.delegate=self;
    //   [self.btleMager startWithDeviceName:@"GroovTube 2.0" andPollInterval:0.1];
    //[self.btleMager setTreshold:60];
    
}

-(IBAction)sliderchanged:(id)sender
{
    sketchamount=self.testSlider.value;
    
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
// self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//  if (self) {

// }
// return self;
//}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"PHOTO LIBRARY ACTION - imagePickerController");
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self setupDisplayFilteringWithImage:image];
    
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        // UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *webData = UIImagePNGRepresentation(image);
        [webData writeToFile:imagePath atomically:YES];
    }
    
    // [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}

- (IBAction)photoButtonLibraryAction:(id)sender
{
    NSLog(@"PHOTO LIBRARY ACTION");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popover presentPopoverFromRect:CGRectMake(0, 0, 500, 500) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //[self presentModalViewController:imagePickerController animated:YES];
    }
}

@synthesize midiexhale,midiinhale,velocity;
@synthesize midiIsOn;

-(void)setBTTreshold:(float)value
{
    [self.btleMager setTreshold:value];
    
     NSLog(@"inner setBTTreshold");
}
-(void)setBTBoost:(float)value
{
    [self.btleMager setRangeReduction:value];
    NSLog(@"inner setBTBoost");
}
-(void)setRate:(float)value
{
    NSLog(@"inner setRate");
    self.animationrate=value;
}

-(void)test:(float)value
{
    NSLog(@"inner TEST");
    self.animationrate=value;
}


-(void) appendToTextView: (NSString*) moreText {
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputtext.text = [NSString stringWithFormat:@"%@%@\n",
                            _outputtext.text, moreText];
        [_outputtext scrollRangeToVisible:NSMakeRange(_outputtext.text.length-1, 1)];
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!displayLink) {
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        animationRunning = YES;
        [displayLink setFrameInterval:8];
        //[self makeTimer];
        acceleration=0.1;
        distance=0;
        time=0;
        //      [self toggleDirection:nil];
        //      [self toggleDirection:nil];
    }
}


-(void)updateimage
{
    //  NSLog(@"UPDATE IMAGE");
    
    /***
     @"Bulge",@"Swirl",@"Blur",@"Vignette",@"Toon",
     @"Tone",@"Sketch",@"Polka",
     @"Posterize",@"Pixellate",@"Haze",@"Erosion"
     */
    // self.velocity+=1;
    
    float fVel= (float)self.velocity;
    // float rate = fVel/5;
    float rate = fVel;
    
    
    //NSLog(@"stillImageFilter %@",stillImageFilter);
    
    if (isaccelerating)
    {
        //    NSLog(@"isaccelerating == %hhd",isaccelerating);
        if (self.velocity>=threshold) {
            
            targetRadius=targetRadius+((rate/500)*_animationrate);
        }
        
    }else
    {
        //force-=force*0.03;
        // targetRadius=targetRadius-((35.0/500)*_animationrate);
        targetRadius=targetRadius-((40.0/500)*_animationrate);
    }
    
    // NSLog(@"targetRadius == %f",targetRadius);
    //if (inorout==midiinhale) {
    // }else
    // {
    // targetRadius=targetRadius-((rate/1000)*_animationrate);
    // }
    
    if (targetRadius<0.001) {
        targetRadius=0.001;
    }
    
    if (targetRadius>1) {
        targetRadius=1;
    }
    // NSLog(@"target radius %f",targetRadius);
    
    if ([stillImageFilter isKindOfClass:[GPUImageBulgeDistortionFilter class]])
        
    {
        if (targetRadius<0.001) {
            targetRadius=0.0;
        }
        [(GPUImageBulgeDistortionFilter*)stillImageFilter setRadius:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageSwirlFilter class]])
    {
        [(GPUImageSwirlFilter*)stillImageFilter setRadius:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageZoomBlurFilter class]])
    {
        [(GPUImageZoomBlurFilter*)stillImageFilter setBlurSize:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageVignetteFilter class]])
    {
        [(GPUImageVignetteFilter*)stillImageFilter setVignetteStart:1-targetRadius];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageToonFilter class]])
    {
        [(GPUImageToonFilter*)stillImageFilter setThreshold:1-(targetRadius-0.1)];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageExposureFilter class]])
    {
        [(GPUImageExposureFilter*)stillImageFilter setExposure:targetRadius+0.1];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePolkaDotFilter class]])
    {
        //[(GPUImagePolkaDotFilter*)stillImageFilter setDotScaling:targetRadius];
        [(GPUImagePolkaDotFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePosterizeFilter class]])
    {
        [(GPUImagePosterizeFilter*)stillImageFilter setColorLevels:11-(10*targetRadius)];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePixellateFilter class]])
    {
        [(GPUImagePixellateFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageContrastFilter class]])
    {
        [(GPUImageContrastFilter*)stillImageFilter setContrast:1-targetRadius];
        
        //[(GPUImageThresholdSketchFilter*)stillImageFilter setSlope:targetRadius/3];
    }
    
    //NSLog(@"value == %f",targetRadius);
    
    [sourcePicture processImage];
    
    /**
     self.topFocusLevel = 0.4;
     self.bottomFocusLevel = 0.6;
     self.focusFallOffRate = 0.2;
     self.blurSize = 2.0;*/
}

-(void)setupDisplayFilteringWithImage:(UIImage*)aImage
{
    NSLog(@"SETUP DISPLAY WITH NEW IMAGE");
    //cleanup
    [sourcePicture removeAllTargets];
    //[stillImageFilter destroyFilterFBO];
    //[stillImageFilter releaseInputTexturesIfNeeded];
    stillImageFilter=nil;
    [imageView removeFromSuperview];
    imageView=nil;
    // imageView = [[GPUImageView alloc]initWithFrame:self.view.frame]
    
    //maybe0th 
   // stillImageFilter=[self filterForIndex:0];
   // [sourcePicture addTarget:stillImageFilter];
   // [stillImageFilter addTarget:imageView];
    
    //image set
    //dispatch_async(dispatch_get_main_queue(), ^{
    sourcePicture = [[GPUImagePicture alloc] initWithImage:aImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:0];
    //imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    // [self.view addSubview:imageView];
    //[self.view insertSubview:imageView atIndex:0];
    
    imageView = [[GPUImageView alloc]initWithFrame:self.imageFilterView.frame];
    //[self.view insertSubview:imageView atIndex:0];
    [self.imageFilterView insertSubview:imageView atIndex:0];
    
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    [sourcePicture processImage];
    
    // });
    // [self start];
}
- (void)setupDisplayFiltering;
{
    
    NSLog(@"SET UP DISPLAY FILTERING");
    UIImage *inputImage;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    NSData  *data=[NSData dataWithContentsOfFile:imagePath];
    
    //inputImage=[UIImage imageWithData:data];
    //if (!inputImage) {
    inputImage=[UIImage imageNamed:@"giraffe-614141_1280.jpg"];
    // }
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:0];
    //imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    //[self.view addSubview:imageView];
    //change [self.view insertSubview:imageView atIndex:0];
    
    imageView = [[GPUImageView alloc]initWithFrame:self.imageFilterView.frame];
    //[self.view insertSubview:imageView atIndex:0];
    [self.imageFilterView insertSubview:imageView atIndex:0];
    
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    
    [sourcePicture processImage];
}

-(void)setFilter:(int)index
{
    NSLog(@"inner set filter");
    
    [sourcePicture removeAllTargets];
    //[stillImageFilter destroyFilterFBO];
    //[stillImageFilter releaseInputTexturesIfNeeded];
    stillImageFilter=nil;
    [imageView removeFromSuperview];
    imageView=nil;
    imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    // [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:0];
    stillImageFilter=[self filterForIndex:index];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
}


-(GPUImageFilter*)filterForIndex:(int)index
{
    GPUImageFilter *filter;
    
    switch (index) {
        case 0:
            filter=[[GPUImageBulgeDistortionFilter alloc] init];
            break;
        case 1:
            filter=[[GPUImageSwirlFilter alloc] init];
            break;
        case 2:
            filter=[[GPUImageZoomBlurFilter alloc] init];
            break;
        case 3:
            filter=[[GPUImageToonFilter alloc] init];
            break;
        case 4:
            filter=[[GPUImageExposureFilter alloc] init];
            break;
        case 5:
            filter=[[GPUImagePolkaDotFilter alloc] init];
            break;
        case 6:
            filter=[[GPUImagePosterizeFilter alloc] init];
            break;
        case 7:
            filter=[[GPUImagePixellateFilter alloc] init];
            break;
        case 8:
            filter=[[GPUImageContrastFilter alloc] init];
            break;
        default:
            break;
    }
    return filter;
}


-(void)addText:(NSString*)str
{
    NSString  *newstring=[NSString stringWithFormat:@"%@\n%@",_textarea.text,str];
    [_textarea setText:newstring];
}

-(void)animate
{
    self.velocity+=0.1;
    if (self.velocity<threshold) {
        return;
    }
    
    float fVel= (float)self.velocity;
    float rate = fVel/10;
    
    if (inorout==midiinhale) {
        targetRadius=targetRadius+((45.0/100)*_animationrate);
    }else
    {
        targetRadius=targetRadius-((45.0/100)*_animationrate);
    }
    
    if (targetRadius<0.01) {
        targetRadius=0.01;
    }
    
    if (targetRadius>1) {
        targetRadius=1;
    }
}

-(void)start
{
    //  [self stop];
    //[self setDefaults];
    // if (!animationRunning)
    // {
    displayLink = [CADisplayLink displayLinkWithTarget:self
                                              selector:@selector(animate)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    animationRunning = YES;
    //}
}




@end
