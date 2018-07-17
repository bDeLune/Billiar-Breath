#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "SettingsViewController.h"
#import "InfoViewController.h"
#import "BTLEManager.h"
#import "Session.h"

@interface SettingsViewController ()<UITabBarDelegate, BTLEManagerDelegate, MidiControllerProtocol>{
    UINavigationController   *navcontroller;
    MidiController  *midiController;
    NSTimer  *timer;
    BOOL  sessionRunning;
    NSTimer  *effecttimer;
    int threshold;
    AVAudioPlayer *audioPlayer;
    UIButton  *togglebutton;
    BOOL   toggleIsON;
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
        imageGameSoundFileNameArray=[NSMutableArray arrayWithObjects: @"Ballon",@"schuiffluit",@"spaceship",@"scheet",@"Bas slide",@"bell synth", @"droon", @"sirene fluit", @"xylofoon", @"Toy Piano", @"harp", nil];
        imageGameSoundArray=[NSMutableArray arrayWithObjects:
        [NSString stringWithFormat:NSLocalizedString(@"Ballon", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Schuiffluit", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Spaceship", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Scheet", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Bas Slide", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Bel Synth", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Droon", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Sirene Fluit", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Xylofoon", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Toy Piano", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Harp", nil)],
        nil];
        
        repititionsArray=[NSMutableArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil];
        
        filterFileNameArray=[NSMutableArray arrayWithObjects:
                     @"Bulge",@"Swirl",@"Blur",@"Toon",
                     @"Expose",@"Polka",
                     @"Posterize",@"Pixellate",@"Contrast", nil];
        
        filterArray=[NSMutableArray arrayWithObjects:
        [NSString stringWithFormat:NSLocalizedString(@"Bulge", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Swirl", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Blur", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Toon", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Expose", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Polka", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Posterize", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Pixellate", nil)],
        [NSString stringWithFormat:NSLocalizedString(@"Contrast", nil)],
        nil];
    

        
         NSLog(@"INITIATED SETTINGS MODE PART 2");
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"vew will appear");
    
    NSString* directionSetting = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultDirection"];
    if ([directionSetting isEqual: @"Inhale"]){
        currentdirection = 0;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        NSLog(@"DEFAULTS directionSetting inhale");
    }else if (!directionSetting || [directionSetting isEqual: @"Exhale"]){
        currentdirection = 1;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        NSLog(@"DEFAULTS directionSetting Exhale");
    }
    
    NSNumber* defaultSpeed = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultSpeed"];
    
    NSLog(@" SETTINGS VIEW : defaultSpeed %@", defaultSpeed);
    [speedSlider setValue:[defaultSpeed floatValue] animated:YES];
    
    
    NSLog(@" SETTINGS VIEW : defaultSpeed %@", defaultSpeed);
    
    //currentlyExhaling = false;
    //[self.gaugeView setBreathToggleAsExhale:currentlyExhaling isExhaling: midiController.toggleIsON];
    
    [self.gaugeView start];
}

-(void)viewWillDisappear:(BOOL)animated{
    
     NSLog(@"viewWillDisappear");
    [self.gaugeView stop];
}

-(void)viewDidLoad{
    
    NSLog(@"viewDidLoad");
    self.gaugeView=[[SettingsViewGauge alloc]initWithFrame:CGRectMake(90, 155, 90, GUAGE_HEIGHT) ];
    NSLog(@" SETTINGS VIEW : defaultSpeed222 %@", self.gaugeView);
    
    [self.view addSubview:self.gaugeView];
    [self.view sendSubviewToBack:self.gaugeView];
    [self.view sendSubviewToBack:pickerViewB];
    [self.view sendSubviewToBack:pickerViewC];
    [self.view sendSubviewToBack:filterPicker];
    [self.view sendSubviewToBack:whiteBackground];

    NSNumber *defaultRepetitionIndex=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultRepetitionIndex"];
    NSString *defaultSound=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSound"];
    NSNumber *defaultEffectIndex=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultEffect"];
    
    NSInteger repetitionIndex = [defaultRepetitionIndex integerValue];
    NSInteger effectIndex = [defaultEffectIndex integerValue];
    
    NSLog(@" SETTINGS VIEW : defaultSound %@", defaultSound);
    
    NSUInteger soundIndex;
    
    if ([defaultSound isEqualToString:@"sirene fluit"]){
        NSLog(@"default sound selected: sirene fluit");
        soundIndex = (int)7;
    }else{
        soundIndex = (int)[imageGameSoundArray indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
            return [obj caseInsensitiveCompare:defaultSound] == NSOrderedSame;
        }];
    }
    

    
    NSLog(@" SETTINGS VIEW : (int)soundIndex %d", (int)soundIndex);
    
    [filterPicker selectRow:effectIndex inComponent:0 animated:NO];
    [pickerViewC selectRow:repetitionIndex inComponent:0 animated:NO];
    [pickerViewB selectRow:soundIndex inComponent:0 animated:NO];
    
    NSLog(@" viewdid load endd");
}

-(void) setGaugeForce: (float)force{
    NSLog(@"should be 3");
    [self.gaugeView setForce:force];
};

-(void) setGaugeSettings: (int)breathToggle exhaleToggle:(BOOL)inhaleActivated{
    NSLog(@"settings inner set gauge settings");
    [self.gaugeView setBreathToggleAsExhale:breathToggle isExhaling: inhaleActivated];
    
    if (inhaleActivated == YES){
        currentdirection = 0;
        NSLog(@"set to inhale");
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        
    }else if (inhaleActivated == NO){
        NSLog(@"set to exhale");
        currentdirection = 1;
        
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
    }
};

-(void) setSettingsViewDirection: (int)val{
    [self setSettingsStrengthLabelText:@"0"];
    [self setSettingsDurationLabelText:@"0"];
    
    NSLog(@"SETTING DIRECTION SETTITNGS %d",val);
    if (val == 0){
        currentdirection = 0;
        NSLog(@"set to inhale");
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        
        [self.settinngsDelegate setDirection:0];
    }else{
        NSLog(@"set to exhale");
        currentdirection = 1;
        
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Exhale" forKey:@"defaultDirection"];
        
         [self.settinngsDelegate setDirection:1];
    }
}

- (IBAction)toggleDirection:(id)sender {
    
    [self setSettingsStrengthLabelText:@"0"];
    [self setSettingsDurationLabelText:@"0"];
    
    if (currentdirection == 1){
        currentdirection = 0;
        NSLog(@"set to inhale");
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-INHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        [self.settinngsDelegate setDirection:0];
    }else{
        NSLog(@"set to exhale");
        currentdirection = 1;
        [self.toggleDirectionButton setImage:[UIImage imageNamed:@"Settings-Button-EXHALE.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:@"Inhale" forKey:@"defaultDirection"];
        [self.settinngsDelegate setDirection:1];
    }
}

#pragma mark -
#pragma mark Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {

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
    NSString *thetitle;
    if (thePickerView==pickerViewB) {
       thetitle=[imageGameSoundArray objectAtIndex:row];
        NSString* defaultSaveName=[imageGameSoundFileNameArray objectAtIndex:row];
        [[NSUserDefaults standardUserDefaults]setObject:defaultSaveName forKey:@"defaultSound"];
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
    int rowint=(int)row;
    if (thePickerView==pickerViewB) {
        [self.settinngsDelegate setImageSoundEffect: [imageGameSoundFileNameArray objectAtIndex:row]];
    }
    
    if (thePickerView==pickerViewC) {
        NSInteger selectedValAsint = [[repititionsArray objectAtIndex:row] integerValue];
        [self.settinngsDelegate setRepetitionCount: selectedValAsint];
    }
    
    if (thePickerView==filterPicker) {
        [self.settinngsDelegate setFilter:rowint];
    }
}

//-(IBAction)changeRate:(id)sender
//{
//    NSLog(@"changing rate");
//    UISlider  *slider=(UISlider*)sender;
//    [self.settinngsDelegate setRate:slider.value];
//}

-(IBAction)setBreathLength:(id)sender
{
    NSLog(@"changing breath length");
    UISlider  *slider=(UISlider*)sender;
    [self.settinngsDelegate setSpeed:slider.value];
}

//-(IBAction)changeThreshold:(id)sender
//{
///    NSLog(@"changing threshold");
///    [self.settinngsDelegate setThreshold:thresholdSlider.value];
////    [thresholdLabel setText:[NSString stringWithFormat:@"%f",thresholdSlider.value]];
//}

///-(IBAction)changeBTTreshold:(id)sender
//{
//    NSLog(@"changing changeBTTreshold");
///    [self.settinngsDelegate setBTTreshold:btThresholdSlider.value];
///    [btTresholdLabel setText:[NSString stringWithFormat:@"%f",btThresholdSlider.value]];
//    [self.settinngsDelegate test:btThresholdSlider.value];
///}

////-(IBAction)changeBTBoostValue:(id)sender
///{
///    NSLog(@"changing changeBTBoostValue");
///    [self.settinngsDelegate setBTBoost:btBoostSlider.value];
//    [btrangeBoost setText:[NSString stringWithFormat:@"%f",btBoostSlider.value]];
///}

-(void)setSettingsDurationLabelText: (NSString*)text  {
    settingsDurationLabel.text = text;
   
}

-(void)setSettingsStrengthLabelText: (NSString*)text  {
    settingsStrengthLabel.text = text;
     NSLog(@"settingsStrengthLabel: %@", text);
}

@end
