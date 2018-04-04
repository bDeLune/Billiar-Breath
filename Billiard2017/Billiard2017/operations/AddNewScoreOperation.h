//
//  AddNewScoreOperation.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Game.h"
#import "Session.h"
@interface AddNewScoreOperation : NSOperation
- (id)initWithData:(User *)user  session:(Session*)session sharedPSC:(NSPersistentStoreCoordinator *)psc;

@end
