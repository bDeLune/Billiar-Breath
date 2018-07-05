#import "GameViewController.h"
#import "SettingsViewController.h"
#import "UserListViewController.h"
#import "InfoViewController.h"

@interface MainTableViewController:UITabBarController

@property(nonatomic,strong) UserListViewController *userListViewController;
@property(nonatomic,strong) GameViewController  *gameViewController;
@property(nonatomic,strong) InfoViewController  *infoViewController;
@property(nonatomic,strong) SettingsViewController *settingsViewController;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) UITableView *tableview;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate = self;
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
    //self.settingsViewController.delegate = self.gameViewController;
    [self.settingsViewController setSettinngsDelegate:self.gameViewController];
    [self.gameViewController prepareDisplay]; //todo: prepare imageview
    
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

-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user withManagedObjectContext:(NSManagedObjectContext*)moc{
    NSLog(@"setting memory info");
    self.gameViewController.gameUser=user;
    [self.gameViewController setLabels];
    self.gameViewController.sharedPSC=store;
    self.userListViewController.sharedPSC=store;
    [self.userListViewController getListOfUsers];

    self.managedObjectContext = moc;
}

-(void)saveUserSettings {
    
    NSLog(@"Saving user settings");
    NSString *direction=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultDirection"];
    NSNumber *defaultSpeed=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSpeed"];
    NSNumber *defaultRepetitions=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultRepetitions"];
    NSString *defaultSound=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultSound"];
    NSNumber *defaultEffect=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultEffect"];
    NSNumber *defaultMute=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultMute"];
    
    //NSInteger* defaultSpeed = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultSpeed"];
    //NSString *defaultSound = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultSound"];
    //NSInteger* defaultRepetitions = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultRepetitions"];
   // NSString* direction = [[NSUserDefaults standardUserDefaults]stringForKey:@"defaultDirection"];
   /// NSInteger *defaultEffect = [[NSUserDefaults standardUserDefaults]integerForKey:@"defaultEffect"];
   // NSNumber *defaultMute=[[NSUserDefaults standardUserDefaults]objectForKey:@"defaultMute"];
    
    NSLog(@"direction %@", direction);
    NSLog(@"defaultSpeed %@", defaultSpeed);
    NSLog(@"defaultRepetitions %@", defaultRepetitions);
    NSLog(@"defaultSound %@", defaultSound);
    NSLog(@"defaultEffect %@", defaultEffect);
    NSLog(@"defaultMute %@", defaultMute);
    
    NSString  *name=[self.gameViewController.gameUser valueForKey:@"userName"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    //[fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entity];
    NSLog(@"pred %@", name);
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];

    User *user = items[0];
    
    NSLog(@"user %@", user);
    [user setValue:direction forKey:@"defaultDirection"];
    [user setValue:defaultSpeed forKey:@"defaultSpeed"];
    [user setValue:defaultRepetitions forKey:@"defaultRepetitions"];
    [user setValue:defaultSound forKey:@"defaultSound"];
    [user setValue:defaultMute forKey:@"defaultMute"];
    [user setValue:defaultEffect forKey:@"defaultEffect"];
    
   // user.direction = direction;
    //user.defaultSpeed = defaultSpeed;
    //user.defaultRepetitions = defaultRepetitions;
    //user.defaultSound = defaultSound;
    //user.defaultEffect = defaultEffect;
   // user.defaultMute = defaultMute;
    //[appdelegate saveContext];
    

    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during developmeint. If it is not possible to recover from the error, display an alerto
            // panel that instructs the user to quit the application by pressing the Home button.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
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

    [self saveUserSettings];
    
    NSLog(@"selected index : %i",[tabBarController selectedIndex]);
    if ([tabBarController selectedIndex] == 1){
    
    }
}

@end
