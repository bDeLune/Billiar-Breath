#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "Gauge.h"

@protocol SettingsViewProtocol <NSObject>
-(void)exitSettingsViewController;
@end

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
	//NSMutableArray *arrayA;
    NSMutableArray *imageGameSoundArray;
    NSMutableArray *repititionsArray;
    NSMutableArray *filterArray;
    id<SETTINGS_DELEGATE> __unsafe_unretained settinngsDelegate;
}

@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property(nonatomic,unsafe_unretained)id<SettingsViewProtocol>delegate;
@property(nonatomic,strong)Gauge  *gaugeView;
+(Gauge*) getSettingsGauge;
-(IBAction)changeRate:(id)sender;
-(IBAction)changeThreshold:(id)sender;
-(IBAction)changeBTTreshold:(id)sender;
-(IBAction)changeBTBoostValue:(id)sender;
-(void)setSettingsStrengthLabelText: (NSString*)text;
-(void)setSettingsDurationLabelText: (NSString*)text;
//-(void)testGaugeInhale: (float)percent;
//-(void)testGaugeExhale: (float)percent;
//-(void)testGaugeBegan;
//-(void)testGaugeStopped;
@end
