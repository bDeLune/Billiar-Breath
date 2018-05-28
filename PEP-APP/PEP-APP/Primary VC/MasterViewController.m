//
//  TableViewController.m
//  GPUImage
//
//  Created by Brian Dillon on 28/05/2018.
//  Copyright © 2018 Brad Larson. All rights reserved.
//
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
    
    //CGRect bounds = [tableView bounds];
    //[self setBounds:CGRectMake(bounds.origin.x,
                                   // bounds.origin.y,
                                   // bounds.size.width,
                                   // bounds.size.height + 20)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate= self;
    }
    
    if (!self.settingsViewController) {
        self.settingsViewController=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
        //  self.settingsViewController.delegate= self;
    }
    
    if (!self.infoViewController) {
        self.infoViewController=[[InfoViewController alloc]initWithNibName:@"InfoViewController" bundle:nil];
        //self.infoViewController.delegate= self;
    }
    
    if (!self.userListViewController) {
        self.userListViewController=[[UserListViewController alloc]initWithNibName:@"UserListViewController" bundle:nil];
        //  self.userListViewController.delegate= self;
    }
    

    
    self.gameViewController.settingsViewController = self.settingsViewController;

    self.settingsViewController.delegate=self.gameViewController;
    [self.settingsViewController setSettinngsDelegate:self.gameViewController];
    ///----
    // [UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){
    
    
    
    
    ///------
    //[[self.gameViewController settingsViewController] setSettinngsDelegate:self.gameViewController];
    // self.settingsViewController.delegate=self;
    
    // [self.settingsViewController setSettinngsDelegate:self.gameViewController];
    // [self.view addSubview:self.settingsViewController.view];
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:self.gameViewController];
    [tabViewControllers addObject:self.settingsViewController];
    [tabViewControllers addObject:self.userListViewController];
    [tabViewControllers addObject:self.infoViewController];
    
    [self setViewControllers:tabViewControllers];
    //can't set this until after its added to the tab bar
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
    //self.gameViewController.sharedPSC=self.persistentStoreCoordinator;
    self.gameViewController.sharedPSC=store;
    //[self.gameViewController resetGame:nil];
    
    self.userListViewController.sharedPSC=store;
    
    [self.userListViewController getListOfUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    
    self.tableview =tableView;
    CGRect bounds = [self.tableview bounds];
    [self.tableview setBounds:CGRectMake(bounds.origin.x,
                                                    bounds.origin.y,
                                                    bounds.size.width,
                                                    bounds.size.height + 20)];
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    NSLog(@"selected index : %i",[tabBarController selectedIndex]);
    
    if ([tabBarController selectedIndex] == 1){
        
        

        
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
