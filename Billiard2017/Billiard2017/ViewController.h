//
//  ViewController.h
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "GameViewController.h"

@protocol SETTINGS_DELEGATE

-(void)sendValue:(int)note onoff:(int)onoff;
-(void)setFilter:(int)index;
-(void)setRate:(float)value;
-(void)setThreshold:(float)value;
-(void)setBTTreshold:(float)value;
-(void)setBTBoost:(float)value;
@end


@interface ViewController : UIViewController<LoginProtocol,GameViewProtocol,SETTINGS_DELEGATE,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    //maybe
    int midiinhale;
    int midiexhale;
    int currentdirection;
    BOOL midiIsOn;
}

//all maybe
@property int midiinhale;
@property int midiexhale;
@property float velocity;
@property float animationrate;
@property(nonatomic,strong)IBOutlet UISlider  *testSlider;
-(IBAction)sliderchanged:(id)sender;
@property BOOL midiIsOn;
@property(nonatomic,strong) UITextView  *outputtext;
@property  dispatch_source_t  aTimer;
@property(nonatomic,strong)IBOutlet  UITextView  *textarea;
-(void)continueMidiNote:(int)pvelocity;
-(void)stopMidiNote;
-(void)midiNoteBegan:(int)direction vel:(int)pvelocity;
-(void)makeTimer;
-(void)background;
-(void)foreground;

@end
