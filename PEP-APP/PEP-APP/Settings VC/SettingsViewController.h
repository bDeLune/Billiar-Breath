#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "SettingsViewGauge.h"

@interface SettingsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate, GaugeProtocol, SETTINGS_DELEGATE>
{
    IBOutlet UISlider *speedSlider;
    IBOutlet UISlider *breathLengthSlider;
    IBOutlet UIPickerView *pickerViewB;
    IBOutlet UILabel *settingsStrengthLabel;
    IBOutlet UILabel *settingsDurationLabel;
    IBOutlet UIImageView *whiteBackground;
    IBOutlet UIPickerView *pickerViewC;
    IBOutlet UIImageView *backgroundImage;
    IBOutlet UIPickerView *filterPicker;
    IBOutlet UILabel *breathLengthLabel;
    IBOutlet UISlider *rateSlider;
    IBOutlet UILabel  *thresholdLabel;
    IBOutlet UISlider *thresholdSlider;
    IBOutlet UILabel  *btTresholdLabel;
    IBOutlet UILabel  *btrangeBoost;
    IBOutlet UISlider *btThresholdSlider;
    IBOutlet UISlider *btBoostSlider;
    NSMutableArray *imageGameSoundArray;
    NSMutableArray *repititionsArray;
    NSMutableArray *filterArray;
    NSMutableArray *imageGameSoundFileNameArray;
    NSMutableArray *filterFileNameArray;
    int currentdirection;
    id<SETTINGS_DELEGATE> __unsafe_unretained settinngsDelegate;
}
@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property(nonatomic,strong)SettingsViewGauge  *gaugeView;

-(void) setSettingsStrengthLabelText:(NSString*)text;
-(void) setSettingsDurationLabelText:(NSString*)text;
-(void) setGaugeForce:(float)force;
-(void) setSettingsViewDirection:(int)val;
-(void) setGaugeSettings: (int)breathToggle exhaleToggle:(BOOL)ex;
-(void)setUIState:(int)picker toNo:(int)indexNo;
@end
