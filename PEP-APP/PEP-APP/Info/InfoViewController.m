#import "InfoViewController.h"

@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *returnToGameView;
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)returnToGameView:(id)sender {
    NSLog(@"Returning to game view");
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)goToWebsite:(id)sender {
    
    NSLog(@"Moving to website");
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.google.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
