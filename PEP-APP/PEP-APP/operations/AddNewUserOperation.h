//
//  AddNewUserOperation.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
extern NSString *kAddNewUserOperationUserExistsError;
extern NSString *kAddNewUserOperationUserAdded;

extern NSString *kAddNewUserOperationUserError;
@interface AddNewUserOperation : NSOperation
- (id)initWithData:(NSString *)username sharedPSC:(NSPersistentStoreCoordinator *)psc;

@end
