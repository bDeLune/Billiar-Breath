#import "User.h"
#import "Game.h"

@implementation User
@dynamic userName;
@dynamic game;
@dynamic note;

- (void)addGameObject:(Game *)value{
    NSLog(@"ADDED GAME OBJECT");
}

@end
