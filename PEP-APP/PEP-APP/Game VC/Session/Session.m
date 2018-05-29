#import "Session.h"

@implementation Session

-(id)init
{
    self=[super init];
    
    if (self) {
        _sessionDate=[NSDate date];
        _sessionStrength=[NSNumber numberWithFloat:0.0];
        _sessionDuration=[NSNumber numberWithFloat:0.0];
        _sessionSpeed=[NSNumber numberWithFloat:0.0];
        _sessionType=[NSNumber numberWithInt:0];
        _sessionRequiredBalloons=[NSNumber numberWithInt:0];
        _sessionAchievedBalloons=[NSNumber numberWithInt:0];
        _sessionBreathDirection=[NSNumber numberWithInt:0];
        _sessionRequiredBreathLength=[NSNumber numberWithInt:0];
        _sessionAchievedBreathLength=[NSNumber numberWithInt:0];
        _sessionBreathDirection=[NSNumber numberWithInt:0];
    }
    
    return self;
}

-(void)updateStrength:(float)pvalue
{
    if (pvalue>[_sessionStrength floatValue]) {
        _sessionStrength=[NSNumber numberWithFloat:pvalue];
    }
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_sessionDate forKey:@"sessionDate"];
    [encoder encodeObject:_sessionDuration forKey:@"sessionDuration"];
    [encoder encodeObject:_sessionStrength forKey:@"sessionStrength"];
    [encoder encodeObject:_sessionSpeed forKey:@"sessionSpeed"];
    [encoder encodeObject:_username forKey:@"username"];
    [encoder encodeObject:_sessionType forKey:@"sessionType"];
    [encoder encodeObject:_sessionRequiredBalloons forKey:@"sessionRequiredBalloons"];
    [encoder encodeObject:_sessionAchievedBalloons forKey:@"sessionAchievedBalloons"];
    [encoder encodeObject:_sessionRequiredBreathLength forKey:@"sessionRequiredBreathLength"];
    [encoder encodeObject:_sessionAchievedBreathLength forKey:@"sessionAchievedBreathLength"];
    [encoder encodeObject:_sessionBreathDirection forKey:@"sessionBreathDirection"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self.sessionDate = [decoder decodeObjectForKey:@"sessionDate"];
    self.sessionStrength = [decoder decodeObjectForKey:@"sessionStrength"];
    self.username = [decoder decodeObjectForKey:@"username"];
    self.sessionDuration = [decoder decodeObjectForKey:@"sessionDuration"];
    self.sessionSpeed=[decoder decodeObjectForKey:@"sessionSpeed"];
    self.sessionType=[decoder decodeObjectForKey:@"sessionType"];
    self.sessionRequiredBalloons = [decoder decodeObjectForKey:@"sessionRequiredBalloons"];
    self.sessionAchievedBalloons = [decoder decodeObjectForKey:@"sessionAchievedBalloons"];
    self.sessionRequiredBreathLength = [decoder decodeObjectForKey:@"sessionRequiredBreathLength"];
    self.sessionAchievedBreathLength = [decoder decodeObjectForKey:@"sessionAchievedBreathLength"];
    self.sessionBreathDirection=[decoder decodeObjectForKey:@"sessionBreathDirection"];
    return self;
}

@end
