#import <UIKit/UIKit.h>
#import "GameViewController.h"

@protocol SettingsViewProtocol <NSObject>
-(void)exitSettingsViewController;
@end

@interface SettingsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate>
{
    IBOutlet UIPickerView *pickerViewA;
    IBOutlet UIPickerView *pickerViewB;
    IBOutlet UIPickerView *pickerViewC;
    IBOutlet UIPickerView *filterPicker;
    IBOutlet UISlider *rateSlider;
    IBOutlet UILabel  *thresholdLabel;
    IBOutlet UISlider *thresholdSlider;
    IBOutlet UILabel   *btTresholdLabel;
    IBOutlet UILabel   *btrangeBoost;
    IBOutlet UISlider  *btThresholdSlider;
    IBOutlet UISlider  *btBoostSlider;
	NSMutableArray *arrayA;
    NSMutableArray *arrayB;
    NSMutableArray *arrayC;
    NSMutableArray *filterArray;
    id<SETTINGS_DELEGATE> __unsafe_unretained settinngsDelegate;
}

@property (unsafe_unretained) id<SETTINGS_DELEGATE> settinngsDelegate;
@property(nonatomic,unsafe_unretained)id<SettingsViewProtocol>delegate;
-(IBAction)changeRate:(id)sender;
-(IBAction)changeThreshold:(id)sender;
-(IBAction)changeBTTreshold:(id)sender;
-(IBAction)changeBTBoostValue:(id)sender;

@end
