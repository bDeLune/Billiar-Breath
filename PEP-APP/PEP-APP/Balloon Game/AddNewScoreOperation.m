#import "AddNewScoreOperation.h"
@interface AddNewScoreOperation ()
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,strong)User  *user;
@property(nonatomic,strong)Session  *session;
@end
@implementation AddNewScoreOperation
- (id)initWithData:(User *)auser  session:(Session*)asession sharedPSC:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
        
        self.sharedPSC = psc;
        self.user=auser;
        self.session=asession;
    }
    return self;
    
}
- (void)main {

    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    [self addTheSession];
}

-(void)addTheSession
{
    
    NSLog(@"ADDING THE SESSION");
    
   // //NSLog(@"SESSION DURATION %@", self.session.sessionDuration);
   // NSLog(@"SESSION STRENGTH %@", self.session.sessionStrength);
    
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    //[game setUser:self.user];
    
    //CHANGE BACK - DURATION NEEDS TO BE LOGGED
    ///SAVE THE SPEED CHOSEN BY USER
    //if ([self.session.sessionDuration floatValue]<=0.0) {
   //     return;
   // }
    
    //also add
    //sessionRequiredBalloon
    //sessionAchievedBalloons"
    //sessionRequiredBreathLength"
    //sessionAchievedBreathLength"
    //sessionBreathDirection"

    [game setDuration:0];   //change
    [game setGameDate:self.session.sessionDate];
    [game setPower:self.session.sessionStrength];
    [game setGameType:self.session.sessionType];
    
    [game setRequiredBalloons:self.session.sessionRequiredBalloons];   //change
    [game setAchievedBalloons:self.session.sessionAchievedBalloons];
    [game setRequiredBreathLength:self.session.sessionRequiredBreathLength];
    [game setAchievedBreathLength:self.session.sessionAchievedBreathLength];
    
    //workds
    //[game setCurrentGameRequiredBalloons:self.session.sessionRequiredBalloons];
    //[game setCurrentGameAchievedBalloons:self.session.sessionAchievedBalloons];
    //[game setCurrentGameRequiredBreathLength:self.session.sessionRequiredBreathLength];
    //[game setCurrentGameAchievedBreathLength:self.session.sessionAchievedBreathLength];
    
    //game.gameRequiredBalloons = self.session.sessionRequiredBalloons;
    //game.gameAchievedBalloons = self.session.sessionAchievedBalloons;
    //game.gameRequiredBreathLength = self.session.sessionRequiredBreathLength;
    //game.gameAchievedBreathLength = self.session.sessionAchievedBreathLength;

    NSString *direction=[[NSUserDefaults standardUserDefaults]objectForKey:@"direction"];
    [game setGameDirection:direction];
   // [game setSpeed:self.session.sessionSpeed];
    NSString   *name=[self.user valueForKey:@"userName"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];

    NSLog(@"ADDTHESESSION game: %@", game);
    NSLog(@"pred game: %@", pred);
    NSLog(@"pred game: %@", items);
    NSLog(@"sessionDuration %@", self.session.sessionDuration);
    NSLog(@"sessionDate %@", self.session.sessionDate);
    NSLog(@"sessionStrength %@", self.session.sessionStrength);
    NSLog(@"sessionType %@", self.session.sessionType);
    NSLog(@"sessionRequiredBalloons %@", self.session.sessionRequiredBalloons);
    NSLog(@"sessionAchievedBalloons %@", self.session.sessionAchievedBalloons);
    NSLog(@"sessionRequiredBreathLength %@", self.session.sessionRequiredBreathLength);
    NSLog(@"sessionAchievedBreathLength %@", self.session.sessionAchievedBreathLength);
    
    if ([items count]>0) {
        User *auser=[items objectAtIndex:0];
        [[auser mutableSetValueForKey:@"game"]addObject:game];
        NSLog(@"ADDTHESESSION USER ARRAY: %@", auser);
       // NSLog(@"ADDTHESESSION game: %@", game);
    }
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during developmeint. If it is not possible to recover from the error, display an alerto
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
           // abort();
        }
    }
}

@end
