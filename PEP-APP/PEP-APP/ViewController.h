#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "GameViewController.h"
#import "SettingsViewController.h"

@interface ViewController : UIViewController<LoginProtocol, GameViewProtocol, SettingsViewProtocol>

@end
