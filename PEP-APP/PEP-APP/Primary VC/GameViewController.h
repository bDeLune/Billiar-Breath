#import <UIKit/UIKit.h>
#import "User.h"
#import "Game.h"
#import "Gauge.h"
#import "AbstractGame.h"
#import "MidiController.h"
#import "GPUImage.h"

@protocol SETTINGS_DELEGATE
-(void)sendValue:(int)note onoff:(int)onoff;
-(void)setFilter:(int)index;
-(void)setRate:(float)value;
-(void)setThreshold:(float)value;
-(void)setBTTreshold:(float)value;
-(void)setBTBoost:(float)value;
-(void)setRepetitionCount:(NSString*)value;
-(void)setImageSoundEffect:(NSString*)value;
-(void)test:(float)value;
@end

@protocol GameViewProtocol <NSObject>
-(void)gameViewExitGame;
-(void)toSettingsScreen;
@end

@interface GameViewController : UIViewController<MidiControllerProtocol,GameProtocol,GaugeProtocol, SETTINGS_DELEGATE,UINavigationControllerDelegate,DraggableDelegate, UIImagePickerControllerDelegate, UITabBarDelegate>{
    
   // GPUImagePicture *sourcePicture;
    GPUImageOutput<GPUImageInput> *sepiaFilter, *sepiaFilter2;
    UISlider *imageSlider;
}

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

@end
