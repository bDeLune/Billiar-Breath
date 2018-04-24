//
//  GraphViewController.m
//  BilliardBreath
//
//  Created by barry on 13/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "GraphViewController.h"
#import "PlotGallery.h"
#import "CurvedScatterPlot.h"

@interface GraphViewController ()
{
    PlotItem *detailItem;
    CPTTheme  *currentTheme;
    NSString   *currentType;
}
@end

@implementation GraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentTheme=[CPTTheme themeNamed:kCPTDarkGradientTheme];
        currentType=@"Duration";
        
       /// [self.typeButton removeFromSuperview];
        [self.view addSubview:self.typeButton];//added
    }
    return self;
}
-(PlotItem *)detailItem
{
    return detailItem;
}
-(void)setDetailItem:(id)newDetailItem
{
    
    if ( detailItem != newDetailItem ) {
        detailItem=newDetailItem;
        [detailItem killGraph];
        [detailItem setType:@"Duration"];
        [detailItem renderInView:self.hostingView withTheme:currentTheme animated:YES];
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [detailItem renderInView:self.hostingView withTheme:currentTheme animated:YES];

  //  PlotGallery  *pgal=[PlotGallery sharedPlotGallery];
  ///     [pgal addPlotItem:plot];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)typeButtonSelected:(id)sender
{
    if ([self.typeButton.titleLabel.text isEqualToString:@"Power"]) {
        [self.typeButton setTitle:@"Duration" forState:UIControlStateNormal];
        [detailItem killGraph];
        [detailItem setType:@"Duration"];
        [detailItem renderInView:self.hostingView withTheme:currentTheme animated:YES];

    }else
    {
        [self.typeButton setTitle:@"Power" forState:UIControlStateNormal];
        [detailItem killGraph];
        [detailItem setType:@"Power"];
        [detailItem renderInView:self.hostingView withTheme:currentTheme animated:YES];

    }
}
@end
