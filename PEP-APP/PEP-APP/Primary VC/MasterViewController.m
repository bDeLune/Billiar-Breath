#import "GameViewController.h"
#import "SettingsViewController.h"
#import "UserListViewController.h"
#import "InfoViewController.h"

@interface MasterViewController:UITabBarController

@property(nonatomic,strong) UserListViewController  *userListViewController;
@property(nonatomic,strong) GameViewController  *gameViewController;
@property(nonatomic,strong) InfoViewController  *infoViewController;
@property(nonatomic,strong) SettingsViewController *settingsViewController;
@property(nonatomic,strong) UITableView *tableview;
@end

@implementation MasterViewController

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
                                  image:[UIImage imageNamed:@"PEP-App-ACTIVE"]
                                    tag:1];
    self.settingsViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"SettingsViewController"
                                  image:[UIImage imageNamed:@"Settings-ACTIVE"]
                                    tag:2];
    self.userListViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"UserListViewController"
                                  image:[UIImage imageNamed:@"Users-ACTIVE"]
                                    tag:3];
    self.infoViewController.tabBarItem =
    [[UITabBarItem alloc] initWithTitle:@"InfoViewController"
                                  image:[UIImage imageNamed:@"Info-ACTIVE"]
                                    tag:4];
    
    self.delegate = self;
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 140;
    tabFrame.origin.y = self.view.frame.size.height - 110;
    self.tabBar.frame = tabFrame;
    
    self.tabBar.itemSpacing = 100;
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
    CGRect bounds = [self.tableview bounds];
    [self.tableview setBounds:CGRectMake(bounds.origin.x,
                                                    bounds.origin.y,
                                                    bounds.size.width,
                                                    bounds.size.height + 20)];
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    NSLog(@"selected index : %i",[tabBarController selectedIndex]);
    if ([tabBarController selectedIndex] == 1){
        
    }
}

@end
