#import "AllGamesForDayTableVC.h"
#import "Game.h"
#import "HeaderView.h"

@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@property (nonatomic,strong)UIButton  *backButton;
//-(void)goBack;
@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    //data = games;
    
    NSLog(@"ALL TABLES DATA - %@", data);
    
    NSMutableArray* myDateArray;
    int count = [games count];
    
    for (int i = 1; i < count; i++){
        Game  *game= [games objectAtIndex:i];
        NSDate  *date=game.gameDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm:ss"];
        [myDateArray addObject:date];
      //  NSLog(@"myDateArray - %@", date);
      //  NSLog(@"myDateArray - %@", myDateArray);
    }
    
    //NSArray *sorted = [myDateArray sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
   //     return [date1 compare:date2];
    //}];
    
    data = [games sortedArrayUsingComparator: ^NSComparisonResult(Game *c1, Game *c2)
    {
        NSDate *d1 = c2.gameDate;
        NSDate *d2 = c1.gameDate;
        return [d1 compare:d2];
    }];
    
   // NSLog(@"SORTED - %@", data);

    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"All Games view did load");
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    //set the frame here
    //self.view.frame = CGRectMake(10, 10, 200, 400);
    UIImage *image = [UIImage imageNamed: @"User-Project.png"];
    [self.backgroundColouredImage setImage:image];
    [self.view addSubview:self.backgroundColouredImage];
    [self.view bringSubviewToFront:self.backgroundColouredImage];
    [self.backgroundColouredImage sendSubviewToBack:self.view];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:237/255.0f alpha:1.0f] ;
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"DISSAPEARS: go back to users");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
}

- (IBAction)tapGesture:(UITapGestureRecognizer*)gesture
{
    NSLog(@"tap gesture");
    CGPoint tapLocation = [gesture locationInView: self.view];
    for (UIImageView *imageView in self.view.subviews) {
        NSLog(@"imageView");
        if (CGRectContainsPoint(imageView.frame, tapLocation)) {
            NSLog(@"BACK BUTTON: go back to users");
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.view removeFromSuperview];
        }
    }
}

- (void)goBack:(UIButton *)sender  {
    NSLog(@"go back to users");
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Game  *game= [data objectAtIndex:indexPath.row];
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   // [dateFormat setDateFormat:@"d MMM y H:m:s"];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
    int gameType=[game.gameType intValue];
    

    NSString  *typeString;
    if (gameType==0) {
        typeString=@"Balloon Game";
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }else if (gameType==1)
    {
        typeString=@"Image Game";
     //   cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
    }else if (gameType==2)
    {
        typeString=@"Duo Game";
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
      //  cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }
    
    NSString* durationString;
    NSString* powerString;
    
    
    NSLog(@"game.power %@", game.power);
    NSLog(@"game.duration %@", game.duration);
    
    if ([game.power intValue] == 0){
        powerString = @"0";
    }else{
        // NSLog(@"powerStringTRY %@", powerString);
        //powerString= [[NSString stringWithFormat: @"%@", game.power] substringToIndex:4];
        // NSLog(@"powerString %@", powerString);
        
        float number =  [game.power floatValue];
        float x = (int)(number * 10000) / 10000.0;
        powerString = [NSString stringWithFormat:@"%.2f", x];
    }
    
    @try{
    //     NSLog(@"durationStringTRY %@", durationString);
        durationString= [[NSString stringWithFormat: @"%@", game.duration] substringToIndex:4];
    }@catch(NSException *exception){
         durationString= @"0" ;
    }
    
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@   %@",typeString,attemptDateString];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    
    cell.detailTextLabel.numberOfLines = 5;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"Strength: %@ \nDuration: %@ \nDirection: %@ \nSpeed: %@" ,powerString, durationString, game.gameDirection, game.speed];
    
    NSLog(@"%@",cell.detailTextLabel.text);

    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView  *header=[[HeaderView alloc]initWithFrame:CGRectMake(0, 100, 670, 0)];
    header.section=section;
    //header.user=[self.userList objectAtIndex:section];
    //header.delegate=self;
    [header build];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.backButton addGestureRecognizer:tap];
    
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

@end
