#import "GCDQueue.h"
#import "AppDelegate.h"
#import "AddNewScoreOperation.h"
#import "SettingsViewController.h"
#import "GameViewController.h"




@interface AppDelegate()
{
    UIImageView  *startupImageView;
    NSTimer      *startupTimer;
}


@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    
    NSLog(@"APP FINISHED LAUNCHING with language: %@", language);
    [self showSplash];
    
    return YES;
}

- (void)showSplash
{
    self.initialSplash = [[SplashViewController alloc]initWithNibName:@"SplashViewController" bundle:nil];
    
    self.initialSplash.view.frame = self.window.frame;
    
    [self.window addSubview:self.initialSplash.view];
    [self.window bringSubviewToFront:self.initialSplash.view];
    
    [NSTimer scheduledTimerWithTimeInterval:4.0
                                     target:self
                                   selector:@selector(removeSplash:)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void)removeSplash:(NSTimer *)timer{
    [timer invalidate];
    NSLog(@"Removing splash");
    [self.initialSplash.view removeFromSuperview];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
