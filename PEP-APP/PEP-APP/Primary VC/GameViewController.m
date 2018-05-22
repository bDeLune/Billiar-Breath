///What constitutes game ended for image game
//"as user complete repitions, more balloons show, up to value in settings" - is this normal bb behaviour
// Do we save after each attempt at balloon game?


#import "GameViewController.h"
#import "User.h"
#import "BilliardBallViewController.h"
#import "BilliardBall.h"
#import "Session.h"
#import "SequenceGame.h"
//#import "PowerGame.h"
//#import "DurationGame.h"
#import "AbstractGame.h"    //change
#import "Game.h"
#import "AddNewScoreOperation.h"
#import "UIEffectDesignerView.h"
#import "GCDQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "BTLEManager.h"
#import "UserListViewController.h"
#import "infoViewController.h"
#import "Gauge.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Gauge.h"
//#import "ScoreDisplayViewController.h"
#import "Session.h"
#import "UIEffectDesignerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Draggable.h"

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
    BOOL globalSoundActivated;
    UINavigationController   *navcontroller;
  //  LoginViewViewController   *loginViewController;
  //  HighScoreViewController   *highScoreViewController;
    //Gauge    *gaugeView;
    MidiController  *midiController;
   /// ScoreDisplayViewController  *scoreViewController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    Session  *currentSession;
    NSTimer  *effecttimer;
    UIImageView  *bellImageView;
    UIImageView  *bg;
    Draggable  *peakholdImageView;
    int midiinhale;
    int midiexhale;
    int currentdirection;
    NSNumber* currentBreathLength;
    bool currentlyExhaling;
    bool currentlyInhaling;
    NSString* currentImageGameSound;
    int selectedBallCount;
}

@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic, retain) NSMutableArray *capturedImages;
@property(nonatomic,strong)Gauge  *gaugeView;
@property(nonatomic,strong)BTLEManager  *btleMager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSOperationQueue  *addGameQueue;
@property(nonatomic,strong)BilliardBallViewController  *billiardViewController;
@property(nonatomic,strong)MidiController  *midiController;
@property(nonatomic)gameType  currentGameType;
@property(nonatomic,strong)Session  *currentSession;
@property(nonatomic,strong)SequenceGame  *sequenceGameController;
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
       // [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-ON"]];
    });
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
    });
}

#pragma mark -
#pragma mark - Session

-(void)startSession
{   //ADDED CHECK
    NSLog(@"START Session");
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
    self.currentSession.sessionRequiredBreathLength = [NSNumber numberWithInt:4];
    self.currentSession.sessionAchievedBreathLength = 0;
    self.currentSession.sessionRequiredBalloons = [NSNumber numberWithInt:selectedBallCount];
    self.currentSession.sessionAchievedBalloons = 0;
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
        //self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 160, 450, 225)];
        selectedBallCount = 3;
        //self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 160, 450, 225) withBallCount:selectedBallCount];
        self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(45, 100, 650,325) withBallCount:selectedBallCount];
        

        
       // -(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount{
       // self.billiardViewController=[[BilliardBallViewController alloc]initWithFrame:CGRectMake(25, 260, 650, 325)];
        self.midiController=[[MidiController alloc]init];
        self.midiController.delegate=self;
        [self.midiController addObserver:self forKeyPath:@"numberOfSources" options:0 context:NULL];
        // [self.midiController setup];
        self.currentGameType=gameTypeBalloon;
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
        
        
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
    
        //change add in storyboard0
       // self.btOnOfImageView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-230, 30, 100, 100)];
        //[self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
       // [self.view addSubview:self.btOnOfImageView];
        
        ///image
        sketchamount=0;
        self.title = @"Groov";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        _animationrate=1;
        picselect=[UIButton buttonWithType:UIButtonTypeCustom];
        //picselect.frame=CGRectMake(0, self.view.frame.size.height-120, 108, 58);
        
        picselect.frame=CGRectMake(0, self.view.frame.size.height-120, 108, 58);
        [picselect addTarget:self action:@selector(photoButtonLibraryAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:picselect];
        [picselect setBackgroundImage:[UIImage imageNamed:@"PickPhotoButton.png"] forState:UIControlStateNormal];
        self.capturedImages = [NSMutableArray array];
    
        imagePickerController = [[UIImagePickerController alloc] init] ;
        imagePickerController.delegate = self;
        currentImageGameSound = @"bell";
        
        self.gaugeView=[[Gauge alloc]initWithFrame:CGRectMake(670, 365, 40, GUAGE_HEIGHT)];
        self.gaugeView.gaugedelegate=self;
        
        [self.view addSubview:self.gaugeView];
        
        [self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
        [self.gaugeView start];
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
    self.breathGauge.progress = 0;
}


-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    wasExhaling = false;
    //addedgauge
     [self.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];

    if (self.midiController.toggleIsON==NO) {
        NSLog(@"INHALING AND RETURNING");
        return;
    }
    self.breathGauge.progress = percentOfmax;
    //currentdirection=midiinhale;
    //self.velocity=(percentOfmax/10.0)*127.0;
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    //  NSLog(@"inhaleWithValue %f",percentOfmax);
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
    //addedgaugeview
   float scale=50.0f;
   float value=self.velocity*scale;
   [self.gaugeView setForce:(value)];
    
    [self midiNoteContinuing: self.midiController];
}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    wasExhaling = true;

    if (self.midiController.toggleIsON==YES) {
        NSLog(@"EXHALING AND RETURNING");
        return;
    }
    
    self.breathGauge.progress = percentOfmax;
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
    [self midiNoteContinuing: self.midiController];
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    
    float scale=50.0f;
    float value=self.velocity*scale;
    [self.gaugeView setForce:(value)];
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
- (IBAction)imagePickerPressed:(id)sender {
    
    NSLog(@"image picker pressed");
    
    
}

- (IBAction)contrastPickerPressed:(id)sender {
    NSLog(@"contrastPickerPressed pressed");
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.billiardViewController.view];
    [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];
    self.userList=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    self.userList.sharedPSC=self.sharedPSC;
    self.navcontroller=[[UINavigationController alloc]initWithRootViewController:self.userList];
    
    self.currentGameType = gameTypeBalloon;
    
    CGRect frame = self.view.frame;
    [self.navcontroller.view setFrame:frame];
    self.breathGauge.progress = 0;
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

- (IBAction)goToInfoView:(id)sender {
    
    NSLog(@"Going to info view");
    
    infoViewController *infoVC = [[infoViewController alloc]initWithNibName:@"infoViewController" bundle:nil];
    
    if (infoVC){
        NSLog(@"instantiating infoVC");
        [self presentViewController:infoVC animated:YES completion:nil];
    }else{
        NSLog(@"Cant instantiate infoVC");
    }
}


- (IBAction)toUsersScreen:(id)sender {
    
    NSLog(@"Moving to users screen");
    self.userList.sharedPSC=self.sharedPSC ;
    [self.userList getListOfUsers];
    [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        
        self.userList.sharedPSC=self.sharedPSC;
        self.userList.delegate=self;
        
    }];

}

-(IBAction)exitGameScreen:(id)sender
{
    [self.delegate gameViewExitGame];
}

- (IBAction)goToSettings:(id)sender {
    
    NSLog(@"Go to settings");
    
    self.currentGameType= gameTypeTest;     //change: check if correct
    [self.delegate toSettingsScreen];
}

-(IBAction)toggleDirection:(id)sender
{
    
    NSLog(@"toggling direction");
    switch (self.midiController.toggleIsON) {
        case 0:
            self.midiController.toggleIsON=YES;
            //  midiController.currentdirection=midiinhale;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];    // Do any additional setup after loading the view from its nib.
            wasExhaling = false;
            break;
        case 1:
            self.midiController.toggleIsON=NO;
            
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
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
    NSLog(@"Toggling game mode");
    int mode=self.currentGameType;
    
    mode++;
    
    if (mode>2) {   //check if correct
        mode=gameTypeBalloon;
    }
    
    self.currentGameType=mode;
    self.billiardViewController.currentGameType = self.currentGameType;
    
    NSLog(@"Current game mode %u", self.currentGameType);
    
    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    
    [self resetGame:nil];
}

-(NSString*)stringForMode:(int)mode
{
    NSString  *modeString;
    
    NSLog(@"changing mode %d", mode);
    
    //change add new images
    switch (mode) {
        case gameTypeDuo:
           // modeString=@"ModeButtonDuo";
           // modeString=@"ModeButtonSEQUENCE";
            NSLog(@"changing mode BALLOON");
            modeString=@"MainMode-BALLOON";
            break;
            
        case gameTypeImage:
           // modeString=@"ModeButtonImage";
            // modeString=@"ModeButtonSEQUENCE";
            NSLog(@"changing mode gameTypeImage");
            modeString=@"MainMode-IMAGE";
            break;
            
        case gameTypeBalloon:
           // modeString=@"ModeButtonBalloon";
            // modeString=@"ModeButtonSEQUENCE";
            NSLog(@"changing mode gameTypeBalloon");
            modeString=@"MainMode-BOTH";
            break;
        case gameTypeTest:
           // modeString=@"ModeButtonTest";
             NSLog(@"changing mode gameTypeTest");
             modeString=@"MainMode-BALLOON";
            break;
            
        default:
            break;
    }
    return modeString;
}

-(IBAction)presentSettings:(id)sender
{   //REMOVE
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
    NSLog(@"RESETTING GAME with ballcount %d", selectedBallCount);
  //  if (gameTypeTest){

   // self.sequenceGameController= [SequenceGame new];
    //self.sequenceGameController= [[SequenceGame alloc] init];
    self.sequenceGameController= [[SequenceGame alloc] initWithBallCount:selectedBallCount ];
   // [self.sequenceGameController setBallCount: 3];
   // self.sequenceGameController.totalBalls=3;
        self.sequenceGameController.delegate=self;
 //   }else{}

   // self.powerGameController=[PowerGame new];
   // self.powerGameController.delegate=self;
   // self.durationGameController=[DurationGame new];
   // self.durationGameController.delegate=self;
    
    //Check - need test game, remove other games, set up all games here
   // self.durationGameController=[Testgame new];
    ///self.durationGameController.delegate=self;
    //[self setThreshold:0];
    
   //eir [self.billiardViewController reset];
    [self.billiardViewController resetwithBallCount:selectedBallCount];
    
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
            case gameTypeDuo:
             //   self.durationGameController.isRunning=YES;
                [self midiNoteBeganForSequence:midi];
                self.billiardViewController.currentGameType=gameTypeDuo;
               /// [self midiNoteBeganForDuration:midi];
                break;
            case gameTypeImage:
               // [self midiNoteBeganForPower:midi];
                [self playImageGameSound];
                self.billiardViewController.currentGameType=gameTypeImage;
                break;
            case gameTypeBalloon:
                [self midiNoteBeganForSequence:midi];
                self.billiardViewController.currentGameType=gameTypeBalloon;
                break;
            case gameTypeTest:
                [self midiNoteBeganForSequence:midi];
                self.billiardViewController.currentGameType=gameTypeTest;
                break;
            default:
                break;
        }
    }
    
    //added gauge
    if (self.gaugeView.animationRunning) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //   [_debugTextField setText:@"\nMidi Began"];
        });
        //        [self beginNewSession];
        [self.gaugeView blowingBegan];
    }
}

-(void)midiNoteStopped:(MidiController*)midi
{
    // NSLog(@"Midi Stopped\n");
    
    if ((self.midiController.toggleIsON == false && wasExhaling == true) || (self.midiController.toggleIsON == true && wasExhaling == false)){
        // NSLog(@"MIDI NOTES STOPPED HERE");
        switch (self.currentGameType) {
            case gameTypeDuo:
             //   self.durationGameController.isRunning=NO;
                [self midiNoteStoppedForSequence:midi];
                break;
            case gameTypeImage:
                [self midiNoteStoppedForSequence:midi];
                break;
            case gameTypeBalloon:
                [self midiNoteStoppedForSequence:midi];
                break;
            case gameTypeTest:
                [self midiNoteStoppedForSequence:midi];
                break;
            default:
                break;
        }
    }
    
    //added gauge
  //  if (self.gaugeView.animationRunning) {
  //      [self sendLogToOutput:@"\nMidi Stop"];
        [self.gaugeView blowingEnded];
       // [self endCurrentSession];
  //  }
}

-(void)midiNoteContinuing:(MidiController*)midi
{
    
    if (midi.velocity==127) {
        return;
    }
    
    //added gauge
   // float scale=50.0f;
  //  float value=midi.velocity*scale;
  //  [self.gaugeView setForce:(value)];
    
    
    /// NSLog(@"Midi Continue\n");
    if (midi.velocity>[self.currentSession.sessionStrength floatValue]) {
        
        if (midi.velocity!=127) {
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:midi.velocity];
            
        }
        // [gaugeView setArrowPos:0];
    }
    
    if(self.currentGameType==gameTypeDuo)
    {
       // if (self.durationGameController.isRunning) {
       //     self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];
            
      //  }
    }else if(self.currentGameType==gameTypeTest)
    {
   //     self.currentSession.sessionDuration=[NSNumber numberWithDouble:self.sequenceGameController.time];
        
    }
    self.currentSession.sessionSpeed=[NSNumber numberWithFloat:midi.speed];
    
    //check
    self.currentSession.sessionDuration = currentBreathLength;
    
    NSString *durationtext=[NSString stringWithFormat:@"%0.1f",self.sequenceGameController.time];
    
    [[GCDQueue mainQueue]queueBlock:^{
        if (midi.velocity!=127) {
            
        }
        // if (midi.speed!=0) {
        //  [self.speedLabel setText:[NSString stringWithFormat:@"%0.0f",midi.speed]];
    }];
    
    [[GCDQueue mainQueue]queueBlock:^{
        switch (self.currentGameType) {
            case gameTypeDuo:
               // [self midiNoteContinuingForPower:midi]; //MAYBE
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
                [self midiNoteContinuingForSequence:midi];
                break;
            case gameTypeImage:
               // [self midiNoteContinuingForPower:midi]; //MAYBE
             //   [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
             //   [self midiNoteContinuingForSequence:midi];
                break;
            case gameTypeBalloon:
               // [self midiNoteContinuingForPower:midi]; //MAYBE
                [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
                [self midiNoteContinuingForSequence:midi];
                break;
            case gameTypeTest:
              //  [self midiNoteContinuingForPower:midi]; //MAYBE
            //    [self.strenghtLabel setText:[NSString stringWithFormat:@"%0.0f",midi.velocity]];
            //    [self midiNoteContinuingForSequence:midi];
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
    NSLog(@"midiNoteStoppedForSequence");
    
    //CHANGE
    if (self.currentGameType == gameTypeImage) {
        [self imageGameWon];
    }
    
    [self.sequenceGameController nextBall];
    //Maybe change - check if this is in corrent location
    self.currentSession.sessionAchievedBalloons = [NSNumber numberWithInt: self.sequenceGameController.currentBall];
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
}

//#pragma - Duration
////-(void)midiNoteBeganForDuration:(MidiController *)midi
///{
    ///  NSLog(@"MIDI NOTES midiNoteBeganForDuration");
    //self.billiardViewController.durationGame=self.durationGameController;
   // [self.billiardViewController startDurationPowerGame];
    
//}
//-(void)midiNoteStoppedForDuration:(MidiController *)midi
//{
    ///NSLog(@"MIDI NOTES midiNoteStoppedForDuration");
  //  [[GCDQueue mainQueue]queueBlock:^{
   //     [self.billiardViewController endDurationPowerGame];
   //     [self resetGame:nil];
  //  }];
  //  [self saveCurrentSession];
//}


//-(void)midiNoteContinuingForDuration:(MidiController*)midi
//{
  //  [[GCDQueue mainQueue]queueBlock:^{
 ///       [self.durationGameController pushBall];
 //   }];
//}

//#pragma - Power

//-(void)midiNoteBeganForPower:(MidiController *)midi
//{
    ///   NSLog(@"MIDI NOTES BEGAN FOR POWER");
  //'/  self.billiardViewController.powerGame=self.powerGameController;
  ///  [self.billiardViewController startBallsPowerGame];
//}


//-(void)midiNoteStoppedForPower:(MidiController *)midi
//{
  ///  if ((self.midiController.toggleIsON == false && wasExhaling == true) || (self.midiController.toggleIsON == true && wasExhaling == false)){
        
 //       NSLog(@"MIDI NOTES STOPPED FOR POWER");
    
///       [[GCDQueue mainQueue]queueBlock:^{
 ///           [self.billiardViewController endBallsPowerGame];
            
            ///  [self saveCurrentSession];
 //           [self resetGame:nil];
 ///       }];
        
        /// [self saveCurrentSession];
//    }else{
 ///       NSLog(@"MIDI NOTE DISALLOWED - B");
//    }
//}

- (IBAction)toggleMuteSound:(id)sender {
    
    NSLog(@"toggle sound");
    if (globalSoundActivated == 1){
        NSLog(@"muting sound");
        globalSoundActivated = 0;
        UIImage *soundOnImage = [UIImage imageNamed:@"Sound-ON.png"];
         [self.soundIcon setImage:soundOnImage forState:UIControlStateNormal];
        //   [self.billiardViewController setAudioMute: globalSoundActivated];     //change: make available
        [self.sequenceGameController setAudioMute: globalSoundActivated];
    }else if(globalSoundActivated == 0){
        NSLog(@"unmuting sound");
        globalSoundActivated = 1;
        UIImage *soundOffImage = [UIImage imageNamed:@"Sound-OFF.png"];
        [self.soundIcon setImage:soundOffImage forState:UIControlStateNormal];
        //[self.soundIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
    //    [self.billiardViewController setAudioMute: globalSoundActivated];
        [self.sequenceGameController setAudioMute: globalSoundActivated];
    }
}

-(void)sendLogToOutput:(NSString*)log
{
    [[GCDQueue  mainQueue]queueBlock:^{
        [self.debugtext setText:log];
    }];
}

-(void)setThreshold:(int)pvalue
{
    
    NSLog(@"game view controller: set threshold");
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
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)gameEnded:(AbstractGame *)game
{
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

//-(void)gameWonDuration
//{
    
  //  if (particleEffect) {
  ///      return;
 //   }
    
    // self.durationGameController.isRunning=NO;
  //  [[GCDQueue mainQueue]queueBlock:^{
  //      [self playSound];
  //      [self startEffects];
        /// [self resetGame:nil];
 //   }];
    // UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"billiardwin.ped"];
    // [self.view addSubview:effectView];
    // if (game.saveable) {
    //[self saveCurrentSession];
    // }
  //  [self.sequenceGameController killTimer];
//}

-(void)imageGameWon
{
    [[GCDQueue mainQueue]queueBlock:^{
         NSLog(@"IMAGE GAME WON");
        [self saveCurrentSession];  //added kung
    }];
}

-(void)gameWon:(AbstractGame *)game
{
    NSLog(@"GAME WON");
   //if (self.currentGameType==gameTypeDuo) {
   ///[self gameWonDuration];
   // return;
   //}
    
    if (particleEffect) {
        return;
    }

    [[GCDQueue mainQueue]queueBlock:^{
        [self playSound];
        [self startEffects];
        [self resetGame:nil];
    }];
    
   /// if (self.currentGameType == gameTypeImage) {
   //     [[GCDQueue mainQueue]queueBlock:^{
   //         NSLog(@"IMAGE GAME WON");
   //         [self saveCurrentSession];  //added kung
   //     }];
   //     return;
    //}else
    if (self.currentGameType == gameTypeDuo) {
        [[GCDQueue mainQueue]queueBlock:^{
             NSLog(@"DUO GAME WON");
            [self saveCurrentSession];  //added kung
        }];
        return;
    }
    else if (self.currentGameType == gameTypeBalloon) {
        [[GCDQueue mainQueue]queueBlock:^{
             NSLog(@"Balloon GAME WON");
            [self saveCurrentSession];  //added kung
        }];
        return;
    }
    
    if (game.saveable) {
        ///
    }
    
    [self.sequenceGameController killTimer];
}

//PROBLEM: CURRENTLY BALLOON SAVES FOR WON BALLOON GAMES. NEEDS TO SAVE FOR ALL ATTEMPTS.


-(void)startEffects
{
    //change replace with bursting effect
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
    //kill bursting effect
    dispatch_async(dispatch_get_main_queue(), ^{
        [particleEffect removeFromSuperview];
        particleEffect=nil;
        [effectTimer invalidate];
        effectTimer=nil;
        
    });
}

-(void)saveCurrentSession
{
    NSLog(@"ATTEMPTING TO Save Current Session: %u", self.currentGameType);
    
    self.currentSession.sessionType=[NSNumber numberWithInt:self.currentGameType];
    self.currentSession.sessionRequiredBalloons = [NSNumber numberWithInt:selectedBallCount];
    
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    
    NSLog(@"SAVING CURRENT SESSION");
    [self.addGameQueue addOperation:operation];
    [self startSession];
}

-(void)setTargetScore
{   //REMOVE
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

//-(void)testContinueStop
//{
//    [testDurationDisplayLink invalidate];
//    testDurationDisplayLink=nil;
//
//}
//-(void)testContinueStart
//{
    //  [self stop];
//    [self midiNoteBeganForPower:Nil];
//    testDurationDisplayLink = [CADisplayLink displayLinkWithTarget:self
  //                                                        selector:@selector(animateForTestDuration)];
//    [testDurationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
//}

//-(void)animateForTestDuration
//{
    //[self midiNoteContinuingForDuration:nil];
//    [self midiNoteContinuingForPower:nil];
//}

-(void) playSound {
    
    NSLog(@"Should be playing bursting sound!!!!!");
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Crowd_cheer6" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        //[audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=1.0;
        
        NSLog(@"SOUND: reset all2 %hhd", globalSoundActivated);
        
        if (globalSoundActivated == 1){
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
    
    
    //[soundPath release];
    // NSLog(@"soundpath retain count: %d", [soundPath retainCount]);
}

-(void)addTestScores
{   //POSSIBLY REMOVE
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
    //CHECK TEMP
    currentBreathLength = [NSNumber numberWithFloat: value];
    
    
    NSLog(@"inner setBTBoost to %f",value );
}

-(void)setBreathLength:(float)value
{
    NSLog(@" (animation) inner set breath length %f", value);
   // self.breathLength=value;
    self.currentSession.sessionRequiredBreathLength = [NSNumber numberWithFloat:value];
    _animationrate=value;
}

-(void)setRate:(float)value
{
    NSLog(@"OFF inner setRate");
    //self.animationrate=value;
}

-(void)test:(float)value
{
    NSLog(@"OFF inner TEST");
  //  self.animationrate=value;
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
    NSLog(@"view did appear!: animatedd");
    
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
    //NSLog(@"UPDATE IMAGE");
   // NSLog(@"self.currentGameType %u" , self.currentGameType);
    
  if (self.currentGameType == gameTypeTest) {
   //   NSLog(@"Image filter not allowed in test mode! ");
      return;
  }else if (self.currentGameType == gameTypeBalloon){
    //   NSLog(@"Image filter not allowed in balloon mode! ");
      return;
  }
    
    //change: is this the best place to do this?
    
    
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
   // _animationrate = 6 - _animationrate;
    
    //NSLog(@"ESTIMATED TIME OF ANIMATION %f", 10 - _animationrate);
   // NSLog(@"FL Velocity %f", fVel);
    
   // NSLog(@"OUTPUT %f",targetRadius+((rate/500)*_animationrate));
   // NSLog(@"_animationrate %f",_animationrate);
   // NSLog(@"TARGETRADIUS  - %f",targetRadius);
   // NSLog(@"rate/500 -  %f",rate/500);
    //NSLog(@"((rate/500)*_animationrate) -  %f",((rate/500)*_animationrate));
    
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
    
    //check change
    self.imageFilterView.layer.zPosition = 5;
    imageView.layer.zPosition = 5;
    
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

-(void)setRepetitionCount:(int)value{
    
    NSLog(@"Setting balloon game repetition count to %d ", value);
    NSLog(@"count %d ", value);
    
    //chang: consolodate variables
    selectedBallCount = value;
    //self.session.sessionRequiredBalloons = value;
    
}


-(void)setImageSoundEffect:(NSString*)value{
    NSLog(@"Setting Image sound effect to %@ ", value);
    
    currentImageGameSound = value;
    
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


-(void) playImageGameSound {
    
    NSLog(@"Playing image game sound %@", currentImageGameSound);
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: currentImageGameSound ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

-(void)start
{
    //  [self stop];
    //[self setDefaults];
    // if (!animationRunning)
    // {
    NSLog(@"Starting mage game");
    [self playImageGameSound];
    displayLink = [CADisplayLink displayLinkWithTarget:self
                                              selector:@selector(animate)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    animationRunning = YES;
    //}
}

///GAUGE STUFF

-(void)setResitance:(int)pvalue
{
    NSLog(@"Setting setResitance to %d", pvalue);
    
    switch (pvalue) {
        case 0:
            [self.gaugeView setMass:1];
            break;
        case 1:
            [self.gaugeView setMass:2];
            break;
        case 2:
            [self.gaugeView setMass:2.5];
            break;
        case 3:
            [self.gaugeView setMass:3];
            break;
        default:
            break;
    }
}

@end
