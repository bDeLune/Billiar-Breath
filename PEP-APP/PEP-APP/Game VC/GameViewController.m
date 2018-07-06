#import "GameViewController.h"
#import "BalloonViewController.h"
#import "SettingsViewController.h"
#import "User.h"
#import "Balloon.h"
#import "Session.h"
#import "SequenceGame.h"
#import "AbstractGame.h"
#import "Game.h"
#import "AddNewScoreOperation.h"
#import "GCDQueue.h"
#import "BTLEManager.h"
#import "UserListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface GameViewController ()<BTLEManagerDelegate, UITabBarDelegate,UITabBarControllerDelegate, SETTINGS_DELEGATE>
{
    int threshold;
    CADisplayLink *testDurationDisplayLink;
    gameDifficulty  currentDifficulty;
    AVAudioPlayer  *audioPlayer;
    NSTimer  *effectTimer;
    bool wasExhaling;
    float bestCurrentVelocity;
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
    UIPopoverController *popover;
    UIImagePickerController *imagePickerController;
    UIImagePickerController *hqImagePickerController;
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
    MidiController  *midiController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    Session  *currentSession;
    NSTimer  *effecttimer;
    //UIImageView  *bellImageView;
    UIImageView  *bg;
    int midiinhale;
    int midiexhale;
    int currentdirection;
    NSNumber* currentBreathLength;
    bool currentlyExhaling;
    bool currentlyInhaling;
    NSString* currentImageGameSound;
    int currentlySelectedEffectIndex;
    int selectedBallCount;
    int selectedSpeed;
    bool disableModeButton;
}

@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic, retain) NSMutableArray *capturedImages;
@property (nonatomic, retain) NSMutableArray *hqImages;
@property (weak, nonatomic) IBOutlet UIImageView *MainGaugeWindow;
@property (nonatomic,strong) GameViewGauge  *mainGaugeView;
@property (nonatomic,strong) SettingsViewGauge  *gaugeView;
@property (nonatomic,strong) BTLEManager  *btleMager;
@property (nonatomic,strong) UIView  *hqPickerContainer;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong)NSOperationQueue  *addGameQueue;
@property (nonatomic,strong) BalloonViewController  *balloonViewController;
@property (nonatomic,strong) MidiController  *midiController;
@property (nonatomic) gameType  currentGameType;
@property (nonatomic,strong) Session  *currentSession;
@property (nonatomic,strong) SequenceGame  *sequenceGameController;
@property (nonatomic,strong) BTLEManager  *btleManager;
@property (nonatomic,strong) UIImageView  *btOnOfImageView;
@property (nonatomic,strong) UserListViewController  *userList;
@property (weak, nonatomic) IBOutlet UIImageView *imageFilterView;
@property (weak, nonatomic) IBOutlet UIImageView *balloonView;
@property (nonatomic,strong) UINavigationController *navcontroller;
@end

@implementation GameViewController
@synthesize chosenImageView, chosenImageController;
#define THUMBNAIL_SIZE 30
#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 400

-(void)userListDismissRequest:(UserListViewController *)caller
{
    [[GCDQueue mainQueue]queueBlock:^{
        [UIView transitionFromView:self.navcontroller.view toView:self.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
            self.userList.sharedPSC=self.sharedPSC;
            self.userList.delegate=self;
        }];
    }];
}

-(void)btleManagerConnected:(BTLEManager *)manager
{
    NSLog(@"BLUETOOTH IS ON");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-ON"]];
    });
}

-(void)btleManagerDisconnected:(BTLEManager *)manager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
    });
}

#pragma mark -
#pragma mark - Session

-(void)startSession
{
   //NSLog(@"START Session");
    self.currentSession=[Session new];
    self.currentSession.sessionDate=[NSDate date];
    self.currentSession.sessionSpeed = [NSNumber numberWithInt:selectedSpeed];
    self.currentSession.sessionDuration = [NSString stringWithFormat:@"%d", 0];
    ///usersettings
    //self.currentSession.sessionAchievedBreathLength = 0;
    //self.currentSession.sessionRequiredBalloons = [NSNumber numberWithInt:selectedBallCount];
    //self.currentSession.sessionAchievedBalloons = 0;
}

#pragma mark -
#pragma mark - KVO
// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.midiController && [keyPath isEqualToString:@"numberOfSources"]) {
        
        if (self.midiController.numberOfSources == 0) {
    ///        NSLog(@"No Midi Sources!!!");
            UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Midi Message" message:@"No Midi Device Detected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [[GCDQueue mainQueue]queueBlock:^{
                [alert show];
            }];
        }else
        {
    //        NSLog(@" Midi Sources Detected!!!");
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

        self.settingsViewController = [self.tabBarController.viewControllers objectAtIndex:2];
        selectedBallCount = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultRepetitionIndex"];
        //int TEST  = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultRepetitionIndex"];
        selectedSpeed = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultSpeed"];
        currentImageGameSound = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultSound"];
        globalSoundActivated = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultMute"];
        NSString* directionSetting = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultDirection"];
        currentlySelectedEffectIndex= [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultEffect"];
        
        NSLog(@"GV LOADED DEFAULTS directionSetting %@", directionSetting);
        NSLog(@"GV LOADED DEFAULTS selectedBallCount %d", selectedBallCount);
        NSLog(@"GV LOADED DEFAULTS currentImageGameSound %@", currentImageGameSound);
        NSLog(@"GV LOADED DEFAULTS selectedSpeed %d", selectedSpeed);
        NSLog(@"GV LOADED DEFAULTS globalSoundActivated %hhd", globalSoundActivated);
        NSLog(@"GV LOADED DEFAULTS currentlySelectedEffectIndex %d", currentlySelectedEffectIndex);
        
        if (selectedBallCount == NULL){selectedBallCount = 15;}else{[self.settingsViewController setUIState:3 toNo:selectedBallCount];};
        if (selectedSpeed == NULL){selectedSpeed = 3;}
        if (currentImageGameSound  == NULL){currentImageGameSound = @"sirene fluit";}else{[self.settingsViewController setUIState:2 toNo:[currentImageGameSound intValue]];};
        if (globalSoundActivated == NULL){globalSoundActivated = 1;}
        if (currentlySelectedEffectIndex  == NULL){currentlySelectedEffectIndex = 1;}else{[self.settingsViewController setUIState:1  toNo:currentlySelectedEffectIndex];};
        if ([directionSetting isEqual: @"Inhale"]){
            self.midiController.toggleIsON = YES;
            [self.settingsViewController setSettingsViewDirection: 0];
             NSLog(@"GV SET DEFAULTS directionSetting inhale");
            wasExhaling = false;
            [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
            [self.settingsViewController setGaugeSettings:0 exhaleToggle: YES];
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        }else if (directionSetting == NULL || [directionSetting isEqual: @"Exhale"]){
            self.midiController.toggleIsON = NO;
            [self.settingsViewController setSettingsViewDirection: 1];
             NSLog(@"GV SET DEFAULTS directionSetting Exhale");
            [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            //settings vie gaug
             [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
            [self.settingsViewController setGaugeSettings:1 exhaleToggle: NO];
            // [self.settingsViewController.gaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            wasExhaling = true;
        }
        
        NSLog(@"GV SET DEFAULTS selectedBallCount %d", selectedBallCount);
        NSLog(@"GV SET DEFAULTS currentImageGameSound %@", currentImageGameSound);
        NSLog(@"GV SET DEFAULTS selectedSpeed %d", selectedSpeed);
        NSLog(@"GV SET DEFAULTS globalSoundActivated %hhd", globalSoundActivated);
        NSLog(@"GV SET DEFAULTS currentlySelectedEffectIndex %d", currentlySelectedEffectIndex);
        
      // [self.settingsViewController selectRow:currentlySelectedEffectIndex inComponent:1 animated:YES];
        
        currentDifficulty=gameDifficultyEasy;
       // wasExhaling = true;
        sketchamount=0;
        self.title = @"Groov";
        _animationrate=selectedSpeed;
        self.balloonViewController=[[BalloonViewController alloc]initWithFrame:CGRectMake(10, 0, 130,220) withBallCount:selectedBallCount];
        self.midiController=[[MidiController alloc]init];
        self.midiController.delegate=self;
        [self.midiController addObserver:self forKeyPath:@"numberOfSources" options:0 context:NULL];
        self.currentGameType=gameTypeDuo;
        [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:currentDifficulty] forKey:@"difficulty"];
        
        self.addGameQueue=[[NSOperationQueue alloc]init];
        self.btleManager=[BTLEManager new];
        self.btleManager.delegate=self;
        [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
        [self.btleManager setRangeReduction:2];
        [self.btleManager setTreshold:60];
        [self startSession];
        [self.bluetoothIcon setImage:[UIImage imageNamed:@"Bluetooth-OFF"]];
        [self.photoPickerButton addTarget:self action:@selector(photoButtonLibraryAction) forControlEvents:UIControlEventTouchUpInside];
        self.capturedImages = [NSMutableArray array];
        [self.HQPhotoPickerButton addTarget:self action:@selector(photoButtonBundleAction) forControlEvents:UIControlEventTouchUpInside];
        self.hqImages = [NSMutableArray array];
        
        imagePickerController = [[UIImagePickerController alloc] init] ;
        imagePickerController.delegate = self;
        hqImagePickerController = [[UIImagePickerController alloc] init] ;
        hqImagePickerController.delegate = self;
        
        self.mainGaugeView=[[GameViewGauge alloc]initWithFrame:CGRectMake(445, 20, 40, MAINGUAGE_HEIGHT) ];
        self.mainGaugeView.MainGaugeDelegate=self;
        [self.view addSubview:self.mainGaugeView ];
        [self.view sendSubviewToBack:self.mainGaugeView];
        
        [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: midiController.toggleIsON]; //ADDED FRI
        [self.mainGaugeView start];
    
    }
    return self;
}

-(void) viewWillDisappear:(BOOL)animated{
    
    NSLog(@"GVview will disappear");
   // [self.tabBarController saveUserSettings];
}

- (void)viewDidDisappear:(BOOL)animated{
    self.currentGameType =gameTypeTest;
}

-(void)btleManagerBreathBegan:(BTLEManager*)manager{
    
    disableModeButton = true;
    if ([self.midiController allowBreath]==NO) {
        return;
    }
    
    [self.balloonViewController blowStarted: self.sequenceGameController.currentBall atSpeed:selectedSpeed];
    [self.settingsViewController setSettingsDurationLabelText: [NSString stringWithFormat:@"%.1f", 0.0]];
    
    if ((self.midiController.toggleIsON == 0 && wasExhaling == 1) || (self.midiController.toggleIsON == 1 && wasExhaling == 0)){
        [self midiNoteBegan:nil];
    }else{
        NSLog(@"FIRST MIDI NOTE BEGAN DISALLOWED!");
    }
}

-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    
    disableModeButton = false;
    if ([self.midiController allowBreath]==NO) {
        return;
    }
    [self.balloonViewController blowEnded];
    [self midiNoteStopped:nil];
    isaccelerating=NO;
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    
    wasExhaling = false;
    [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];
    [self.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];
    [self.settingsViewController.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];

    if (self.midiController.toggleIsON==NO) {
        NSLog(@"INHALING AND RETURNING");
        return;
    }
    
    
    NSLog(@"INHALING POM %f, ", percentOfmax);
    
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
   float scale=50.0f;
   float value=self.velocity*scale;
   [self.mainGaugeView setForce:(value)];
   [self.gaugeView setForce:(value)];
   [self.settingsViewController.gaugeView setForce:(value)];
    [self midiNoteContinuing: self.midiController];
}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    wasExhaling = true;
    [self.mainGaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];
    [self.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];
    [self.settingsViewController.gaugeView setBreathToggleAsExhale:wasExhaling isExhaling: self.midiController.toggleIsON];

    if (self.midiController.toggleIsON==YES) {
        NSLog(@"EXHALING AND RETURNING");
        return;
    }
    
    //NSLog(@"EXHALING POM %f, ", percentOfmax);
    
    self.midiController.velocity=127.0*percentOfmax;
    self.midiController.speed= (fabs( self.midiController.velocity- self.midiController.previousVelocity));
    self.midiController.previousVelocity= self.midiController.velocity;
    
    [self midiNoteContinuing: self.midiController];
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    
    float scale=50.0f;
    float value=self.velocity*scale;
    [self.mainGaugeView setForce:(value)];
    [self.gaugeView setForce:(value)];
    [self.settingsViewController setGaugeForce:(value)];
}

- (IBAction)openPhotoPicker:(id)sender {
    [self photoButtonLibraryAction];
}

- (IBAction)openHQContrastPhoto:(id)sender {
    [self photoButtonBundleAction];
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
    [self.view addSubview:self.balloonViewController.view];
    [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
    [self.imageFilterView sendSubviewToBack:imageView];

    [self.settingsViewController setSettinngsDelegate:self];
    self.tabBarController.delegate = self;
    
    self.currentGameType = gameTypeDuo;
    //globalSoundActivated = 1;
    ///usersettings
    
    
    midiinhale=61;
    midiexhale=73;
    velocity=0;
    midiIsOn=false;
    targetRadius=0;
    defaultScale=1.5;
    defaultRadius=0;
    chosenImage = -1;
}

-(void)setLabels
{
    [self managedObjectContext];
    [[GCDQueue mainQueue]queueBlock:^{
        self.currentUsersNameLabel.text=[self.gameUser valueForKey:@"userName"];
    }];
}
#pragma - UIControls

-(IBAction)exitGameScreen:(id)sender
{
    [self.delegate gameViewExitGame];
}

- (IBAction)goToSettings:(id)sender {
    self.currentGameType = gameTypeTest;
    self.balloonViewController.currentGameType = self.currentGameType;

    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
    
    [self.settingsViewController setSettingsDurationLabelText: [NSString stringWithFormat:@"%.1f", 0.0]];
}

-(IBAction)toggleDirection:(id)sender
{
    //velocity=0;
    //isaccelerating = NO;
    //[self.mainGaugeView blowingEnded];
    [self.gaugeView blowingEnded];
    [self.settingsViewController.gaugeView blowingEnded];
    
    NSLog(@"TOGGLE DIRECTION BUTTON %hhd", self.midiController.toggleIsON);
    
    
    if (self.midiController.toggleIsON == YES){
            NSLog(@"SETTING TO EXHALE");
            self.midiController.toggleIsON=NO;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
            
            //addedthu
            [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            //settings vie gaug
            [self.settingsViewController setGaugeSettings:1 exhaleToggle: NO];
           // [self.settingsViewController.gaugeView setBreathToggleAsExhale:1 isExhaling: NO];
            wasExhaling = true;
    }else if (self.midiController.toggleIsON == NO){
             NSLog(@"SETTING TO INHALE");
            self.midiController.toggleIsON=YES;
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
            wasExhaling = false;
            [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
            [self.settingsViewController setGaugeSettings:0 exhaleToggle: YES];

            //[self.settingsViewController.gaugeView setBreathToggleAsExhale:0 isExhaling: YES];
    }
}

-(void)setDirection:(int)value{
    
    [self.gaugeView blowingEnded];
    [self.settingsViewController.gaugeView blowingEnded];
    
    if (self.midiController.toggleIsON == YES){
        NSLog(@"SETTING TO EXHALE from settings");
        self.midiController.toggleIsON=NO;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
        [self.mainGaugeView setBreathToggleAsExhale:1 isExhaling: NO];
        wasExhaling = true;
        
        
    }else if (self.midiController.toggleIsON == NO){
        NSLog(@"SETTING TO INHALE from settings");
        self.midiController.toggleIsON=YES;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        wasExhaling = false;
        [self.mainGaugeView setBreathToggleAsExhale:0 isExhaling: YES];
    }
}

-(IBAction)toggleGameMode:(id)sender
{
    if (disableModeButton == true){
        NSLog(@"game mode button is disabled");
    }else{
        NSLog(@"Toggling game mode");
        int mode=self.currentGameType;
        mode++;
        
        if (mode>2) {
            mode=gameTypeBalloon;
        }
        
        self.currentGameType=mode;
        self.balloonViewController.currentGameType = self.currentGameType;
        NSLog(@"Current game mode %u", self.currentGameType);
        [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];
        [self resetGame:nil];
    }
}

-(NSString*)stringForMode:(int)mode
{
    NSString  *modeString;
    
    switch (mode) {
        case gameTypeDuo:
            NSLog(@"changing mode duo");
            modeString=@"MainMode-BOTH";
            break;
        case gameTypeImage:
            NSLog(@"changing mode gameTypeImage");
            modeString=@"MainMode-IMAGE";
            break;
        case gameTypeBalloon:
            NSLog(@"changing mode gameTypeBalloon");
            modeString=@"MainMode-BALLOON";
            break;
        case gameTypeTest:
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
    
    int setDifficulty = [[[NSUserDefaults standardUserDefaults] objectForKey:@"difficulty"] intValue];
    
    if (setDifficulty == 2 || setDifficulty > 2){
        setDifficulty = 0;
    }else{
        setDifficulty++;
    }

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
   // NSLog(@"RESETTING GAME with ballcount %d", selectedBallCount);
    self.sequenceGameController= [[SequenceGame alloc] initWithBallCount:selectedBallCount ];
        self.sequenceGameController.delegate=self;
    [self.balloonViewController resetwithBallCount:selectedBallCount];
}

#pragma - Midi Delegate

-(void)midiNoteBegan:(MidiController*)midi
{
    self.sequenceGameController.time = 0;
    bestCurrentVelocity = 0;
    [self.settingsViewController setSettingsStrengthLabelText:@"0"];
    [self.settingsViewController setSettingsDurationLabelText:[NSString stringWithFormat:@"%.1f",self.sequenceGameController.time]];
    
    if ((self.midiController.toggleIsON == 0 && wasExhaling == 1) || (self.midiController.toggleIsON == 1 && wasExhaling == 0)){
        
        [self.sequenceGameController startTimer];
        
        switch (self.currentGameType) {
            case gameTypeDuo:
                [self midiNoteBeganForSequence:midi];
                self.balloonViewController.currentGameType=gameTypeDuo;
                [self playImageGameSound];
                break;
            case gameTypeImage:
                [self playImageGameSound];
                self.balloonViewController.currentGameType=gameTypeImage;
                break;
            case gameTypeBalloon:
                [self midiNoteBeganForSequence:midi];
                 [self playGameSound];
                self.balloonViewController.currentGameType=gameTypeBalloon;
                break;
            case gameTypeTest:
                [self midiNoteBeganForSequence:midi];
                self.balloonViewController.currentGameType=gameTypeTest;
                break;
            default:
                break;
        }
    }
    
    if (self.mainGaugeView.animationRunning) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //   [_debugTextField setText:@"\nMidi Began"];
        });
        //        [self beginNewSession];
        [self.mainGaugeView blowingBegan];
    }
    
    if (self.gaugeView.animationRunning) {
        [self.gaugeView blowingBegan];
    }
    
    if (self.settingsViewController.gaugeView.animationRunning) {
        [[self.settingsViewController gaugeView] blowingBegan];
    }
}

-(void)midiNoteStopped:(MidiController*)midi
{
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
    

    
    [self.mainGaugeView blowingEnded];
    [self.gaugeView blowingEnded];
    [self.settingsViewController.gaugeView blowingEnded];
    [self.sequenceGameController killTimer];
    self.sequenceGameController.time = 0;
    
    if (self.currentGameType == gameTypeTest){
        NSLog(@"Currently in test mode, saving disabled");
    }else{
        [self saveCurrentSession];
    }
    
    
}

-(void)midiNoteContinuing:(MidiController*)midi
{
    if (midi.velocity==127) {
        return;
    }

    if (midi.velocity > bestCurrentVelocity){
        bestCurrentVelocity = midi.velocity;
    }
    
    [self.settingsViewController setSettingsStrengthLabelText:[NSString stringWithFormat:@"%0.0f",bestCurrentVelocity]];
    [self.settingsViewController setSettingsDurationLabelText:[NSString stringWithFormat:@"%.1f",self.sequenceGameController.time]];
    
    if (midi.velocity>[self.currentSession.sessionStrength floatValue]) {
        
        if (midi.velocity!=127) {
            self.currentSession.sessionStrength=[NSNumber numberWithFloat:midi.velocity];
        }
    }
    
    //self.currentSession.sessionSpeed=[NSNumber numberWithFloat:midi.speed];
    
    self.currentSession.sessionSpeed = [NSNumber numberWithInt:selectedSpeed];
    //check
    self.currentSession.sessionDuration = [NSString stringWithFormat:@"%g", self.sequenceGameController.time];
    
    [[GCDQueue mainQueue]queueBlock:^{
        switch (self.currentGameType) {
            case gameTypeDuo:
                [self midiNoteContinuingForSequence:midi];
                break;
            case gameTypeImage:
                break;
            case gameTypeBalloon:
                [self midiNoteContinuingForSequence:midi];
                break;
            case gameTypeTest:
                break;
            default:
                break;
        }
    }];
}

#pragma - Sequence

-(void)midiNoteBeganForSequence:(MidiController *)midi
{
    self.sequenceGameController.currentSpeed= -1;
    self.sequenceGameController.time = 0; //added
    
    if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest ){
        NSLog(@"DISALLOWING - SEQUENCE GAME NOT ACTIVE");
        return;
    }

    [self.sequenceGameController startTimer];
}
-(void)midiNoteStoppedForSequence:(MidiController *)midi
{
    
    if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest ){
        NSLog(@"DISALLOWING - SEQUENCE GAME NOT ACTIVE");
        return;
    }
    
    NSLog(@"midiNoteStoppedForSequence");
    NSLog(@"self.sequenceGameController.time %f", self.sequenceGameController.time);
    if (self.currentGameType == gameTypeImage ) {
        [self imageGameWon];
    }
    
    [self.sequenceGameController killTimer];  //only for testing purposes
    
    [self.sequenceGameController nextBall];
    //self.currentSession.sessionAchievedBalloons = [NSNumber numberWithInt: self.sequenceGameController.currentBall];
}

-(void)midiNoteContinuingForSequence:(MidiController*)midi
{

    self.sequenceGameController.currentSpeed=midi.speed;
    
    gameDifficulty  difficulty=[[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"]intValue];
    
    NSLog(@"self.sequenceGameController.currentSpeed %d", self.sequenceGameController.currentSpeed);
    ///   NSLog(@"MIDI NOITE CONTINUING WITH difficulty %u", difficulty);
    
    switch (difficulty) {
        case 0:
        
            if (_currentGameType == gameTypeImage || _currentGameType == gameTypeTest){
                NSLog(@"DISALLOWING - SEQUENCE GAME NOT ACTIVE");
                return;
            }
            
            [self.sequenceGameController setAllowNextBall:YES];
           
            NSLog(@"Sequence small");
            break;
        case 1:
            if (self.sequenceGameController.currentSpeed>15) {       //was 1
                [self.sequenceGameController setAllowNextBall:YES];
                NSLog(@"Sequence medium");
            }else
            {
                [self.sequenceGameController setAllowNextBall:NO];
            }
            break;
        case 2:
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
            if (midi.speed!=0) {
                self.sequenceGameController.totalBallsRaised++;
                [self.sequenceGameController playHitTop];
            }
        }];
    }
}

- (IBAction)toggleMuteSound:(id)sender {
    
    NSLog(@"toggle sound");
    if (globalSoundActivated == 0){
        NSLog(@"muting sound");
        globalSoundActivated = 1;
        UIImage *soundOnImage = [UIImage imageNamed:@"Sound-ON.png"];
         [self.soundIcon setImage:soundOnImage forState:UIControlStateNormal];
        [self.sequenceGameController setAudioMute: globalSoundActivated];
    }else if(globalSoundActivated == 1){
        NSLog(@"unmuting sound");
        globalSoundActivated = 0;
        UIImage *soundOffImage = [UIImage imageNamed:@"Sound-OFF.png"];
        [self.soundIcon setImage:soundOffImage forState:UIControlStateNormal];
        [self.sequenceGameController setAudioMute: globalSoundActivated];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:globalSoundActivated] forKey:@"defaultMute"];
}

-(void)gameEnded:(AbstractGame *)game
{
    [[GCDQueue mainQueue]queueBlock:^{
        [self resetGame:nil];
    }];
    
    [self saveCurrentSession];
    [self.sequenceGameController killTimer];
}

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
    
   // if (particleEffect) {
   //     return;
   // }

    [[GCDQueue mainQueue]queueBlock:^{
        //[self playSound];
       // [self startEffects];
        //[self resetGame:nil];
    }];

    if (self.currentGameType == gameTypeDuo) {
        [[GCDQueue mainQueue]queueBlock:^{
             NSLog(@"DUO GAME WON");
        //    [self saveCurrentSession];  //added kung
        }];
        return;
    }
    else if (self.currentGameType == gameTypeBalloon) {
        [[GCDQueue mainQueue]queueBlock:^{
             NSLog(@"Balloon GAME WON");
        //    [self saveCurrentSession];  //added kung
        }];
        return;
    }
    else if (self.currentGameType == gameTypeImage) {
        [[GCDQueue mainQueue]queueBlock:^{
            NSLog(@"Image GAME WON");
        //    [self saveCurrentSession];  //added kung
        }];
        return;
    }
    
    [self.sequenceGameController killTimer];
}

-(void)startEffects
{

}

-(void)killSparks
{

}

-(void)saveCurrentSession
{
    NSLog(@"ATTEMPTING TO Save Current Session: %u", self.currentGameType);
    self.currentSession.sessionType=[NSNumber numberWithInt:self.currentGameType];
    AddNewScoreOperation  *operation=[[AddNewScoreOperation alloc]initWithData:self.gameUser session:self.currentSession sharedPSC:self.sharedPSC];
    
    NSLog(@"SAVING CURRENT SESSION");
    [self.addGameQueue addOperation:operation];
    [self startSession];
}

-(void) playSound {
    
    NSLog(@"Playing sound game view contoller");
    
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Crowd_cheer6" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        
        NSError *error = nil;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=1.0;
        
        NSLog(@"SOUND: reset all2 %hhd", globalSoundActivated);
        
        if (globalSoundActivated == 0){
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
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"PHOTO LIBRARY did pick ACTION - imagePickerController");
    
    NSLog(@"picker %@", picker);
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self setupDisplayFilteringWithImage:image];
    
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        NSData *webData = UIImagePNGRepresentation(image);
        [webData writeToFile:imagePath atomically:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   // [picker dismissModalViewControllerAnimated:NO];
     [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoButtonLibraryAction
{
    NSLog(@"PHOTO LIBRARY ACTION");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popover presentPopoverFromRect:CGRectMake(0, 0, 500, 500) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //[self presentModalViewController:imagePickerController animated:YES];
    }
}

- (void)photoButtonBundleAction
{
    NSLog(@"PHOTO Bundle ACTION");
    self.hqPickerContainer = [[UIView alloc] initWithFrame:CGRectMake(280, 520, 246, 270)];
    self.hqPickerContainer.backgroundColor = [UIColor blackColor];
    
    NSArray *hqImages = [self getHQImages];
    CGFloat currentX = 2.0f;
    CGFloat currentY = 2.0f;
    
    NSLog(@"hqImages %@", hqImages);
    NSLog(@"[hqImages count] %lu", (unsigned long)[hqImages count]);
    
    for (int i=0; i < [hqImages count]; i++) {
        UIImage *image = [UIImage imageNamed:[hqImages objectAtIndex:i]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        imageView.image= image;
        CGRect rect = imageView.frame;
        rect.origin.x = currentX;
        rect.origin.y = currentY;
        imageView.frame = rect;
        
        if(i == 0){
           // NSLog(@"first");
            
        }else if (i % 4 == 0){
          //  NSLog(@"nextline: i %d", i);
            currentY += 54;
            rect.origin.y = currentY;
            currentX = 2.0f;
            rect.origin.x = currentX;
        }else if (i == 19){
            NSLog(@"adding last image");
            UIImage *lastImage = [UIImage imageNamed:@"HQ 1.jpg"];
            UIImageView *lastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
            lastImageView.image= lastImage;
            CGRect lastRect = lastImageView.frame;
            lastRect.origin.x = 184;
            lastRect.origin.y = 218;
            lastImageView.frame = lastRect;
            lastImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [lastImageView addGestureRecognizer:tap];
            [self.hqPickerContainer addSubview:lastImageView];
            [self.hqPickerContainer bringSubviewToFront:lastImageView];
        }else{
          //  NSLog(@"addding: i %d", i);
            currentX += imageView.frame.size.width + 2;
        }
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [imageView addGestureRecognizer:tap];

        NSLog(@"placing %d at x %f / y %f", i, rect.origin.x, rect.origin.y);
        [self.hqPickerContainer addSubview:imageView];
        [self.hqPickerContainer bringSubviewToFront:imageView];
    }
    
    [self.view addSubview: self.hqPickerContainer];
}



- (IBAction)tapGesture:(UITapGestureRecognizer*)gesture
{
    NSLog(@"tap gesture");

    CGPoint tapLocation = [gesture locationInView: self.hqPickerContainer];
    for (UIImageView *imageView in self.hqPickerContainer.subviews) {
        
         NSLog(@"imageView");
        if (CGRectContainsPoint(imageView.frame, tapLocation)) {
            // [imageView removeFromSuperview];
            [self setupDisplayFilteringWithImage:imageView.image];
        }
    }
    
    [self.hqPickerContainer removeFromSuperview];
}

-(NSArray*)getHQImages{
    
    NSString *bundleRootPath = [[NSBundle mainBundle] bundlePath];
    NSArray *bundleRootContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRootPath error:nil];
    NSArray *files = [bundleRootContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self beginswith 'HQ'"]];
    
    return files;
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
    NSLog(@" inner set breath length %f", value);
   // self.breathLength=value;
    selectedSpeed = (int) (value + 0.5);
   // self.currentSession.sessionRequiredBreathLength = [NSNumber numberWithFloat:value];
    _animationrate= (int) (value + 0.5);
}

-(void)setSpeed:(float)value
{
    NSLog(@" inner set breath speed %f", value);

   // selectedSpeed = (int)value;
    selectedSpeed = roundf(value);
    
    NSLog(@" roundedNumber %d", selectedSpeed);
    
    self.currentSession.sessionSpeed = [NSNumber numberWithFloat:selectedSpeed];
    _animationrate=selectedSpeed; //was value
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:selectedSpeed] forKey:@"defaultSpeed"];
}

-(void)viewDidAppear:(BOOL)animated
{
     NSLog(@"VIEWDIDAPPEAR");
    [self resetGame:nil];
    self.currentGameType= gameTypeDuo;
    
    ///usersettings
    
    self.balloonViewController.currentGameType = self.currentGameType;
    [self.toggleGameModeButton setImage:[UIImage imageNamed:[self stringForMode:self.currentGameType]] forState:UIControlStateNormal];

    if (!displayLink) {
         NSLog(@"SETTING UP DISPLAY LINK viewdidload");
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        animationRunning = YES;
        [displayLink setFrameInterval:3];//60 times in one second       //was 8
        //[self makeTimer];
        // acceleration=0.1;
        acceleration=0.1;
        distance=0;
    }
}

-(void)prepareDisplay{
    NSLog(@"PREPARING VC");
    
    self.mainGaugeView.MainGaugeDelegate=self;
    [self.mainGaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
    [self.mainGaugeView start];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tap];
    
    if (!displayLink) {
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        animationRunning = YES;
        [displayLink setFrameInterval:3];//60 times in one second       //was 8
        //[self makeTimer];
        // acceleration=0.1;
        acceleration=0.1;
        distance=0;
    }
}


-(void)updateimage
{
   // NSLog(@"self.currentGameType %u" , self.currentGameType);
  if (self.currentGameType == gameTypeTest) {
   //   NSLog(@"Image filter not allowed in test mode! ");
      return;
  }else if (self.currentGameType == gameTypeBalloon){
    //   NSLog(@"Image filter not allowed in balloon mode! ");
      return;
  }
    //  NSLog(@"UPDATE IMAGE");
    //change: is this the best place to do this?
    
    
    /***
     @"Bulge",@"Swirl",@"Blur",@"Vignette",@"Toon",
     @"Tone",@"Sketch",@"Polka",
     @"Posterize",@"Pixellate",@"Haze",@"Erosion"
     */
    // self.velocity+=1;
    
    //float fVel= (float)self.velocity;
    // float rate = fVel/5;
    
    //CHANGED
    //float rate = fVel;
    //float rate = 10;
    
    //NSLog(@"stillImageFilter %@",stillImageFilter);
   // _animationrate = 6 - _animationrate;
    
    //NSLog(@"ESTIMATED TIME OF ANIMATION %f", 10 - _animationrate);
   // NSLog(@"FL Velocity %f", fVel);
    
   // NSLog(@"OUTPUT %f",targetRadius+((rate/500)*_animationrate));
    //NSLog(@"_animationrate %f",_animationrate);
    //NSLog(@"THRESH %d",threshold);
    
   
   // _animationrate = _animationrate;
    //NSLog(@"selectedspeed  - %d",selectedSpeed);
   // NSLog(@"rate/500 -  %f",rate/500);
    //NSLog(@"((rate/500)*_animationrate) -  %f",((rate/500)*_animationrate));
    
    if (isaccelerating)
    {
        //    NSLog(@"isaccelerating == %hhd",isaccelerating);
        
        //this is called ten times a second
        //animation rate is 3
        //need targetradius to be 100% over 3 seconds
        
        
        if (self.velocity>=threshold) {
            
            //float newRate = .1/_animationrate;
            float newRate = .05/_animationrate;
            //float newRate2 = _animationrate/.1;
          //  NSLog(@"RATE:  %f",newRate);
           // NSLog(@"RATE2:  %f",newRate2);
           // NSLog(@"_animationrate:  %f",_animationrate);
           // NSLog(@"targetRadius:  %f",targetRadius);
            //targetRadius=targetRadius+((rate/500)*_animationrate);
            targetRadius=targetRadius+newRate;
        }
        
    }else
    {
        //force-=force*0.03;
        // targetRadius=targetRadius-((35.0/500)*_animationrate);
        targetRadius=targetRadius-(40.0/500);
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
    }
    [sourcePicture processImage];
}

-(void)setupDisplayFilteringWithImage:(UIImage*)aImage
{
    NSLog(@"SETUP DISPLAY WITH NEW IMAGE");
    [sourcePicture removeAllTargets];
    stillImageFilter=nil;
    sourcePicture = [[GPUImagePicture alloc] initWithImage:aImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:1];
    
    ///usersettings
    
    [self.imageFilterView insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    [sourcePicture processImage];
}

- (void)setupDisplayFiltering;
{
   // NSLog(@"SET UP DISPLAY FILTERING");
    UIImage *inputImage;
    inputImage=[UIImage imageNamed:@"giraffe-614141_1280.jpg"];
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex: currentlySelectedEffectIndex];
    ///usersettings
    imageView = [[GPUImageView alloc]initWithFrame:self.imageFilterView.frame];
    [self.imageFilterView insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    //[sourcePicture processImage]; //changed to stop bulge on startup
}

-(void)setFilter:(int)index
{
   // NSLog(@"inner set filter");
    [sourcePicture removeAllTargets];
    stillImageFilter=nil;
    stillImageFilter=[self filterForIndex:index];

    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    self.mainGaugeView.MainGaugeDelegate=self;
    [self.mainGaugeView start];
    [self.mainGaugeView setForce:0];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:index] forKey:@"defaultEffect"];
    currentlySelectedEffectIndex = index;
}

-(void)setRepetitionCount:(int)value{
    NSLog(@"inner Setting balloon game repetition count to %d ", value);
    NSLog(@"count %d ", value);
    selectedBallCount = value;
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:selectedBallCount] forKey:@"defaultRepetitionIndex"];
}

-(void)setImageSoundEffect:(NSString*)value{
    NSLog(@"Setting Image sound effect to %@ ", value);
    currentImageGameSound = value;
    [[NSUserDefaults standardUserDefaults]setObject:currentImageGameSound forKey:@"defaultSound"];
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

-(void)animate
{
    NSLog(@"animating");
    
    self.velocity+=0.1;
    if (self.velocity<threshold) {
        return;
    }
    
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
    NSString* imageName = @"";
    
    if (_currentGameType == gameTypeBalloon){
        imageName = [NSString stringWithFormat:@"%dBallon", selectedSpeed];
    }else{
        imageName = [NSString stringWithFormat:@"%d%@", selectedSpeed, currentImageGameSound];
    }
    
    NSLog(@"Playing sound GVC IMAGE SOUND:  %@", imageName);
    NSLog(@" image game speed %d", selectedSpeed);
    
     NSLog(@"globalSoundActivated %d", globalSoundActivated);
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: imageName ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    
    if (globalSoundActivated == 1){
        [audioPlayer play];
    }else{
        NSLog(@"Global sound set to off");
    }
}

-(void) playGameSound {
    
    NSLog(@"Playing image game sound %@", currentImageGameSound);
    NSLog(@" image game speed %d", selectedSpeed);
    NSString* imageName = @"";
    
    if (_currentGameType == gameTypeBalloon){
        imageName = [NSString stringWithFormat:@"%dBallon", selectedSpeed];
    }else{
        imageName = [NSString stringWithFormat:@"%d%@", selectedSpeed, currentImageGameSound];
    }

    NSLog(@"Playing sound GVC: GAME SOUND  %@", imageName);
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: imageName ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    
    if (globalSoundActivated == 1){
        [audioPlayer play];
    }else{
        NSLog(@"Global sound set to off");
    }
}

-(void)start
{
    NSLog(@"Starting mage game");
    displayLink = [CADisplayLink displayLinkWithTarget:self
                                              selector:@selector(animate)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    animationRunning = YES;
}

-(void)setResitance:(int)pvalue
{
    NSLog(@"Setting setResitance to %d", pvalue);
    //maybe remove
    
    switch (pvalue) {
        case 0:
            [self.mainGaugeView setMass:1];
            break;
        case 1:
            [self.mainGaugeView setMass:2];
            break;
        case 2:
            [self.mainGaugeView setMass:2.5];
            break;
        case 3:
            [self.mainGaugeView  setMass:3];
            break;
        default:
            break;
    }
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[SettingsViewController class]]){
        self.settingsViewController = (SettingsViewController *) viewController;
    }
    
    NSLog(@"FOUND TAB BAR");
    return TRUE;
}

@end
