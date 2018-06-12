#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "SettingsViewController.h"
#import "InfoViewController.h"
#import "BTLEManager.h"
#import "Session.h"
#import "UIEffectDesignerView.h"

@interface SettingsViewController ()<UITabBarDelegate, BTLEManagerDelegate, MidiControllerProtocol>{
    UINavigationController   *navcontroller;
    MidiController  *midiController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    NSTimer  *effecttimer;
   // UIImageView  *bellImageView;
    UIImageView  *bg;
    int threshold;
    AVAudioPlayer *audioPlayer;
    UIButton  *togglebutton;
    BOOL   toggleIsON;
    int midiinhale;
    int midiexhale;
    //int currentdirection;
    int inorout;
    bool currentlyExhaling;
    bool currentlyInhaling;
}
@property (weak, nonatomic) IBOutlet UIButton *toggleDirectionButton;
//@property(nonatomic, assign) int currentdirection;
@property(nonatomic,strong) BTLEManager  *btleManager;
@end

@implementation SettingsViewController
@synthesize settinngsDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"INITIATED SETTINGS MODE");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if (self) {
        self.title = @"Settings";
        imageGameSoundArray=[NSMutableArray arrayWithObjects:@"Ballon",@"schuiffluit",@"spaceship",@"Bas slide",@"bell synth", @"droom", @"sirene fluit", @"xylofoon", @"Toy Piano", @"harp", nil];
        repititionsArray=[NSMutableArray arrayWithObjects: @"1",@"2",@"3", @"4",@"5",@"6",@"7",@"8", nil];
        filterArray=[NSMutableArray arrayWithObjects:
                     @"Bulge",@"Swirl",@"Blur",@"Toon",
                     @"Expose",@"Polka",
                     @"Posterize",@"Pixellate",@"Contrast", nil];
        
        self.gaugeView=[[SettingsViewGauge alloc]initWithFrame:CGRectMake(90, 155, 90, GUAGE_HEIGHT) ];
        self.gaugeView.GaugeDelegate=self;
        [self.view addSubview:self.gaugeView];
        [self.view sendSubviewToBack:self.gaugeView];
        [self.view sendSubviewToBack:whiteBackground];
        
        [self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
        [self.gaugeView start];
        
        NSLog(@"SETTING CURRENT DIRECTION AS %d, ", currentdirection);
        if (currentdirection == 1)
        {
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
        }else{
            [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
        }
            
            
        [speedSlider setValue:4 animated:YES];
        currentlyExhaling = false;
    }
    return self;
}

-(void) setGaugeForce: (float)force{
    
    NSLog(@"should be 3");
    [self.gaugeView setForce:force];
    
};

-(void)setSettingsViewDirection: (int)val{
    
    NSLog(@"SETTING DIRECTION SETTITNGS %d",val);
    if (val == 0){
        currentdirection = 0;
        NSLog(@"set to inhale");
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
    }else{
        NSLog(@"set to exhale");
        currentdirection = 1;
        
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"direction"];
    }
}

- (IBAction)toggleDirection:(id)sender {
    
    NSLog(@"toggling direction");
    
    if (currentdirection == 1){
        currentdirection = 0;
        NSLog(@"set to inhale");
        
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];

        [self.settinngsDelegate setDirection:0];
    }else{
        NSLog(@"set to exhale");
        currentdirection = 1;
        
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"inhale" forKey:@"direction"];
        
       [self.settinngsDelegate setDirection:1];
    }
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
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
    //int sliderValue = (int) slider.value;
    
    //[self.settinngsDelegate setBreathLength:slider.value];
    
    [self.settinngsDelegate setSpeed:slider.value];
    //[self setBreathLengthLabelText: [NSString stringWithFormat:@"%d",sliderValue]];
    //self.settingsViewController.delegate=self;
    //[self setSettinngsDelegate:self.gameViewController];
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
    
      //[UIView transitionFromView:self.view toView: gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
      //}];
    //
    //[self.settinngsDelegate settingsModeDismissRequest:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
   // [self.delegate exitSettingsViewController];
}


#pragma mark -
#pragma mark - Test Methods


#pragma mark -
#pragma mark - Midi Delegate

-(void)setSettingsDurationLabelText: (NSString*)text  {
    
   // NSLog(@"Settings duration label text %@", text);
    settingsDurationLabel.text = text;
}

-(void)setSettingsStrengthLabelText: (NSString*)text  {
    
  //  NSLog(@"Settings strength label text %@", text);
    settingsStrengthLabel.text = text;
}

-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"bell synth" ofType:@"wav"];
    NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                error:&error];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

@end
