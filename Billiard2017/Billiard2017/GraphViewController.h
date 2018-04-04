//
//  GraphViewController.h
//  BilliardBreath
//
//  Created by barry on 13/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import "PlotItem.h"
#import <UIKit/UIKit.h>
@interface GraphViewController : UIViewController
{
@private
    
    PlotItem *_detailItem;
    
    
}

@property (nonatomic, retain) PlotItem *detailItem;
@property (nonatomic, retain) IBOutlet UIView *hostingView;
@property(nonatomic,retain)IBOutlet  UIButton *typeButton;

-(IBAction)typeButtonSelected:(id)sender;
@end
