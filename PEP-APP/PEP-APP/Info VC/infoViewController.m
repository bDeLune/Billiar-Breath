#import "infoViewController.h"

@interface infoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *returnToGameView;
@end

@implementation infoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)returnToGameView:(id)sender {
    NSLog(@"Returning to game view");
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
