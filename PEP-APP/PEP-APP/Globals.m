//
//  Globals.m
//  Breath5
//
//  Created by barry on 21/04/2015.
//  Copyright (c) 2015 rocudo. All rights reserved.
//

#import "Globals.h"
#import "Game.h"
#import "User.h"
@interface Globals()
@property (strong) NSManagedObjectContext *managedObjectContext;

@end
@implementation Globals
static Globals *sharedGlobal = nil;
dispatch_semaphore_t sema;


+ (Globals *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedGlobal = [[Globals alloc] init];
        
        [sharedGlobal setup];
    });
    
    return sharedGlobal;
}

-(void)setup
{
   /* NSString * const gameHillType_toString[] = {
        [hillTypeFlat] = @"Flat",
        [hillTypeHill] = @"Hill",
        [hillTypeMountain]=@"Mountain"
    };
    
    NSString * const gameUserType_toString[]={
      [userTypeSignifigant]=@"User Type 1",
        [userTypeReduced]=@"User Type 2",
        [userTypeLittleReduced]=@"User Type 3",

    };*/
    


}
-(void)updateCoreData
{
    
    if ([self.managedObjectContext hasChanges]) {
        
        if (![self.managedObjectContext save:nil]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            NSLog(@"ABORTING");
            // abort();
        }
    }


}
-(void)updateUser:(User*)user
{
    //NSLog(@"%@",user.userAbilityType);
    if (!self.managedObjectContext) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    }
   
    
    
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *found=[items objectAtIndex:0];
        [found setUserAbilityType:user.userAbilityType];
    }
    
    [self updateCoreData];



}
-(NSManagedObjectID*)gameIDForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype
{
    NSManagedObjectContext *managedObjectContext =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
        
        //see if a game exists for combination of hill type and breath direction
        
        for (Game *game in games)
        {
            if ([game.gameHillType intValue]==hilltype) {
                
                if ([game.gameDirectionInt intValue]==direction) {
                    NSLog(@"direction == %@",game.gameDirectionInt);

                    return game.objectID;
                }
            }
        }
    }
    
    return nil;


}
-(Game*)gameForUser:(User*)user breathDirection:(int)direction hilltype:(int)hilltype
{
    
    
    NSManagedObjectContext *managedObjectContext =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator = self.sharedPSC;

    
    NSString   *name=user.userName;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate  *pred = [NSPredicate predicateWithFormat:@"userName == %@", name];
    [fetchRequest setPredicate:pred];
    
    NSError  *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    if ([items count]>0) {
        
        User  *user=[items objectAtIndex:0];
        NSSet  *game=user.game;
        NSArray  *games=[game allObjects];
        
        //see if a game exists for combination of hill type and breath direction
        
        for (Game *game in games)
        {
            NSLog(@"direction == %@",game.gameDirectionInt);
            if ([game.gameHillType intValue]==hilltype) {
                
                if ([game.gameDirectionInt intValue]==direction) {
                    return game;
                }
            }
        }
    }
    
    return nil;
    
}

@end
