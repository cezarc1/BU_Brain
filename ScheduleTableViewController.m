//
//  ScheduleTableViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 11/8/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "ScheduleTableViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SCHEDULE_CELL_IDENTIFIER @"ScheduleCellIdentifier"


@interface ScheduleTableViewController ()


@end

@implementation ScheduleTableViewController

static BOOL doesntHaveClasses;



-(id) initWithTerm: (NSString *) term andTitle:(NSString *)title{
    self = [super init];
    if(self){
        doesntHaveClasses = NO;
        self.term = term;
        self.title = title;
        self.classes = nil;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNIB = [UINib nibWithNibName:@"ClassCell" bundle:nil];
    if (cellNIB){
        [self.tableView registerNib:cellNIB forCellReuseIdentifier:SCHEDULE_CELL_IDENTIFIER];
    }
    else NSLog(@"failed to load nib");
    
    UINib *defCellNIB = [UINib nibWithNibName:@"TermCell" bundle:nil];
    if (cellNIB){
        [self.tableView registerNib:defCellNIB forCellReuseIdentifier:@"TermCell"];
    }
    else NSLog(@"failed to load nib");

    
    BUBrainClient *client = [BUBrainClient sharedClient];
    if([client areCredentialsStored]){
        //NSLog(@"Credentials were found in BUBrainClient");
        [client requestAuthenticationWithStoredCredentialsAndCompletion:^(NSString *response, NSError *error) {
            if(!error){
                [client scheduleForSemester:_term andCompletion:^(NSString *classes, NSError *error) {
                    if(!error){
                        [self parseScheduleAndUpdateTable:classes];
                        [self.activityIndicator stopAnimating];
                    }
                    
                }];
            }
            else{//Login was not successfull
                NSLog(@"%@", error);
            }
        }];
    }
    else{//Credentials not found so get them from previous request!
        //NSLog(@"The credentials were not found in BUBrainClient");
        BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
        NSArray *arr = [cred getCredentials];
        if(arr)
            [client requestAuthenticationWithUser:arr[0]
                                      andPassword:arr[1]
                                       completion:^(NSString *response, NSError *error) {
                                           if(!error)
                                               [client scheduleForSemester:_term andCompletion:^(NSString *classes, NSError *error) {
                                                   if(!error){
                                                       [self parseScheduleAndUpdateTable:classes];
                                                       [self.activityIndicator stopAnimating];

                                                   }
                                                   
                                               }];
                                       }];
        else {
            //do not have credentials in Keychain
            NSLog(@"Schedule Controller: Did not find user in keychain");
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
        
    }
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.classes == nil && !doesntHaveClasses) {//Only want to do the following if the data hasn't been parsed yet...
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
        self.activityIndicator.color = UIColorFromRGB(0x009933);
        [self.view addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.activityIndicator = nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if ([self.classes count] > 0)
        return [self.classes count];
    else if(doesntHaveClasses)
        return 1;
    else
        return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    
    if ([self.classes count ] > 0) {
        ClassCell  *cell1 = (ClassCell *)[tableView dequeueReusableCellWithIdentifier:SCHEDULE_CELL_IDENTIFIER forIndexPath:indexPath];
        // Configure Cell
        if (cell1 == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ClassCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell1 = [topLevelObjects objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ClassInfo *aClass = [self.classes objectAtIndex:indexPath.row];
        [cell1.time setText:[[[aClass time]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        [cell1.days setText:[[[aClass days]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        [cell1.className setText:[[[aClass className]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        [cell1.where setText:[[[aClass where]componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "]];
        cell = (UITableViewCell *) cell1;
    }
    else{
         cell  = [tableView dequeueReusableCellWithIdentifier:@"TermCell" forIndexPath:indexPath];
        if (cell == Nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TermCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"No Classes Found";
        cell.accessoryType =  UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result;
    result = 120.0f;
    return result;
}

//parses and updates table
- (void)parseScheduleAndUpdateTable: (NSString *) schedule{

    OGNode *data =  [ObjectiveGumbo parseDocumentWithString:schedule];
    NSArray * elements = [data elementsWithClass:@"pagebodydiv"];
    if ([elements count] > 0) {
        NSMutableArray * allClasses = [[NSMutableArray alloc] init];
        NSArray *classes = [[elements objectAtIndex:0] elementsWithClass:@"datadisplaytable"];
        
        BOOL foundClasses = NO;
        for (int i = 0; i < [classes count]; i = i+2 ) {
            ClassInfo *aClass = [[ClassInfo alloc]init];
            foundClasses = YES;
            // i
            OGElement *titleElement = [[[classes objectAtIndex:i] elementsWithClass:@"captiontext"] objectAtIndex:0];
            [aClass setClassName:[titleElement text]];
            
            // i+1
            NSArray *otherInformation = [[classes objectAtIndex:i+1] elementsWithClass:@"dddefault"];
            
            for (int j = 0; j < [otherInformation count]; j++) {
                OGElement *info =  [otherInformation objectAtIndex:j];
                //NSLog(@"%d: %@", j,[info text]);
                switch (j) {
                    case 1://time
                        [aClass setTime:[info text]];
                        //NSLog(@"Time: %@", [aClass time]);
                        break;
                        
                    case 2: //days
                        [aClass setDays:[info text]];
                        //NSLog(@"Days: %@", [aClass days]);
                        break;
                        
                    case 3: //where
                        [aClass setWhere:[info text]];
                        //NSLog(@"Where: %@", [aClass where]);
                        break;
                }
            }
            [allClasses addObject:aClass];
        }
        if (foundClasses) {
            [self setClasses:allClasses];
            [self.tableView reloadData];
            self.tableView.scrollEnabled = YES;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        else{
            doesntHaveClasses = YES;
            [self setClasses:nil];
            [self.tableView reloadData];
        }

   
    }
    
}

//to hide empty cells
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}
//to hide empty cells
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
    
}

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
