#import "GameViewController.h"
#import "SettingsViewController.h"
#import "UserListViewController.h"
#import "InfoViewController.h"

@interface MainTableViewController:UITabBarController

@property(nonatomic,strong) UserListViewController *userListViewController;
@property(nonatomic,strong) GameViewController  *gameViewController;
@property(nonatomic,strong) InfoViewController  *infoViewController;
@property(nonatomic,strong) SettingsViewController *settingsViewController;
@property(nonatomic,strong) UITableView *tableview;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate= self;
    }
    
    if (!self.settingsViewController) {
        self.settingsViewController=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    }
    
    if (!self.infoViewController) {
        self.infoViewController=[[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
    }
    
    if (!self.userListViewController) {
        self.userListViewController=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
    }
    
    self.gameViewController.settingsViewController = self.settingsViewController;
    self.settingsViewController.delegate=self.gameViewController;
    [self.settingsViewController setSettinngsDelegate:self.gameViewController];
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:self.gameViewController];
    [tabViewControllers addObject:self.settingsViewController];
    [tabViewControllers addObject:self.userListViewController];
    [tabViewControllers addObject:self.infoViewController];
    
    [self setViewControllers:tabViewControllers];
    self.gameViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"GameViewController"
                                  image:[UIImage imageNamed:@"PEP-App-INACTIVE-80x80"]
                                    tag:1];
    self.settingsViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"SettingsViewController"
                                  image:[UIImage imageNamed:@"Settings-INACTIVE-80x80"]
                                    tag:2];
    self.userListViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"UserListViewController"
                                  image:[UIImage imageNamed:@"Users-INACTIVE-80x80"]
                                    tag:3];
    self.infoViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"InfoViewController"
                                  image:[UIImage imageNamed:@"Info-INACTIVE-80x80"]
                                    tag:4];
    
    UIImage *image = [[UIImage imageNamed:@"Info-INACTIVE-80x80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.infoViewController.tabBarItem setSelectedImage:image];
    [self.infoViewController.tabBarItem setImage:image];
    
    UIImage *image2 = [[UIImage imageNamed:@"Settings-INACTIVE-80x80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.settingsViewController.tabBarItem setSelectedImage:image2];
    [self.settingsViewController.tabBarItem setImage:image2];
    
    UIImage *image3 = [[UIImage imageNamed:@"Users-INACTIVE-80x80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.userListViewController.tabBarItem setSelectedImage:image3];
    [self.userListViewController.tabBarItem setImage:image3];
    
    UIImage *image4 = [[UIImage imageNamed:@"PEP-App-INACTIVE-80x80"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.gameViewController.tabBarItem setSelectedImage:image4];
    [self.gameViewController.tabBarItem setImage:image4];
    
    self.infoViewController.tabBarItem.title = @"";
    self.userListViewController.tabBarItem.title = @"";
    self.settingsViewController.tabBarItem.title = @"";
    self.gameViewController.tabBarItem.title = @"";
    self.delegate = self;
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 130;
    tabFrame.origin.y = self.view.frame.size.height - 110;
    self.tabBar.frame = tabFrame;
    [self.tabBar setItemPositioning:UITabBarItemPositioningFill];
}

-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user{
    NSLog(@"setting memory info");
    self.gameViewController.gameUser=user;
    [self.gameViewController setLabels];
    self.gameViewController.sharedPSC=store;
    self.userListViewController.sharedPSC=store;
    [self.userListViewController getListOfUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableview =tableView;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    //[self.userListViewController.detailViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"selected index : %i",[tabBarController selectedIndex]);
    if ([tabBarController selectedIndex] == 1){
        
    }
}

@end
