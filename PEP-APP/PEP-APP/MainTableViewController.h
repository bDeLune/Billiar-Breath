#import <UIKit/UIKit.h>

@interface MainTableViewController : UITableViewController
-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user;
@end
