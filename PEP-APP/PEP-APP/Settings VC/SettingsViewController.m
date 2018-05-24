#import "ViewController.h"
#import "SettingsViewController.h"
#import "infoViewController.h"
#import "BTLEManager.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Session.h"
#import "UIEffectDesignerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Draggable.h"

@interface SettingsViewController ()<UITabBarDelegate, BTLEManagerDelegate, MidiControllerProtocol>{
    UINavigationController   *navcontroller;
    //Gauge    *gaugeView;
    MidiController  *midiController;
    //  ScoreDisplayViewController  *scoreViewController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    //Session  *currentSession;
    //UIEffectDesignerView  *particleEffect;
    NSTimer  *effecttimer;
    UIImageView  *bellImageView;
    UIImageView  *bg;
    Draggable  *peakholdImageView;
    //LogoViewController  *logoviewcontroller;
    int threshold;
    AVAudioPlayer *audioPlayer;
    UIButton  *togglebutton;
    BOOL   toggleIsON;
    int midiinhale;
    int midiexhale;
    int currentdirection;
    int inorout;
    bool currentlyExhaling;
    bool currentlyInhaling;
}

@property(nonatomic,strong)BTLEManager  *btleManager;

@end

@implementation SettingsViewController

@synthesize settinngsDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"INITIATED SETTINGS MODE");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if (self) {
        self.title = @"Settings";
        imageGameSoundArray=[NSMutableArray arrayWithObjects:@"01Ballon",@"01Bas slide",@"01bell synth", @"01droom", nil];
        repititionsArray=[NSMutableArray arrayWithObjects: @"1",@"2",@"3", @"4",@"5",@"6",@"7",@"8", nil];
        filterArray=[NSMutableArray arrayWithObjects:
                     @"Bulge",@"Swirl",@"Blur",@"Toon",
                     @"Expose",@"Polka",
                     @"Posterize",@"Pixellate",@"Contrast", nil];
        
        self.gaugeView=[[Gauge alloc]initWithFrame:CGRectMake(90, 155, 90, GUAGE_HEIGHT) ];
        self.gaugeView.GaugeDelegate=self;
        [self.view addSubview:self.gaugeView];
        [self.view sendSubviewToBack:self.gaugeView];
        [self.view sendSubviewToBack:whiteBackground];
        
        [self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
        [self.gaugeView start];
        
        NSArray *imageNames = @[@"bell_1.png", @"bell_2.png", @"bell_3.png", @"bell_2.png",@"bell_1.png"];
        NSMutableArray *images = [[NSMutableArray
                                   alloc] init];
        for (int i = 0; i < imageNames.count; i++) {
            [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        }
        
        bellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.gaugeView.frame.origin.x, self.gaugeView.frame.origin.y-50, 100, 100)];
        bellImageView.animationImages = images;
        bellImageView.animationDuration = 0.7;
        
        [self.view addSubview:bellImageView];
        
        [speedSlider setValue:4 animated:YES];
        //peakholdImageView=[[Draggable alloc]initWithImage:[UIImage imageNamed:@"PeakHoldArrow.png"]];
       // CGRect peakframe=peakholdImageView.frame;
       /// peakframe.origin.y=900;
       // peakframe.origin.x=251;
        
        //[peakholdImageView setFrame:peakframe];
       // peakholdImageView.delegate=self;
        // [self.gaugeView addSubview:peakholdImageView];
        //  self.view.userInteractionEnabled=NO;
        ///[self.view addSubview:peakholdImageView];
        //self.gaugeView.arrow=peakholdImageView;
        
       // self.btleManager=[BTLEManager new];
       // self.btleManager.delegate=self;
       // [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
       // [self.btleManager setRangeReduction:2];
       // [self.btleManager setTreshold:60];
       // [self startSession];
        
        currentlyExhaling = false;
       // [self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
       // [self.gaugeView start];
    }
    return self;
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

-(Gauge*) getSettingsGauge{
    
    return self.gaugeView;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
   // NSLog(@"changing numberOfRowsInComponent 0");
    int amount = 0;
    if (thePickerView==pickerViewB) {
        amount=(int)[imageGameSoundArray count];
        }
    if (thePickerView==pickerViewC) {
        amount=(int)[repititionsArray count];
    }
    if (thePickerView==filterPicker) {
        amount=(int)[filterArray count];
    }
    
	return amount;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    //NSLog(@"changing pickerView titleForRow");
    NSString *thetitle;
    
  //  if (thePickerView==pickerViewA) {
  ///     thetitle=[arrayA objectAtIndex:row];
  //  }
    if (thePickerView==pickerViewB) {
       thetitle=[imageGameSoundArray objectAtIndex:row];
   }
    if (thePickerView==pickerViewC) {
        thetitle=[repititionsArray objectAtIndex:row];
    }
    if (thePickerView==filterPicker) {
        thetitle=[filterArray objectAtIndex:row];
    }
	return thetitle;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
   // NSLog(@"changing thePickerView didSelectRow ");
	
    int rowint=(int)row;
 //   if (thePickerView==pickerViewA) {
        //NSLog(@"Selected : %@. Index of selected color: %i", [arrayA objectAtIndex:row], row);
        
   //     [self valueASend:rowint];
  //  }
    if (thePickerView==pickerViewB) {
     //   NSLog(@"Selected : %@. Index of selected color: %i", [imageGameSoundArray objectAtIndex:row], row);
       // [self valueBSend:rowint];
        [self.settinngsDelegate setImageSoundEffect: [imageGameSoundArray objectAtIndex:row]];
    }
    
    if (thePickerView==pickerViewC) {
     //   NSLog(@"Selected : %@. Index of selected color: %i", [repititionsArray objectAtIndex:row], row);
        //[self valueCSend:rowint];
        NSInteger selectedValAsint = [[repititionsArray objectAtIndex:row] integerValue];
        [self.settinngsDelegate setRepetitionCount: selectedValAsint];
    }
    
    if (thePickerView==filterPicker) {
      //  NSLog(@"Selected : %@. Index of selected color: %i", [filterArray objectAtIndex:row], row);
        [self.settinngsDelegate setFilter:rowint];
    }
}

-(void)btleManagerConnected:(BTLEManager *)manager
{
    
    NSLog(@"setting view btle manager detected");
  //  dispatch_async(dispatch_get_main_queue(), ^{
   //     [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-CONNECTED"]];
   // });
}

-(IBAction)changeRate:(id)sender

{
    NSLog(@"changing rate");
    UISlider  *slider=(UISlider*)sender;
    [self.settinngsDelegate setRate:slider.value];
}

-(IBAction)setBreathLength:(id)sender
{
    NSLog(@"changing breath length");
    UISlider  *slider=(UISlider*)sender;
    int sliderValue = (int) slider.value;
    
    [self.settinngsDelegate setBreathLength:slider.value];
    
    [self.settinngsDelegate setSpeed:slider.value];
    
    
    //[self setBreathLengthLabelText: [NSString stringWithFormat:@"%d",sliderValue]];
}

-(IBAction)changeThreshold:(id)sender
{
    NSLog(@"changing threshold");
    
    [self.settinngsDelegate setThreshold:thresholdSlider.value];
    [thresholdLabel setText:[NSString stringWithFormat:@"%f",thresholdSlider.value]];
}
-(IBAction)changeBTTreshold:(id)sender
{
    NSLog(@"changing changeBTTreshold");
    
    [self.settinngsDelegate setBTTreshold:btThresholdSlider.value];
    [btTresholdLabel setText:[NSString stringWithFormat:@"%f",btThresholdSlider.value]];
    [self.settinngsDelegate test:btThresholdSlider.value];

}
-(IBAction)changeBTBoostValue:(id)sender
{
    NSLog(@"changing changeBTBoostValue");
    
    [self.settinngsDelegate setBTBoost:btBoostSlider.value];
    [btrangeBoost setText:[NSString stringWithFormat:@"%f",btBoostSlider.value]];
}

- (IBAction)exitSettingsViewController:(id)sender {
    NSLog(@"SV: back button pressed");
    
  //  [UIView transitionFromView:self.view toView: gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
  //  }];
  //
    
    [self.delegate exitSettingsViewController];
}

//-(void)valueASend:(NSInteger)index
//{
 //   int note =0;
 //   switch (index) {
 //       case 0:
 //           note=12;
 ///           break;
 //       case 1:
 //           note=14;
 /////           break;
//        case 2:
////            note=16;
 //           break;
///        default:
//            break;
 //   }
//
//    [self.settinngsDelegate sendValue:note onoff:0];
///}

//-(void)valueBSend:(NSInteger)index
//{
 //   int note =0;
 //   switch (index) {
 ///       case 0:
 ///           note=24;
 ///           break;
 //       case 1:
  //          note=26;
            
 //           break;
  ///      case 2:
  ///          note=28;
            
  //          break;
  ///      case 3:
  ///          note=29;
            
   //         break;
            
   ///     default:
    //        break;
    //}
    
    
   /// [self.settinngsDelegate sendValue:note onoff:0];
//}
//-(void)valueCSend:(NSInteger)index
//{
//    int note =0;
 ////   switch (index) {
 ///       case 0:
 ///           note=36;
 //           break;
 ///       case 1:
 //           note=38;
            
 //           break;
  ///      case 2:
  //          note=40;
            
  //          break;
 //       case 3:
  //          note=41;
            
   ///         break;
            
   //     default:
   //         break;
  //  }
  //  [self.settinngsDelegate sendValue:note onoff:0];
//gmail}

//TEST

-(void)btleManagerBreathBegan:(BTLEManager*)manager{
 //   self.date=[NSDate date];
    
    //  NSLog(@"MIDINOTEBGAN currentlyexhaling == %d", currentlyExhaling);
    //  NSLog(@"MIDINOTEBGAN currentlyInhaling == %d", currentlyInhaling);
    
    //  if ((currentlyExhaling == true && midiController.toggleIsON )|| (currentlyInhaling == true && midiController.toggleIsON == false)){
    
    [self midiNoteBegan:nil];
    
    //if (gameTypeTest){
    //    [SettingsViewController breathBegan];
   // }
    //  }else{
    // }
}
-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    [self midiNoteStopped:nil];
 //   if (gameTypeTest){
 //       [SettingsViewController breathStopped];
  //  }
}

//-(void)testGaugeStopped{
 //   [self midiNoteStopped:nil];
//}

//-(void)testGaugeBegan{
//      [self midiNoteBegan:nil];
//}

//-(void)testGaugeExhale: (float)percent{

//currentlyExhaling = true;
//currentlyInhaling = false;

//-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;
//[self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];

//if (midiController.toggleIsON) {
//    return;
//}

//float  vel=127.0*percent;

///if (vel<threshold) {
////    return;
/////}
///if (vel==127) {
///    return;
//}
//}

-(void)testGaugeInhale: (float)percent{
    currentlyExhaling = false;
    currentlyInhaling = true;
    
    [self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
    
    if (midiController.toggleIsON==NO) {
        return;
    }
    
    float  vel=127.0*percent;
    
    if (vel<threshold) {
        return;
    }
    if (vel==127) {
        return;
    }
    float scale=50.0f;
    float value=vel*scale;
    
    
    //  if (gameTypeTest){
    //      [SettingsViewController breathInhale];
    //  }else{
    //     [gaugeView setForce:(value)];
    // }
    // NSDate  *date=[NSDate date];
    
    // if (vel>[currentSession.sessionStrength intValue]) {
    //      currentSession.sessionStrength=[NSNumber numberWithInt:vel];
    // [gaugeView setArrowPos:0];
    //   }
    
    //  double  duration=[date timeIntervalSinceDate:self.date];
    // currentSession.sessionDuration=[NSNumber numberWithDouble:duration];
    // NSString  *durationtext=[NSString stringWithFormat:@"%0.0f",duration];
    //  dispatch_async(dispatch_get_main_queue(), ^{
    // scoreViewController.durationValueLabel.text=durationtext;
    // [scoreViewController setStrength:vel];
    // [self sendLogToOutput:@"conti"];
    //  });
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax
{

}

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    
    ///NSLog(@"VEL IS %f", vel);
    
    float scale=50.0f;
 //   float value=vel*scale;
    
 //   if (gameTypeTest){
   //     [SettingsViewController breathExhale];
   // }else{
   //     [gaugeView setForce:(value)];
   // }
    
   // NSDate  *date=[NSDate date];
    
  //  if (vel>[currentSession.sessionStrength intValue]) {
  //      currentSession.sessionStrength=[NSNumber numberWithInt:vel];
        // [gaugeView setArrowPos:0];
  //  }
    
   // double  duration=[date timeIntervalSinceDate:self.date];
  //  currentSession.sessionDuration=[NSNumber numberWithDouble:duration];
   // NSString  *durationtext=[NSString stringWithFormat:@"%0.0f",duration];
  //  dispatch_async(dispatch_get_main_queue(), ^{
    //    scoreViewController.durationValueLabel.text=durationtext;
    //    [scoreViewController setStrength:vel];
        // [self sendLogToOutput:@"conti"];
 //   });
}

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

//MORETEST

-(void)draggable:(Draggable *)didDrag
{
    //900-330
    
    NSLog(@"did drag ");
    CGRect  frame=didDrag.frame;
    [self.gaugeView setBestDistanceWithY:900-frame.origin.y];
    // CGRect  newframe=[self.view convertRect:frame toView:gaugeView];
}

- (IBAction)toggleDirection:(id)sender
{
    if (!midiController) {
        midiController=[MidiController new];
    }
    switch (midiController.toggleIsON) {
        case 0:
            midiController.toggleIsON=YES;
            //  midiController.currentdirection=midiinhale;
            [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_INHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
            // currentlyExhaling = false;
            break;
        case 1:
            midiController.toggleIsON=NO;
            
            [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_EXHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"exhale" forKey:@"direction"];
            //currentlyExhaling = true;
            //  midiController.currentdirection=midiexhale;
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Test Methods

-(IBAction)touchAccelerateUp:(id)sender
{
    [self.gaugeView blowingEnded];
    [self endCurrentSession];
    [timer invalidate];
}

-(IBAction)touchAccelerateDown:(id)sender
{
  //  [self beginNewSession];
    
    [self.gaugeView blowingBegan];
  //  timer=[NSTimer timerWithTimeInterval:0.1 target:self /selector:@selector(simulateBlow) userInfo:nil repeats:YES];
  //  [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
- (IBAction)toInfoView:(id)sender {
    
    NSLog(@"Going to info view");
    
    infoViewController *infoVC = [[infoViewController alloc]initWithNibName:@"infoViewController" bundle:nil];
    
    if (infoVC){
        NSLog(@"instantiating infoVC");
        [self presentViewController:infoVC animated:YES completion:nil];
    }else{
        NSLog(@"Cant instantiate infoVC");
    }
}

- (IBAction)toUsersView:(id)sender {
    
    NSLog(@"Moving to users screen");
 //   self.userList.sharedPSC=self.sharedPSC ;
   // [self.userList getListOfUsers];
 //   [UIView transitionFromView:self.view toView:self.navcontroller.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        
 //       self.userList.sharedPSC=self.sharedPSC;
 //       self.userList.delegate=self;
        
//    }];
    
}

-(void)simulateBlow
{
   NSLog(@"Simulating blow");
  //  float  vel=[_inputtext.text floatValue];
  //  if (vel==127) {
  //      return;
  //  }
   // float scale=10.0f;
 ////   float value=vel*scale;
 //   [gaugeView setForce:(value)];
 //   NSDate  *date=[NSDate date];
    
 ///   if (vel>[currentSession.sessionStrength intValue]) {
  //      currentSession.sessionStrength=[NSNumber numberWithInt:vel];
   // }
    
  //  double  duration=[date timeIntervalSinceDate:self.date];
  //  currentSession.sessionDuration=[NSNumber numberWithDouble:duration];
  //  NSString  *durationtext=[NSString stringWithFormat:@"%0.1f",duration];
  //  dispatch_async(dispatch_get_main_queue(), ^{
 //       scoreViewController.durationValueLabel.text=durationtext;
 //       [scoreViewController setStrength:vel];
        
   // });
}
#pragma mark -
#pragma mark - Midi Delegate

-(void)midiNoteBegan:(MidiController*)midi
{
    NSLog(@"MIDINOTEBEGAN");
    
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
    if (self.gaugeView.animationRunning) {
        [self sendLogToOutput:@"\nMidi Stop"];
        [self.gaugeView blowingEnded];
        [self endCurrentSession];
    }
}

-(void)midiNoteContinuing:(MidiController*)midi
{
    NSLog(@"midiNoteContinuing currentlyExhaling %d", currentlyExhaling);
    NSLog(@"midiNoteContinuing currentlyInhaling %d", currentlyInhaling);
    
    if ((currentlyExhaling == true && midiController.toggleIsON) || (currentlyInhaling == true && midiController.toggleIsON == false)){
        
        float  vel=midiController.velocity;
        
        if (vel<threshold) {
            return;
        }
        if (vel==127) {
            return;
        }
        float scale=50.0f;
        float value=vel*scale;
        
        NSDate  *date=[NSDate date];
        
    //    if (vel>[currentSession.sessionStrength intValue]) {
     //       currentSession.sessionStrength=[NSNumber numberWithInt:vel];
             [self.gaugeView setArrowPos:0];
    //    }
        
      //  double  duration=[date timeIntervalSinceDate:self.date];
   //     currentSession.sessionDuration=[NSNumber numberWithDouble:duration];
   //     NSString  *durationtext=[NSString stringWithFormat:@"%0.0f",duration];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        scoreViewController.durationValueLabel.text=durationtext;
    //        [scoreViewController setStrength:vel];
            // [self sendLogToOutput:@"conti"];
    //    });
        
    }else{
        NSLog(@"Disallowing");
    }
}

-(void)sendLogToOutput:(NSString*)log
{
   // dispatch_async(dispatch_get_main_queue(), ^{
   //     NSString  *string=[NSString stringWithFormat:@"\n %@",log];
      ////  _debugTextField.text =[_debugTextField.text stringByAppendingString:string];
   // });
}

//#pragma mark -
//#pragma mark - Session Controls
//-(void)beginNewSession
//{
//    if (!sessionRunning) {
//        sessionRunning=YES;
    //    currentSession=[[Session alloc]init];
     //   self.date=[NSDate date];
     //   currentSession.sessionDate=self.date;
     ///   currentSession.username=[[NSUserDefaults standardUserDefaults]valueForKey:@"currentusername"];
//    }
//}

//-(void)endCurrentSessionTest
//{
//}

-(void)endCurrentSession
{
    if (sessionRunning) {
        sessionRunning=NO;
    }
    // dispatch_async(dispatch_get_main_queue(), ^{
    //  scoreViewController.durationValueLabel.text=@"";
    // scoreViewController.strengthValueLabel.text=@"";
    
    // });
 //   [loginViewController updateUserStats:currentSession];
  //  [highScoreViewController updateWithCurrentSession:currentSession];
}

#pragma mark -
#pragma mark - Animation

-(void)maxDistanceReached
{
    [self endCurrentSession];
   // [midiController pause];
  //  if (particleEffect) {
  //      dispatch_async(dispatch_get_main_queue(), ^{
  ///          [particleEffect removeFromSuperview];
  ///          particleEffect=nil;
  ///      });
  //}
   //particleEffect = [UIEffectDesignerView effectWithFile:@"sparks.ped"];
  //  CGRect frame=particleEffect.frame;
  // frame.origin.x=(self.view.bounds.size.width/2)-50;
  //  frame.origin.y=gaugeView.frame.origin.y-40;
   /// particleEffect.frame=frame;
   // [self.view addSubview:particleEffect];
    effecttimer=[NSTimer timerWithTimeInterval:4 target:self selector:@selector(killSparks) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:effecttimer forMode:NSDefaultRunLoopMode];
    //[self playSound];
    [bellImageView startAnimating];
}

-(void)killSparks
{
    NSLog(@"KILL SPARKS");
    //dispatch_async(dispatch_get_main_queue(), ^{
    //[particleEffect removeFromSuperview];
    //particleEffect=nil;
    //});
    [midiController resume];
    [self midiNoteStopped:midiController];
    [effecttimer invalidate];
    effecttimer=nil;
    [self.gaugeView start];
    [bellImageView stopAnimating];
}

-(void)setSettingsDurationLabelText: (NSString*)text  {
    
    NSLog(@"Settings duration label text %@", text);
    settingsDurationLabel.text = text;
}

-(void)setBreathLengthLabelText: (NSString*)text  {
    
    NSLog(@"breathLengthLabel label text %@", text);
    breathLengthLabel.text = text;
}

-(void)setSettingsStrengthLabelText: (NSString*)text  {
    
    NSLog(@"Settings strength label text %@", text);
    settingsStrengthLabel.text = text;
}

-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"bell" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}



@end
