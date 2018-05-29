#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;
@class Note;
@interface User : NSManagedObject
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *game;
@property (nonatomic, retain) NSSet *note;
@end

@interface User (CoreDataGeneratedAccessors)
- (void)addGameObject:(Game *)value;
- (void)removeGameObject:(Game *)value;
- (void)addGame:(NSSet *)values;
- (void)removeGame:(NSSet *)values;
@end
