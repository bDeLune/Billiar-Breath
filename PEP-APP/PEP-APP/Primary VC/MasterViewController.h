#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController
-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user;
@end
