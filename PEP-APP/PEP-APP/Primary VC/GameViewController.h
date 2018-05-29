#import <UIKit/UIKit.h>
#import "User.h"
#import "Game.h"
#import "MainGauge.h"
#import "Gauge.h"
#import "AbstractGame.h"
#import "MidiController.h"
#import "GPUImage.h"
@class SettingsViewController;

#define THUMBNAIL_SIZE 30
#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 400

@protocol SETTINGS_DELEGATE
-(void)sendValue:(int)note onoff:(int)onoff;
-(void)setFilter:(int)index;
-(void)setRate:(float)value;
-(void)setThreshold:(float)value;
-(void)setBTTreshold:(float)value;
-(void)setBTBoost:(float)value;
-(void)setRepetitionCount:(int)value;
-(void)setBreathLength:(float)value;
-(void)setImageSoundEffect:(NSString*)value;
-(void)test:(float)value;
-(void)setSpeed:(float)value;
//-(void)settingsModeDismissRequest:(SettingsViewController*)caller;
-(void)returnToGameView;
-(void)settingsModeDismissRequest:(SettingsViewController*)caller;
-(void)settingsModeToUser:(SettingsViewController*)caller;
@end

@protocol GameViewProtocol <NSObject>
-(void)gameViewExitGame;
-(void)toSettingsScreen;
@end

@interface GameViewController : UIViewController<MidiControllerProtocol,GameProtocol,MainGaugeProtocol,  SETTINGS_DELEGATE,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate >{
    
    
    GPUImageOutput<GPUImageInput> *sepiaFilter, *sepiaFilter2;
    UISlider *imageSlider;
    
    NSInteger chosenImage;
    IBOutlet UIViewController *chosenImageController;
    IBOutlet UIImageView *chosenImageView;
}

@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property(nonatomic,weak)IBOutlet  UIButton  *backToLoginButton;
@property (weak, nonatomic) IBOutlet UIProgressView *breathStrengthBar;
@property(nonatomic,weak)IBOutlet  UIButton *toggleDirectionButton;
@property(nonatomic,weak)IBOutlet  UIButton *toggleGameModeButton;
@property(nonatomic,weak)IBOutlet  UIButton *resetGameButton;
@property(nonatomic,weak)IBOutlet  UIButton  *settingsButton;
@property(nonatomic,weak)IBOutlet  UIButton  *testDurationButton;
//@property(nonatomic,weak)IBOutlet  UIImageView  *background;
@property(nonatomic,weak)IBOutlet  UILabel  *targetLabel;
@property(nonatomic,weak)IBOutlet  UILabel  *durationLabel;
@property(nonatomic,weak)IBOutlet  UILabel  *speedLabel;
@property(nonatomic,strong) SettingsViewController  *settingsViewController;
@property(nonatomic,weak)IBOutlet  UILabel  *strenghtLabel;
@property(nonatomic,weak)IBOutlet  UILabel *currentUsersNameLabel;
@property(nonatomic,weak)IBOutlet  UITextView *debugtext;
//@property(nonatomic,weak)IBOutlet  UIButton  *usersButton;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *gameUser;
@property(nonatomic,unsafe_unretained)id<GameViewProtocol, UITabBarDelegate>delegate;  //change

@property int midiinhale;
@property int midiexhale;
@property float velocity;
@property float animationrate;
@property(nonatomic,strong)IBOutlet UISlider  *testSlider;
-(IBAction)sliderchanged:(id)sender;
@property BOOL midiIsOn;
@property(nonatomic,strong) UITextView  *outputtext;
@property  dispatch_source_t  aTimer;
@property(nonatomic,strong)IBOutlet  UITextView  *textarea;
-(void)continueMidiNote:(int)pvelocity;
-(void)stopMidiNote;
-(void)midiNoteBegan:(int)direction vel:(int)pvelocity;
-(void)makeTimer;
-(void)background;
-(void)foreground;
-(void)setLabels;

@property (weak, nonatomic) IBOutlet UIImageView *bluetoothIcon; 
@property (weak, nonatomic) IBOutlet UIButton *soundIcon;
@property (weak, nonatomic) IBOutlet UIButton *photoPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *HQPhotoPickerButton;

-(void)dismissSettingsMode:(id <SETTINGS_DELEGATE>)dismiss;
-(void)settingsModeToUser:(id <SETTINGS_DELEGATE>)dismiss;
-(IBAction)toUsersScreen:(id)sender;
-(IBAction)exitGameScreen:(id)sender;
-(IBAction)toggleDirection:(id)sender;
-(IBAction)toggleGameMode:(id)sender;
-(IBAction)presentSettings:(id)sender;
-(IBAction)resetGame:(id)sender;
//@property (weak, nonatomic) IBOutlet UITabBarItem *changeGameMode;
//@property (weak, nonatomic) IBOutlet UITabBarItem *goToUsersScreen;
-(IBAction)testButtonDown:(id)sender;
-(IBAction)testButtonUp:(id)sender;
// Image filtering
- (void)setupDisplayFiltering;
- (void)setupImageFilteringToDisk;
- (void)setupImageResampling;
- (IBAction)updateSliderValue:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *breathGauge;


@property (nonatomic, retain) IBOutlet UIViewController *chosenImageController;
@property (nonatomic, retain) IBOutlet UIImageView *chosenImageView;
@end
