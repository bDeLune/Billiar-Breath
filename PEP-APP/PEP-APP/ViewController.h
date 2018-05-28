#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "GameViewController.h"
#import "SettingsViewController.h"
#import "MasterViewController.h"

@interface ViewController : UITabBarController<LoginProtocol, GameViewProtocol, SettingsViewProtocol>

@end
