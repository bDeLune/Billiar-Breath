//
//  Draggable.h
//  FairHammer
//
//  Created by barry on 26/02/2014.
//  Copyright (c) 2014 barry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  Draggable;

@protocol DraggableDelegate <NSObject>

-(void)draggable:(Draggable*)didDrag;

@end
@interface Draggable : UIImageView
@property(nonatomic,assign)id<DraggableDelegate>delegate;
@end
