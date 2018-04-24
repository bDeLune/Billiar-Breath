#import "Draggable.h"

@interface Draggable ()
{
    CGPoint startLocation;
}
@end
@implementation Draggable

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(id)initWithImage:(UIImage *)image
{
    self=[super initWithImage:image];
    
    if (self) {
        self.userInteractionEnabled=YES;
        [[self superview] bringSubviewToFront:self];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.userInteractionEnabled=YES;
    [[self superview] bringSubviewToFront:self];

    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_delegate draggable:self];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    // Retrieve the touch point
    CGPoint pt = [[touches anyObject] locationInView:self];
    startLocation = pt;
    NSLog(@"x == %f",pt.x);
    NSLog(@"y == %f",pt.y);
    [[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // Move relative to the original touch point
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGRect frame = [self frame];
    frame.origin.x = 250;
    frame.origin.y += pt.y - startLocation.y;
    
    if (frame.origin.y>900) {
        frame.origin.y=900;
    }
    if (frame.origin.y<330) {
        frame.origin.y=330;
    }
    NSLog(@"x == %f",frame.origin.x);
    NSLog(@"y == %f",frame.origin.y);

    [self setFrame:frame];
}

@end
