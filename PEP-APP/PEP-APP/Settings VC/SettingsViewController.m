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
    MidiController  *midiController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    NSTimer  *effecttimer;
    UIImageView  *bellImageView;
    UIImageView  *bg;
    Draggable  *peakholdImageView;
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
        currentlyExhaling = false;
    }
    return self;
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
    
    [self.settinngsDelegate settingsModeDismissRequest:self];
}
#pragma mark -
#pragma mark - Midi Delegate

-(void)setSettingsDurationLabelText: (NSString*)text  {
    
    NSLog(@"Settings duration label text %@", text);
    settingsDurationLabel.text = text;
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
