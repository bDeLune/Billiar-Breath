//
//  CurvedScatterPlot.h
//  Plot_Gallery_iOS
//
//  Created by Nino Ag on 23/10/11.

#import "PlotItem.h"
#import "User.h"
@interface CurvedScatterPlot : PlotItem<CPTPlotSpaceDelegate,
                                        CPTPlotDataSource,
                                        CPTScatterPlotDelegate>
{
    @private
    CPTPlotSpaceAnnotation *symbolTextAnnotation;

    NSArray *plotData;
    NSArray *plotData1;
    NSArray *plotData2;
    NSArray *testPlotData;
}

-(void)setUser:(User*)user;
-(void)setType:(NSString*)type;
@end
