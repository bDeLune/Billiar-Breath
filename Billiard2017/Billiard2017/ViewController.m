//
//  ViewController.m
//  BilliardBreath
//
//  Created by barry on 09/12/2013.
//  Copyright (c) 2013 rocudo. All rights reserved.
//

#import "ViewController.h"
#import "AddNewUserOperation.h"
#import "User.h"
#import "Game.h"
#import "GameViewController.h"

//maybe
#define GUAGE_HEIGHT 575
#import  "Source/GPUImageBulgeDistortionFilter.h"
#import  "GPUImageSwirlFilter.h"
#import "GPUImageZoomBlurFilter.h"
#import"GPUImageVignetteFilter.h"
#import "GPUImageToonFilter.h"
//#import "GPUImageToneCurveFilter.h"
#import "GPUImageThresholdSketchFilter.h"
#import "GPUImageDilationFilter.h"
#import "GPUImageDissolveBlendFilter.h"
#import "GPUImageStretchDistortionFilter.h"
#import "GPUImageSphereRefractionFilter.h"
#import "GPUImagePolkaDotFilter.h"
#import "GPUImagePosterizeFilter.h"
#import "GPUImagePixellateFilter.h"
#import "GPUImageHazeFilter.h"
#import "GPUImageErosionFilter.h"
#import "Source/GPUImagePicture.h"
#import "Source/GPUImageView.h"
#import "Source/GPUImageExposureFilter.h"
#import <CoreMIDI/CoreMIDI.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GPUImageTiltShiftFilter.h"
#import "GPUImageContrastFilter.h"
#import "BTLEManager.h"

static void    MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon);
void MyMIDINotifyProc (const MIDINotification  *message, void *refCon);
typedef void(^RunTimer)(void);
//

@interface ViewController ()<BTLEManagerDelegate>
{
    //all maybe
    GPUImagePicture *sourcePicture;
    GPUImageFilter *stillImageFilter;
    GPUImageView *imageView;
    CGFloat  defaultRadius;
    CGFloat  defaultScale;
    CGFloat  targetRadius;
    CGFloat  targetScale;
    CADisplayLink *displayLink;
    BOOL animationRunning;
    NSTimeInterval drawDuration;
    CFTimeInterval lastDrawTime;
    CGFloat drawProgress;
    int inorout;
    MIDIPortRef inPort ;
    MIDIPortRef outPort ;
    UIButton  *picselect;
    UIPopoverController *popover;
    UIImagePickerController *imagePickerController;
    UIButton  *togglebutton;
    BOOL   toggleIsON;
    float threshold;
    float mass;
    BOOL isaccelerating;
    float acceleration;// force/ mass
    float distance;
    float time;
    float sketchamount;
    BOOL ledTestIsOn;
}

@property (nonatomic, retain) IBOutlet UIToolbar *myToolbar;

@property (nonatomic, retain) NSMutableArray *capturedImages;
@property(nonatomic,strong)BTLEManager  *btleMager;
@property(nonatomic,strong)UIImageView  *btOnOfImageView;
// toolbar buttons
//- (IBAction)photoLibraryAction:(id)sender;
//- (IBAction)cameraAction:(id)sender;
@property (assign) SystemSoundID tickSound;
@property(nonatomic,strong)UIButton *ledTestButton;
//


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property(nonatomic,strong)LoginViewController  *loginViewController;
@property(nonatomic,strong)GameViewController  *gameViewController;

@property(nonatomic,strong)User  *currentUser;
@property(nonatomic,strong)Game  *currentGame;
@property(nonatomic,strong)UIImageView *startupImageView;
@property(nonatomic,strong)UIImageView  *btOnOfImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // observe for any errors that come from our parser
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserError:) name:kAddNewUserOperationUserError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserExistsError:) name:kAddNewUserOperationUserExistsError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserSuccess:) name:kAddNewUserOperationUserAdded object:nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self managedObjectContext];
    [self addUserLoginViewController];
    
    
///_startupImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
//[self.view addSubview:_startupImageView];
  //  [ NSTimer scheduledTimerWithTimeInterval:5.0
   //                                   target:self
   //                                 selector:@selector(removeStartupImage:)
   //                                 userInfo:nil
  //                                   repeats:NO];
//added
    
}
-(void)removeStartupImage:(NSTimer*)timer
{
    [timer invalidate];
    timer=nil;
    
    
    [UIView animateWithDuration:3.0 animations:^{
        _startupImageView.alpha=0.0;
    } completion:^(BOOL finished){
        [_startupImageView removeFromSuperview];
        _startupImageView=nil;
    }];
    
    
}


//- (UIViewController *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
///    NSLog(@"tocuhed hit event");
//    NSLog(@"%@", NSStringFromCGPoint(point));
//    NSLog(@"%@ ", event);
    
   // CGRect rect = WORK_OUT_WHERE_THE_BUTTON_RECT_IS_RELATIVE_TO_THE_WINDOW;
   // if (CGRectContainsPoint(rect, point))
   // {
   //     return theButtonView;
   // }
   // else
   // {
   //     return self;
        //return true;
  //  }
    
//}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
  //  [self.view setFrame:CGRectMake(600, 600, 600, 600)];
    
}

-(void)addUserLoginViewController
{
    if (!self.loginViewController) {
        self.loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self.view addSubview:self.loginViewController.view];
    self.loginViewController.sharedPSC=self.persistentStoreCoordinator;
    self.loginViewController.delegate=self;
    
}




#pragma mark -
#pragma mark - Add User Notifications
-(void)addUserSuccess:(NSNotification*)notification
{
    
}
-(void)addUserExistsError:(NSNotification*)notification
{
    
}
-(void)addUserError:(NSNotification*)notification
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark - Core Data
// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
    //NSLog(@"Manged object model %@", directoryAndFileNames);
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"mom"]; //was mom
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // find the earthquake data in our Documents folder
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Model.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        
        // Typical reasons for an error here include:
        // The persistent store is not accessible
        // The schema for the persistent store is incompatible with current managed object model
        // Check the error message to determine what the actual problem was.
        NSLog(@"ABORTING");
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark - Orientation
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return (UIInterfaceOrientationMaskLandscape);
}

#pragma mark -
#pragma mark - Login Delegate

-(void)LoginSucceeded:(LoginViewController*)viewController user:(User*)user
{
    // assert([NSThread isMainThread]);
    
    self.currentUser=user;
    
    if (!self.gameViewController) {
        self.gameViewController=[[GameViewController alloc]initWithNibName:@"GameViewController" bundle:nil];
        self.gameViewController.delegate=self;
    }
    
    [UIView transitionFromView:self.loginViewController.view toView:self.gameViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished){
        self.gameViewController.gameUser=user;
        [self.gameViewController setLabels];
        self.gameViewController.sharedPSC=self.persistentStoreCoordinator;
        [self.gameViewController resetGame:nil];
        
    }];
}

-(void)gameViewExitGame
{
    [UIView transitionFromView:self.gameViewController.view toView:self.loginViewController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
        
    }];
}


//// SIMPLEIMAGE

-(void)background

{
    self.btleMager.delegate=nil;
    self.btleMager=nil;
    [displayLink invalidate];
    displayLink=nil;
}
-(void)foreground
{
    self.btleMager=[BTLEManager new];
    self.btleMager.delegate=self;
    [self.btleMager startWithDeviceName:@"GroovTube 2.0" andPollInterval:0.1];
    //[self.btleMager setTreshold:60];
    
}

-(IBAction)sliderchanged:(id)sender
{
    sketchamount=self.testSlider.value;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sketchamount=0;
        self.title = @"Groov";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        _animationrate=1;
        picselect=[UIButton buttonWithType:UIButtonTypeCustom];
        picselect.frame=CGRectMake(0, self.view.frame.size.height-120, 108, 58);
        [picselect addTarget:self action:@selector(photoButtonLibraryAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:picselect];
        
        [picselect setBackgroundImage:[UIImage imageNamed:@"PickPhotoButton.png"] forState:UIControlStateNormal];
        
        self.capturedImages = [NSMutableArray array];
        
        
        
        /*   AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:
         [[NSBundle mainBundle] pathForResource:@"tick"
         ofType:@"aiff"]],
         &_tickSound);*/
        
        imagePickerController = [[UIImagePickerController alloc] init] ;
        imagePickerController.delegate = self;
        
        //  [self.view addSubview:imagePickerController.view];
        
        togglebutton=[UIButton buttonWithType:UIButtonTypeCustom];
        togglebutton.frame=CGRectMake(110, self.view.frame.size.height-120, 108, 58);
        [togglebutton addTarget:self action:@selector(toggleDirection:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:togglebutton];
        
        [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_EXHALE.png"] forState:UIControlStateNormal];
        toggleIsON=NO;
        threshold=0;
        
        
        self.btOnOfImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
        [self.btOnOfImageView setImage:[UIImage imageNamed:@"Bluetooth-DISCONNECTED"]];
        [self.view addSubview:self.btOnOfImageView];
        self.ledTestButton=[[UIButton alloc]initWithFrame:CGRectMake(110, 10, 100, 100)];
        [self.ledTestButton setBackgroundColor:[UIColor greenColor]];
        [self.ledTestButton addTarget:self action:@selector(testLed:) forControlEvents:UIControlEventTouchUpInside];
        //dead [self.view addSubview:self.ledTestButton];
    }
    return self;
}

-(IBAction)testLed:(id)sender
{
    if (ledTestIsOn==YES) {
        
        ledTestIsOn=NO;
        [self.btleMager performSelector:@selector(ledLeftOff)];
    }else
    {
        [self.btleMager performSelector:@selector(ledLeftOn)];
        ledTestIsOn=YES;
    }
}
-(void)btleManagerBreathBegan:(BTLEManager*)manager
{
    NSLog(@"Midi Began");
    if (![self allowBreath]) {
        return;
    }
    //isaccelerating=YES;
}
-(void)btleManagerBreathStopped:(BTLEManager *)manager
{
    NSLog(@"Midi Stopped");
    
    isaccelerating=NO;
}
-(void)btleManager:(BTLEManager*)manager inhaleWithValue:(float)percentOfmax{
    if (toggleIsON==NO) {
        return ;
    }
    currentdirection=midiinhale;
    //self.velocity=(percentOfmax/10.0)*127.0;
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    //  NSLog(@"inhaleWithValue %f",percentOfmax);
    
    
    
}
-(void)btleManager:(BTLEManager*)manager exhaleWithValue:(float)percentOfmax
{
    /*  if (![self allowBreath]) {
     isaccelerating=NO;
     
     return;
     }*/
    if (toggleIsON==YES) {
        return ;
    }
    currentdirection=midiexhale;
    //self.velocity=(percentOfmax/10.0)*127.0;
    self.velocity=(percentOfmax)*127.0;
    isaccelerating=YES;
    //
    //   NSLog(@"exhaleWithValue %f",percentOfmax);
    
}
-(BOOL)allowBreath
{
    if (toggleIsON) {
        if (currentdirection==midiexhale) {
            return NO;
        }
    }else if (!toggleIsON)
    {
        
        if (currentdirection==midiinhale) {
            return NO;
        }
    }
    
    return YES;
    
}
- (IBAction)toggleDirection:(id)sender
{
    
    switch (toggleIsON) {
        case 0:
            toggleIsON=YES;
            [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_INHALE.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [togglebutton setBackgroundImage:[UIImage imageNamed:@"BreathDirection_EXHALE.png"] forState:UIControlStateNormal];
            toggleIsON=NO;
            
            break;
            
        default:
            break;
    }
    
    
    
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self setupDisplayFilteringWithImage:image];
    
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        // UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *webData = UIImagePNGRepresentation(image);
        [webData writeToFile:imagePath atomically:YES];
    }
    
    // [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // [self.delegate didFinishWithCamera];    // tell our delegate we are finished with the picker
}

- (IBAction)photoButtonLibraryAction:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popover presentPopoverFromRect:CGRectMake(0, 0, 500, 500) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //[self presentModalViewController:imagePickerController animated:YES];
    }
}
@synthesize midiexhale,midiinhale,velocity;
@synthesize midiIsOn;
-(void)setThreshold:(float)value
{
    threshold=value;
}
-(void)setBTTreshold:(float)value
{
    [self.btleMager setTreshold:value];
}
-(void)setBTBoost:(float)value
{
    [self.btleMager setRangeReduction:value];
}
-(void)setRate:(float)value
{
    self.animationrate=value;
}
-(void) appendToTextView: (NSString*) moreText {
    dispatch_async(dispatch_get_main_queue(), ^{
        _outputtext.text = [NSString stringWithFormat:@"%@%@\n",
                            _outputtext.text, moreText];
        [_outputtext scrollRangeToVisible:NSMakeRange(_outputtext.text.length-1, 1)];
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!displayLink) {
        [self setupDisplayFiltering];
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateimage)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        animationRunning = YES;
        [displayLink setFrameInterval:8];
        //[self makeTimer];
        acceleration=0.1;
        distance=0;
        time=0;
        [self toggleDirection:nil];
        [self toggleDirection:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    midiinhale=61;
    midiexhale=73;
    velocity=0;
    midiIsOn=false;
    targetRadius=0;
    defaultScale=1.5;
    defaultRadius=0;
    // [self setupMIDI];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)updateimage
{
    /***
     @"Bulge",@"Swirl",@"Blur",@"Vignette",@"Toon",
     @"Tone",@"Sketch",@"Polka",
     @"Posterize",@"Pixellate",@"Haze",@"Erosion"
     */
    // self.velocity+=1;
    
    float fVel= (float)self.velocity;
    // float rate = fVel/5;
    float rate = fVel;
    //NSLog(@"rate == %f",rate);
    
    if (isaccelerating)
    {
        if (self.velocity>=threshold) {
            
            targetRadius=targetRadius+((rate/500)*_animationrate);
        }
        
    }else
    {
        //force-=force*0.03;
        // targetRadius=targetRadius-((35.0/500)*_animationrate);
        targetRadius=targetRadius-((40.0/500)*_animationrate);
    }
    
    //if (inorout==midiinhale) {
    // }else
    // {
    // targetRadius=targetRadius-((rate/1000)*_animationrate);
    // }
    
    
    if (targetRadius<0.001) {
        targetRadius=0.001;
    }
    
    if (targetRadius>1) {
        targetRadius=1;
    }
    // NSLog(@"target radius %f",targetRadius);
    
    if ([stillImageFilter isKindOfClass:[GPUImageBulgeDistortionFilter class]])
        
    {
        if (targetRadius<0.001) {
            targetRadius=0.0;
        }
        [(GPUImageBulgeDistortionFilter*)stillImageFilter setRadius:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageSwirlFilter class]])
    {
        [(GPUImageSwirlFilter*)stillImageFilter setRadius:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageZoomBlurFilter class]])
    {
        [(GPUImageZoomBlurFilter*)stillImageFilter setBlurSize:targetRadius];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageVignetteFilter class]])
    {
        [(GPUImageVignetteFilter*)stillImageFilter setVignetteStart:1-targetRadius];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageToonFilter class]])
    {
        [(GPUImageToonFilter*)stillImageFilter setThreshold:1-(targetRadius-0.1)];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageExposureFilter class]])
    {
        [(GPUImageExposureFilter*)stillImageFilter setExposure:targetRadius+0.1];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePolkaDotFilter class]])
    {
        //[(GPUImagePolkaDotFilter*)stillImageFilter setDotScaling:targetRadius];
        [(GPUImagePolkaDotFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
        
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePosterizeFilter class]])
    {
        [(GPUImagePosterizeFilter*)stillImageFilter setColorLevels:11-(10*targetRadius)];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImagePixellateFilter class]])
    {
        [(GPUImagePixellateFilter*)stillImageFilter setFractionalWidthOfAPixel:targetRadius/10];
        
    }else if ([stillImageFilter isKindOfClass:[GPUImageContrastFilter class]])
    {
        [(GPUImageContrastFilter*)stillImageFilter setContrast:1-targetRadius];
        
        //[(GPUImageThresholdSketchFilter*)stillImageFilter setSlope:targetRadius/3];
    }
    
    //NSLog(@"value == %f",targetRadius);
    
    [sourcePicture processImage];
    
    /**
     self.topFocusLevel = 0.4;
     self.bottomFocusLevel = 0.6;
     self.focusFallOffRate = 0.2;
     self.blurSize = 2.0;*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setupDisplayFilteringWithImage:(UIImage*)aImage
{
    
    //cleanup
    [sourcePicture removeAllTargets];
    //[stillImageFilter destroyFilterFBO];
    //[stillImageFilter releaseInputTexturesIfNeeded];
    stillImageFilter=nil;
    [imageView removeFromSuperview];
    imageView=nil;
    imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:imageView atIndex:0];
    
    stillImageFilter=[self filterForIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    
    //image set
    //dispatch_async(dispatch_get_main_queue(), ^{
    sourcePicture = [[GPUImagePicture alloc] initWithImage:aImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:0];
    imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    // [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    [sourcePicture processImage];
    
    // });
    // [self start];
}
- (void)setupDisplayFiltering;
{
    UIImage *inputImage;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    NSData  *data=[NSData dataWithContentsOfFile:imagePath];
    
    //inputImage=[UIImage imageWithData:data];
    //if (!inputImage) {
    inputImage=[UIImage imageNamed:@"giraffe-614141_1280.jpg"];
    // }
    
    sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    stillImageFilter = [self filterForIndex:0];
    imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    // [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:0];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    
    [sourcePicture processImage];
}

-(void)setFilter:(int)index
{
    [sourcePicture removeAllTargets];
    //[stillImageFilter destroyFilterFBO];
    //[stillImageFilter releaseInputTexturesIfNeeded];
    stillImageFilter=nil;
    [imageView removeFromSuperview];
    imageView=nil;
    imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    // [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:0];
    stillImageFilter=[self filterForIndex:index];
    [sourcePicture addTarget:stillImageFilter];
    [stillImageFilter addTarget:imageView];
    
    
    
    
}

/***
 #import"GPUImageVignetteFilter.h"
 #import "GPUImageToonFilter.h"
 #import "GPUImageToneCurveFilter.h"
 #import "GPUImageThresholdSketchFilter.h"
 #import "GPUImageDilationFilter.h"
 #import "GPUImageDissolveBlendFilter.h"
 #import "GPUImageStretchDistortionFilter.h"
 #import "GPUImageSphereRefractionFilter.h"
 #import "GPUImagePolkaDotFilter.h"
 #import "GPUImagePosterizeFilter.h"
 #import "GPUImagePixellateFilter.h"
 #import "GPUImageHazeFilter.h"
 #import "GPUImageErosionFilter.h"
 */

-(GPUImageFilter*)filterForIndex:(int)index
{
    GPUImageFilter *filter;
    
    switch (index) {
        case 0:
            filter=[[GPUImageBulgeDistortionFilter alloc] init];
            break;
            
        case 1:
            filter=[[GPUImageSwirlFilter alloc] init];
            
            break;
            
        case 2:
            filter=[[GPUImageZoomBlurFilter alloc] init];
            
            break;
            
            
        case 3:
            filter=[[GPUImageToonFilter alloc] init];
            
            break;
            
            
        case 4:
            filter=[[GPUImageExposureFilter alloc] init];
            break;
            
            
        case 5:
            filter=[[GPUImagePolkaDotFilter alloc] init];
            
            break;
        case 6:
            filter=[[GPUImagePosterizeFilter alloc] init];
            
            break;
            
        case 7:
            filter=[[GPUImagePixellateFilter alloc] init];
            
            break;
            
        case 8:
            filter=[[GPUImageContrastFilter alloc] init];
            break;
            
            
            
        default:
            break;
    }
    
    return filter;
}


-(void)addText:(NSString*)str
{
    NSString  *newstring=[NSString stringWithFormat:@"%@\n%@",_textarea.text,str];
    [_textarea setText:newstring];
}
-(void)animate
{
    self.velocity+=0.1;
    if (self.velocity<threshold) {
        return;
    }
    float fVel= (float)self.velocity;
    float rate = fVel/10;
    
    
    
    if (inorout==midiinhale) {
        targetRadius=targetRadius+((45.0/100)*_animationrate);
    }else
    {
        targetRadius=targetRadius-((45.0/100)*_animationrate);
    }
    
    
    if (targetRadius<0.01) {
        targetRadius=0.01;
    }
    
    if (targetRadius>1) {
        targetRadius=1;
    }
    
    
}
-(void)start
{
    //  [self stop];
    //[self setDefaults];
    // if (!animationRunning)
    // {
    displayLink = [CADisplayLink displayLinkWithTarget:self
                                              selector:@selector(animate)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    animationRunning = YES;
    //}
}


@end
