//
//  TableViewController.h
//  GPUImage
//
//  Created by Brian Dillon on 28/05/2018.
//  Copyright © 2018 Brad Larson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController
-(void)setMemoryInfo:(NSPersistentStoreCoordinator*)store withuser:(User*)user;
@end
