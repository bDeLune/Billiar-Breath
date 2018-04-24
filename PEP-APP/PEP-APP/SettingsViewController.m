#import "ViewController.h"
#import "SettingsViewController.h"
#import "BTLEManager.h"
#import "Gauge.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Session.h"
#import "UIEffectDesignerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Draggable.h"

@interface SettingsViewController ()<UITabBarDelegate, BTLEManagerDelegate, MidiControllerProtocol>{
    
    UINavigationController   *navcontroller;
  ///  LoginViewViewController   /*loginViewController;
  //  HighScoreViewController   *highScoreViewController;
    Gauge    *gaugeView;
    MidiController  *midiController;
  //  ScoreDisplayViewController  *scoreViewController;
    NSTimer  *timer;
    BOOL  sessionRunning;
 //   Session  *currentSession;
    
 //   UIEffectDesignerView  *particleEffect;
    
    NSTimer  *effecttimer;
    UIImageView  *bellImageView;
    UIImageView  *bg;
    Draggable  *peakholdImageView;
    
  //  LogoViewController  *logoviewcontroller;
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
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        arrayA=[NSMutableArray arrayWithObjects:@"Small",@"Normal",@"Big", nil];
        arrayB=[NSMutableArray arrayWithObjects:@"Low",@"Normal",@"High",@"Very High", nil];
        arrayC=[NSMutableArray arrayWithObjects:@"10",@"50",@"100",@"200", nil];
        
        /*
         #import"GPUImageVignetteFilter.h"
         #import "GPUImageToonFilter.h"
         #import "GPUImageToneCurveFilter.h"
         #import "GPUImageThresholdSketchFilter.h"
         #import "GPUImageDilationFilter.h"
         #import "GPUImageDissolveBlendFilter.h"
         #import "GPUImageStretchDistortionFilter.h"
         #import "GPUImageSphereRefractionFilter.h"
         #import "GPUImagePolkaDotFilter.h"
         #import "GPUImagePosterizeFilter.h"
         #import "GPUImagePixellateFilter.h"
         #import "GPUImageHazeFilter.h"
         #import "GPUImageErosionFilter.h"
         */
        
        filterArray=[NSMutableArray arrayWithObjects:
                     @"Bulge",@"Swirl",@"Blur",@"Toon",
                     @"Expose",@"Polka",
                     @"Posterize",@"Pixellate",@"Contrast", nil];
        
        
       
        
        
        
        gaugeView=[[Gauge alloc]initWithFrame:CGRectMake(370, 365, 40, GUAGE_HEIGHT)];
        gaugeView.gaugedelegate=self;
        
      //  scoreViewController=[[ScoreDisplayViewController alloc]init];
      //  scoreViewController.view.frame=CGRectMake(self.view.bounds.size.width-200,
        //                                          self.view.bounds.size.height-400,
       //                                           200,
        //                                          300);
        //
       // [self.view addSubview:scoreViewController.view];
        [self.view addSubview:gaugeView];
        
        NSArray *imageNames = @[@"bell_1.png", @"bell_2.png", @"bell_3.png", @"bell_2.png",@"bell_1.png"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i = 0; i < imageNames.count; i++) {
            [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        }
        bellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(gaugeView.frame.origin.x, gaugeView.frame.origin.y-50, 100, 100)];
        bellImageView.animationImages = images;
        bellImageView.animationDuration = 0.7;
        
        [self.view addSubview:bellImageView];
        peakholdImageView=[[Draggable alloc]initWithImage:[UIImage imageNamed:@"PeakHoldArrow.png"]];
        CGRect peakframe=peakholdImageView.frame;
        // peakframe.origin.x=-100;
        peakframe.origin.y=900;
        peakframe.origin.x=251;
        
        [peakholdImageView setFrame:peakframe];
        peakholdImageView.delegate=self;
        // [gaugeView addSubview:peakholdImageView];
        //  self.view.userInteractionEnabled=NO;
        [self.view addSubview:peakholdImageView];
        gaugeView.arrow=peakholdImageView;
        
        
        
     //   self.addGameQueue=[[NSOperationQueue alloc]init];
        self.btleManager=[BTLEManager new];
        self.btleManager.delegate=self;
        [self.btleManager startWithDeviceName:@"GroovTube" andPollInterval:0.1];
        [self.btleManager setRangeReduction:2];
        [self.btleManager setTreshold:60];
       // [self startSession];
        
        
        
        currentlyExhaling = false;
        [gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
        
        
         [gaugeView start];

    }
    return self;
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSLog(@"changing pickerView 0");
	
    int amount;
    
    if (thePickerView==pickerViewA) {
        amount=(int)[arrayA count];
    }
    if (thePickerView==pickerViewB) {
        amount=(int)[arrayB count];
    }
    if (thePickerView==pickerViewC) {
        amount=(int)[arrayC count];
    }
    if (thePickerView==filterPicker) {
        amount=(int)[filterArray count];
    }
    
	return amount;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSLog(@"changing pickerView 1");
    
    NSString *thetitle;
    
    if (thePickerView==pickerViewA) {
       thetitle=[arrayA objectAtIndex:row];
    }
    if (thePickerView==pickerViewB) {
        thetitle=[arrayB objectAtIndex:row];
    }
    if (thePickerView==pickerViewC) {
        thetitle=[arrayC objectAtIndex:row];
    }
    if (thePickerView==filterPicker) {
        thetitle=[filterArray objectAtIndex:row];
    }
	return thetitle;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"changing thePickerView 2 ");
	
    int rowint=(int)row;
    if (thePickerView==pickerViewA) {
        //NSLog(@"Selected : %@. Index of selected color: %i", [arrayA objectAtIndex:row], row);
        
        [self valueASend:rowint];
    }
    if (thePickerView==pickerViewB) {
       // NSLog(@"Selected : %@. Index of selected color: %i", [arrayB objectAtIndex:row], row);
        [self valueBSend:rowint];
    }
    
    if (thePickerView==pickerViewC) {
       // NSLog(@"Selected : %@. Index of selected color: %i", [arrayC objectAtIndex:row], row);
        [self valueCSend:rowint];
    }
    
    if (thePickerView==filterPicker) {
        //NSLog(@"Selected : %@. Index of selected color: %i", [filterArray objectAtIndex:row], row);
        [self.settinngsDelegate setFilter:rowint];
    }

}

-(IBAction)changeRate:(id)sender

{
    NSLog(@"changing rate");
    UISlider  *slider=(UISlider*)sender;
    [self.settinngsDelegate setRate:slider.value];
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
    
    [self.delegate exitSettingsViewController];
}

-(void)valueASend:(NSInteger)index
{
    int note =0;
    switch (index) {
        case 0:
            note=12;
            break;
        case 1:
            note=14;

            break;
        case 2:
            note=16;

            break;
            
        default:
            break;
    }
    
    [self.settinngsDelegate sendValue:note onoff:0];
}

-(void)valueBSend:(NSInteger)index
{
    int note =0;
    switch (index) {
        case 0:
            note=24;
            break;
        case 1:
            note=26;
            
            break;
        case 2:
            note=28;
            
            break;
        case 3:
            note=29;
            
            break;
            
        default:
            break;
    }
    
    
    [self.settinngsDelegate sendValue:note onoff:0];
}
-(void)valueCSend:(NSInteger)index
{
    int note =0;
    switch (index) {
        case 0:
            note=36;
            break;
        case 1:
            note=38;
            
            break;
        case 2:
            note=40;
            
            break;
        case 3:
            note=41;
            
            break;
            
        default:
            break;
    }
    [self.settinngsDelegate sendValue:note onoff:0];
}

//TEST

-(void)btleManagerBreathBegan:(BTLEManager*)manager{
 //   self.date=[NSDate date];
    
    //  NSLog(@"MIDINOTEBGAN currentlyexhaling == %d", currentlyExhaling);
    //  NSLog(@"MIDINOTEBGAN currentlyInhaling == %d", currentlyInhaling);
    
    //  if ((currentlyExhaling == true && midiController.toggleIsON )|| (currentlyInhaling == true && midiController.toggleIsON == false)){
    
    [self midiNoteBegan:nil];
    //  }else{
    // }
}
-(void)btleManagerBreathStopped:(BTLEManager*)manager{
    [self midiNoteStopped:nil];
}

-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax
{
    currentlyExhaling = false;
    currentlyInhaling = true;
    
    [gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
    
    if (midiController.toggleIsON==NO) {
        return;
    }
    
    float  vel=127.0*percentOfmax;;
    
    if (vel<threshold) {
        return;
    }
    if (vel==127) {
        return;
    }
    float scale=50.0f;
    float value=vel*scale;
    [gaugeView setForce:(value)];
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

-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax{
    
    currentlyExhaling = true;
    currentlyInhaling = false;
    
    //-(void)setBreathToggleAsExhale:(bool)value isExhaling: (bool)value2;
    [gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
    
    if (midiController.toggleIsON) {
        return;
    }
    
    float  vel=127.0*percentOfmax;;
    
    if (vel<threshold) {
        return;
    }
    if (vel==127) {
        return;
    }
    
    ///NSLog(@"VEL IS %f", vel);
    
    float scale=50.0f;
    float value=vel*scale;
    [gaugeView setForce:(value)];
    NSDate  *date=[NSDate date];
    
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
            [gaugeView setMass:1];
            break;
            
        case 1:
            [gaugeView setMass:2];
            
            break;
        case 2:
            [gaugeView setMass:2.5];
            
            break;
            
        case 3:
            [gaugeView setMass:3];
            
            break;
            
        default:
            break;
    }
}

//MORETEST

-(void)draggable:(Draggable *)didDrag
{
    //900-330
    CGRect  frame=didDrag.frame;
    [gaugeView setBestDistanceWithY:900-frame.origin.y];
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
    [gaugeView blowingEnded];
    [self endCurrentSession];
    [timer invalidate];
}
-(IBAction)touchAccelerateDown:(id)sender
{
    [self beginNewSession];
    
    [gaugeView blowingBegan];
    timer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(simulateBlow) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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
    
    if (gaugeView.animationRunning) {
        dispatch_async(dispatch_get_main_queue(), ^{
         //   [_debugTextField setText:@"\nMidi Began"];
        });
        [self beginNewSession];
        [gaugeView blowingBegan];
    }
}

-(void)midiNoteStopped:(MidiController*)midi
{
    if (gaugeView.animationRunning) {
        [self sendLogToOutput:@"\nMidi Stop"];
        [gaugeView blowingEnded];
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
        [gaugeView setForce:(value)];
        NSDate  *date=[NSDate date];
        
    //    if (vel>[currentSession.sessionStrength intValue]) {
     //       currentSession.sessionStrength=[NSNumber numberWithInt:vel];
             [gaugeView setArrowPos:0];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString  *string=[NSString stringWithFormat:@"\n %@",log];
  //      _debugTextField.text =[_debugTextField.text stringByAppendingString:string];
    });
}

#pragma mark -
#pragma mark - Session Controls
-(void)beginNewSession
{
    if (!sessionRunning) {
        sessionRunning=YES;
    //    currentSession=[[Session alloc]init];
     //   self.date=[NSDate date];
     //   currentSession.sessionDate=self.date;
     ///   currentSession.username=[[NSUserDefaults standardUserDefaults]valueForKey:@"currentusername"];
    }
}

-(void)endCurrentSessionTest
{
    
}
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
    [midiController pause];
  //  if (particleEffect) {
  ///      dispatch_async(dispatch_get_main_queue(), ^{
 //           [particleEffect removeFromSuperview];
 //           particleEffect=nil;
 //       });
   // }
  //  particleEffect = [UIEffectDesignerView effectWithFile:@"sparks.ped"];
    ///CGRect frame=particleEffect.frame;
  //  frame.origin.x=(self.view.bounds.size.width/2)-50;
  //  frame.origin.y=gaugeView.frame.origin.y-40;
  //  particleEffect.frame=frame;
   // [self.view addSubview:particleEffect];
   // effecttimer=[NSTimer timerWithTimeInterval:4 target:self selector:@selector(killSparks) userInfo:nil repeats:NO];
   // [[NSRunLoop mainRunLoop] addTimer:effecttimer forMode:NSDefaultRunLoopMode];
   // [self playSound];
    //[bellImageView startAnimating];
   // [logoviewcontroller startAnimating];
    // [loginViewController updateUserStats:currentSession];
    
    //
   // [highScoreViewController updateWithCurrentSession:currentSession];
}

-(void)killSparks
{
    
    NSLog(@"KILL SPARKS");
 //   dispatch_async(dispatch_get_main_queue(), ^{
 //       [particleEffect removeFromSuperview];
 ///       particleEffect=nil;
 //   });
[midiController resume];
    [self midiNoteStopped:midiController];
    [effecttimer invalidate];
   effecttimer=nil;

    [gaugeView start];
    [bellImageView stopAnimating];
 //   [logoviewcontroller stopAnimating];
    
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

-(void)sendValue:(int)note onoff:(int)onoff
{
    [midiController sendValue:note onoff:onoff];
}

@end
