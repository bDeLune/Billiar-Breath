#import "HeaderView.h"
@interface HeaderView ()
@property (nonatomic,strong)UILabel  *label;
@property (nonatomic,strong)UIButton  *deleteButton;
@property (nonatomic,strong)UIButton  *dataButton;
@end

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    
    return self;
}
-(void)build
{
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(20,10, 500, self.bounds.size.height)];

    [self.label setText:self.user.userName];
    [self addSubview:self.label];
    
    self.deleteButton=[UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.frame=CGRectMake(self.bounds.size.width-100, 10, 100, self.bounds.size.height);
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    //added
   // self.dataButton=[UIButton buttonWithType:UIButtonTypeSystem];
    //self.dataButton.frame=CGRectMake(self.deleteButton.frame.origin.x+110, 10, 100, self.bounds.size.height);
   // [self.dataButton setTitle:@"Data" forState:UIControlStateNormal];
   // [self.dataButton addTarget:self action:@selector(viewHistoricalData) forControlEvents:UIControlEventTouchUpInside];
   // [self addSubview:self.dataButton];

}
-(void)viewHistoricalData
{
    [self.delegate viewHistoricalData:self];
}
-(void)deleteAction
{
    [self.delegate deleteMember:self];
}

@end
