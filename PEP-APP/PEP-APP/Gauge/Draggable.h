#import <UIKit/UIKit.h>
@class  Draggable;
@protocol DraggableDelegate <NSObject>
-(void)draggable:(Draggable*)didDrag;
@end
@interface Draggable : UIImageView
@property(nonatomic,assign)id<DraggableDelegate>delegate;
@end
