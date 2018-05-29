#import "AllGamesForDayTableVC.h"
#import "Game.h"
@interface AllGamesForDayTableVC ()
{
    NSArray  *data;
}

@end

@implementation AllGamesForDayTableVC

-(void)setUSerData:(NSArray*)games
{
    data=games;
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
    [super viewDidLoad];

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
    
    Game  *game=[data objectAtIndex:indexPath.row];
    NSDate  *date=game.gameDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d MMM y H:m:s"];
    NSString *attemptDateString = [dateFormat stringFromDate:date];
    int gameType=[game.gameType intValue];
    
    NSString  *typeString;
    if (gameType==0) {
        typeString=@"Balloon Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }else if (gameType==1)
    {
        typeString=@"Image Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
    }else if (gameType==2)
    {
        typeString=@"Duo Game";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Breath Length :%f",[game.achievedBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Breath Length :%f",[game.requiredBreathLength floatValue]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Achieved Balloons :%@",game.achievedBalloons];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"Required Balloons :%@",game.requiredBalloons];
    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@  %@",typeString,attemptDateString];

    return cell;
}

@end
