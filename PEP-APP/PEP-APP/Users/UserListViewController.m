#import "UserListViewController.h"
#import "User.h"
#import "Game.h"
#import "HeaderView.h"
#import "AllGamesForDayTableVC.h"
#import "GCDQueue.h"
#import "InfoViewController.h"
#import "SettingsViewController.h"

@interface UserListViewController()<UIActionSheetDelegate,HeaderViewProtocl>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *activityIndicator;
@property (nonatomic) NSMutableArray *userList;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,assign)User  *deleteUser;
@end
@implementation UserListViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(NSArray*)sortedDateArrayForUser:(User*)user
{
    /* NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"d MMM y "];
     
     NSMutableArray  *datesstrings=[NSMutableArray new];
     NSArray *alldates=[user.game allObjects];
     for (int i=0; i<[user.game count]; i++) {
     NSDate  *date=[[alldates objectAtIndex:i]valueForKey:@"gameDate"];
     // NSString  *datestring=[formatter]
     
     [datesstrings addObject:[formatter stringFromDate:date]];
     }
     NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
     NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
     [mutable sortUsingSelector:@selector(compare:)];
     
     NSArray  *reverse=[[mutable reverseObjectEnumerator]allObjects];*/
    
    NSArray *alldates=[user.game allObjects];
    
    
    NSArray *sortedArray = [alldates sortedArrayUsingComparator:
                            ^(id obj1, id obj2)
                            {
                                return [(NSDate*) [obj1 valueForKey:@"gameDate" ] compare: (NSDate*)[obj2 valueForKey:@"gameDate"]];
                            }
                            ];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSMutableArray  *datesstrings=[NSMutableArray new];
    
    for (int i=0; i<[sortedArray count]; i++) {
        NSDate  *date=[[sortedArray objectAtIndex:i]valueForKey:@"gameDate"];
        [datesstrings addObject:[formatter stringFromDate:date]];
        
    }
    
     NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
    
     NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
     [mutable sortUsingSelector:@selector(compare:)];

    return mutable;
    
}
-(int)uniquedatesForUser:(User*)user
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    
    NSMutableArray  *datesstrings=[NSMutableArray new];
    NSArray *alldates=[user.game allObjects];
    for (int i=0; i<[user.game count]; i++) {
        NSDate  *date=[[alldates objectAtIndex:i]valueForKey:@"gameDate"];
        // NSString  *datestring=[formatter]
        [datesstrings addObject:[formatter stringFromDate:date]];
    }
    NSArray *cleanedArray = [[NSSet setWithArray:datesstrings] allObjects];
    NSMutableArray *mutable=[[NSMutableArray alloc]initWithArray:cleanedArray];
    [mutable sortUsingSelector:@selector(compare:)];
    
    return [mutable count];
    return 0;
}
-(void)getUniqueDates{
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self.backgroundColouredImage bringSubviewToFront:self.view];
        [self.backgroundColouredImage sendSubviewToBack:self.tableView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidLoad
{
    self.userList=[NSMutableArray new];
    [self managedObjectContext];
    [self getListOfUsers];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(  UISwipeGestureRecognizerDirectionLeft)];
    // [[self view] addGestureRecognizer:recognizer];
    [self.backgroundColouredImage bringSubviewToFront:self.view];
        [self.backgroundColouredImage sendSubviewToBack:self.tableView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)goBack
{
    [self.delegate userListDismissRequest:self];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)getListOfUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        self.userList=[NSMutableArray arrayWithArray:items];
    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"title");
    User  *user=[self.userList objectAtIndex:section];
    NSString  *title=[user valueForKey:@"userName"];
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   //NSLog(@"Number of users - %lu", (unsigned long)[self.userList count]);
    int sections=[self.userList count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"numberOfRowsInSection");
    NSInteger numberOfRows = 0;
    User *user=[self.userList objectAtIndex:section];
    numberOfRows=[user.game count];
    
    return  [self uniquedatesForUser:user];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    User  *user=[self.userList objectAtIndex:indexPath.section];

    NSArray  *dates=[self sortedDateArrayForUser:user];
    dates=[[dates reverseObjectEnumerator]allObjects];
    NSDate * dateAtRow =[dates objectAtIndex:indexPath.row];
    NSString *stringFromDate =[dates objectAtIndex:indexPath.row];
    cell.textLabel.text= stringFromDate;
    return cell;
}
-(NSArray*)gamesMatchingDate:(NSString*)date user:(User*)user
{
    NSArray *array=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM y "];
    NSPredicate *shortNamePredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Game *game=(Game*)evaluatedObject;
        NSDate *gamedate=[game gameDate] ;
        NSString  *datestring=[formatter stringFromDate:gamedate];
        return [datestring isEqualToString:date];
        return YES;
        /// return [(Game*)[evaluatedObject gameDate]] ;
    }];
    
    NSArray *unfiltered=[user.game allObjects];
    NSArray *filtered=[unfiltered filteredArrayUsingPredicate:shortNamePredicate];
    NSMutableArray  *mut=[NSMutableArray arrayWithArray:filtered];
    NSMutableArray  *temp=[NSMutableArray arrayWithArray:filtered];
    //NSMutableArray *tempcopy= [[NSMutableArray alloc] initWithObjects:unfiltered, nil];
    NSLog(@"gamesMatchingDate username %@", user.userName);
    NSLog(@"gamesMatchingDate unfiltered %@", unfiltered);
    NSMutableArray * tempcopy = [[NSMutableArray alloc] init];
    
    [tempcopy addObjectsFromArray:unfiltered];
    [tempcopy sortUsingDescriptors:
    [NSArray arrayWithObjects:
    [NSSortDescriptor sortDescriptorWithKey:@"gameDate" ascending:YES],nil]];

    return filtered;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User  *user=[self.userList objectAtIndex:indexPath.section];
    NSArray  *dates=[self sortedDateArrayForUser:user];
    dates=[[dates reverseObjectEnumerator]allObjects];
    // NSDate  *date=[sortedDateKeysNoTime objectAtIndex:indexPath.row];
    AllGamesForDayTableVC  *detailViewController=[[AllGamesForDayTableVC alloc]initWithNibName:@"AllGamesForDayTableVC" bundle:nil];
    NSArray  *array=[self gamesMatchingDate:[dates objectAtIndex:indexPath.row] user:user];
    //NSLog(@"didSelectRowAtIndexPath for array %@", array);
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in array) {
       NSLog(@"GAMELABEL -  ADDING didSelectRowAtIndexPath for array %@", array);
       //NSLog(@"ADDING didSelectRowAtIndexPath for agame.gameType %@", agame.gameType);
       //if ([agame.gameType intValue]==2) {
            [durationOnly addObject:agame];
       //}
        }
       NSLog(@"didSelectRowAtIndexPath  for username %@ durationOnlyarray %@" , user.userName , durationOnly);
    [detailViewController setUSerData:durationOnly];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// called after fetched results controller received a content change notification
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
     NSLog(@"controllerDidChangeContent");
    [self.tableView reloadData];
}

#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    if (self.sharedPSC != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.sharedPSC];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    return _managedObjectContext;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView  *header=[[HeaderView alloc]initWithFrame:CGRectMake(0, 150, 570, 20)];
    header.section=section;
    header.user=[self.userList objectAtIndex:section];
    header.delegate=self;
    [header build];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(void)deleteMember:(HeaderView *)header
{
    self.deleteUser=[self.userList objectAtIndex:header.section];
    NSString *message=[NSString stringWithFormat:@"Delete User ' %@ '", self.deleteUser.userName];
    UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.managedObjectContext deleteObject:self.deleteUser];
        [self.managedObjectContext save:nil];
    }
}

-(void)viewHistoricalData:(HeaderView *)header
{
    User *user=[self.userList objectAtIndex:header.section];
    NSArray * src=[user.game allObjects];
    NSMutableArray  *durationOnly=[NSMutableArray new];
    
    for (Game *agame in src) {
        if ([agame.gameType intValue]==2) {
            [durationOnly addObject:agame];
        }
    }

    NSUInteger count=[[user.game allObjects]count];
    
    if (count==0) {
        UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"No Data" message:@"No data for this user yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [[GCDQueue mainQueue]queueBlock:^{
            [alert show];
        }];
        return;
    }
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    [self getListOfUsers];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    //if (notification.object != self.managedObjectContext) {
    [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    // }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"canEditRowAtIndexPath");
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user=[self.userList objectAtIndex:indexPath.section];
    [self.managedObjectContext deleteObject:user];
    [self.managedObjectContext save:nil];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"editingStyleForRowAtIndexPath");
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndEditingRowAtIndexPath");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
