//
//  mainMenuViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 10/19/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "mainMenuViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define REUSE_IDENTIFIER @"TermCell"

@interface mainMenuViewController ()

@end

@implementation mainMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"BU Brain";
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkRedirect];
    
    UINib *cellNIB = [UINib nibWithNibName:@"TermCell" bundle:nil];
    if (cellNIB){
        [self.tableView registerNib:cellNIB forCellReuseIdentifier:REUSE_IDENTIFIER];
    }
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Get B-Number";
            break;
            
        case 1:
            cell.textLabel.text = @"Get Schedule";
            break;
            
        case 2:
            cell.textLabel.text = @"Settings";
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.textLabel.textColor = UIColorFromRGB(0x006221);
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result;
    result = 70.0f;
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if (indexPath.row == 0) {
        BNumberControllerViewController *bnc = [[BNumberControllerViewController alloc] init];
        [self.navigationController pushViewController:bnc animated:YES];
    }
    else if(indexPath.row == 1){
        TermsViewController *tvc = [[TermsViewController alloc] init];
        [self.navigationController pushViewController:tvc animated:YES];
    }
    
    else if ( indexPath.row == 2){
        SettingsViewController *svc = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    }

    
}

- (void)checkRedirect{
    [[RedirectDetector sharedClient] checkAndUpdateForURL];
    
}
 

@end
