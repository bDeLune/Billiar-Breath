#import "InfoViewController.h"

@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *returnToGameView;
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.infoViewBackgroundImage setImage: [UIImage imageNamed:NSLocalizedString(@"InfoBackground", nil)]];
    [self.externalURLButton setImage: [UIImage imageNamed:NSLocalizedString(@"externalURLButton", nil)]forState:UIControlStateNormal];
}
- (IBAction)returnToGameView:(id)sender {
    NSLog(@"Returning to game view");
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)goToWebsite:(id)sender {
    NSLog(@"Moving to website");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:NSLocalizedString(@"manualURL", nil)]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
