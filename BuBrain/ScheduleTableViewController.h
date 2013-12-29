//
//  ScheduleTableViewController.h
//  BU Brain
//
//  Created by Cezar Cocu on 11/8/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveGumbo.h>
#import "ClassCell.h"
#import "BuBrainCredentials.h"
#import "BUBrainClient.h"
#import "ClassInfo.h"
#import "GridScheduleViewController.h"


@interface ScheduleTableViewController : UITableViewController

@property (strong, nonatomic) NSString *term;// eg. 201420
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *classes;
@property (strong, nonatomic) NSURLSessionDataTask *currentTask;

-(id) initWithTerm: (NSString *) term andTitle:(NSString *)title;

@end
