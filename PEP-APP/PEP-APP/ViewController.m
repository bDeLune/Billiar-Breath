#import "ViewController.h"
#import "AddNewUserOperation.h"
#import "User.h"
#import "Game.h"
#import "MasterViewController.h"
//#import "GameViewController.h"
//#import "SettingsViewController.h"
#define GUAGE_HEIGHT 575
#import <AudioToolbox/AudioToolbox.h>
#import "BTLEManager.h"

typedef void(^RunTimer)(void);
@interface ViewController ()<BTLEManagerDelegate>
@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;
@property (nonatomic, retain) NSMutableArray *capturedImages;
@property(nonatomic,strong)BTLEManager  *btleMager;
@property(nonatomic,strong)UIImageView  *btOnOfImageView;
@property (assign) SystemSoundID tickSound;
@property(nonatomic,strong)UIButton *ledTestButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property(nonatomic,strong) LoginViewController  *loginViewController;
//@property(nonatomic,strong) GameViewController  *gameViewController;
@property(nonatomic,strong) MasterViewController  *masterViewController;
//@property(nonatomic,strong) SettingsViewController *settingsViewController;
@property(nonatomic,strong) User  *currentUser;
@property(nonatomic,strong) Game  *currentGame;
@property(nonatomic,strong) UIImageView *startupImageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserError:) name:kAddNewUserOperationUserError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserExistsError:) name:kAddNewUserOperationUserExistsError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserSuccess:) name:kAddNewUserOperationUserAdded object:nil];
    [self managedObjectContext];
    [self addUserLoginViewController];
    
}

-(void)removeStartupImage:(NSTimer*)timer
{
    //remove
    [timer invalidate];
    timer=nil;

    [UIView animateWithDuration:3.0 animations:^{
        _startupImageView.alpha=0.0;
    } completion:^(BOOL finished){
        [_startupImageView removeFromSuperview];
        _startupImageView=nil;
    }];
}

-(void)viewWillLayoutSubviews{
    //remove
    [super viewWillLayoutSubviews];
    //[self.view setFrame:CGRectMake(600, 600, 600, 600)];
}

-(void)addUserLoginViewController
{
    if (!self.loginViewController) {
        self.loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self.view addSubview:self.loginViewController.view];
    self.loginViewController.sharedPSC=self.persistentStoreCoordinator;
    self.loginViewController.delegate=self;
}

-(void)addSettingsViewController
{
    NSLog(@"VC: Adding settings view controller ");
    
   // if (!self.settingsViewController) {
   //     self.settingsViewController=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
   // }else{
   //     NSLog(@"Cant instantiate SettingsViewController/already instantiated");
   // }
    
   // self.settingsViewController.delegate=self;
   
   // [self.settingsViewController setSettinngsDelegate:self.gameViewController];
   // [self.view addSubview:self.settingsViewController.view];
}

#pragma mark -

#pragma mark - Login Delegate

-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user
{
    self.currentUser=user;
    
   // if (!self.gameViewController) {
   //     self.gameViewController=[[GameViewController //alloc]initWithNibName:@"GameViewController" bundle:nil];
   //     self.gameViewController.delegate= self;
   // }
    
    if (!self.masterViewController) {
        self.masterViewController=[[MasterViewController alloc]initWithNibName:@"MasterViewController" bundle:nil];
       // self.masterViewController.delegate= self;
    }
    

    
    [self.masterViewController setMemoryInfo:self.persistentStoreCoordinator withuser:user];
    
    [UIView transitionFromView:self.loginViewController.view toView:self.masterViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){}
    
    //[UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){
    //    self.gameViewController.gameUser=user;
    //    [self.gameViewController setLabels];
    //    self.gameViewController.sharedPSC=self.persistentStoreCoordinator;
    //    [self.gameViewController resetGame:nil];
        
       //[[self.gameViewController settingsViewController] setSettinngsDelegate:self.gameViewController];
        // self.settingsViewController.delegate=self;
        
        // [self.settingsViewController setSettinngsDelegate:self.gameViewController];
        // [self.view addSubview:self.settingsViewController.view];
        
        
    ];
}


-(void)gameViewExitGame
{
   // [UIView transitionFromView:self.gameViewController.view toView:self.loginViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
   // }];
}

-(void)exitSettingsViewController
{
    NSLog(@"inner back button pressed");
    
  //  [UIView transitionFromView:self.settingsViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
   // }];
}

-(void)toSettingsScreen
{
    NSLog(@" VC: Go to settings view controller");
    //[self addSettingsViewController];
}

#pragma mark - Core Data

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
    //NSLog(@"Manged object model %@", directoryAndFileNames);
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"mom"]; //was mom
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Model.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        // Typical reasons for an error here include:
        // The persistent store is not accessible
        // The schema for the persistent store is incompatible with current managed object model
        // Check the error message to determine what the actual problem was.
        NSLog(@"ABORTING");
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}
#pragma mark -
#pragma mark - Add User Notifications
-(void)addUserSuccess:(NSNotification*)notification
{
}
-(void)addUserExistsError:(NSNotification*)notification
{
}
-(void)addUserError:(NSNotification*)notification
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
@end
