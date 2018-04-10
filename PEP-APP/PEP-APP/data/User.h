//
//  User.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;
@class Note;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userHillType;
@property (nonatomic, retain) NSNumber * userAbilityType;

@property (nonatomic, retain) NSSet *game;
@property (nonatomic, retain) NSSet *note;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGameObject:(Game *)value;
- (void)removeGameObject:(Game *)value;
- (void)addGame:(NSSet *)values;
- (void)removeGame:(NSSet *)values;

@end
