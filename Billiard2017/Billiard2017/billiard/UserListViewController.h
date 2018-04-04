//
//  UserListViewController.h
//  BilliardBreath
//
//  Created by barry on 11/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserListViewController;

@protocol UserListProtoCol <NSObject>

-(void)userListDismissRequest:(UserListViewController*)caller;

@end
@interface UserListViewController : UITableViewController<UIAlertViewDelegate>
@property (strong) NSPersistentStoreCoordinator *sharedPSC;
@property(nonatomic,unsafe_unretained)id<UserListProtoCol>delegate;
-(void)getListOfUsers;
@end
