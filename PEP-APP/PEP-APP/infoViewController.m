//
//  infoViewController.m
//  PEP-APP
//
//  Created by Brian Dillon on 19/04/2018.
//  Copyright © 2018 ROCUDO. All rights reserved.
//

#import "infoViewController.h"

@interface infoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *returnToGameView;

@end

@implementation infoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)returnToGameView:(id)sender {
    
    
    NSLog(@"Returning to game view");
   
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
