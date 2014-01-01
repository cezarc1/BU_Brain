//
//  TermsViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 10/20/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "TermsViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define REUSE_IDENTIFIER @"TermCell"


@interface TermsViewController ()

@property ( nonatomic) BOOL attemptedToGetCredentials;
@end

@implementation TermsViewController



- (id)initWithTypeofTerm: (BUAvailableTerms) typeTerm{
    self = [super init];
    if (self) {
        _availableTerms = nil;
        _attemptedToGetCredentials = NO;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.alertView = nil;
        self.currentTask = nil;
        _typeofTerm = typeTerm;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Terms";
    
    UINib *cellNIB = [UINib nibWithNibName:@"TermCell" bundle:nil];
    if (cellNIB){
        [self.tableView registerNib:cellNIB forCellReuseIdentifier:REUSE_IDENTIFIER];
    }
    else NSLog(@"failed to load nib");

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = UIColorFromRGB(0x009933);
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    self.currentTask = nil;
    self.alertView = nil;
    
  if(!_availableTerms && !_attemptedToGetCredentials){
      [self getTerms];
  }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTask cancel];
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    self.currentTask = nil;
    self.alertView = nil;
}


-(void) getTerms{
    
    //Must get credentials first
    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
    NSArray *credentials =[cred getCredentials];
    if(credentials){
        [self reloadTermsWithUser:credentials[0] andPassword:credentials[1]];
    
    }
    else{//not in Keychain
        _attemptedToGetCredentials = YES;
        CaptureCredentialsController *capCredentialsController = [[CaptureCredentialsController alloc] init];
        capCredentialsController.delegate = self;
        [self presentViewController:capCredentialsController animated:YES completion:nil];
        
    }

}

-(void)reloadTermsWithUser: (NSString*) user andPassword: (NSString*) password{
    [self.activityIndicator startAnimating];
    BUBrainClient * client = [BUBrainClient sharedClient];
    self.currentTask = [client requestAuthenticationWithUser:user andPassword:password completion:^(NSString *response, NSError *error) {
        if (!error)
            [self requestTermswithClient:client withUser:user andPassword:password];
        else {
            [self.activityIndicator stopAnimating];
            if ([error code] != -999) {//cancel
                self.alertView = [[UIAlertView alloc] initWithTitle:@"Could not log in!"
                                                            message:[error localizedDescription]
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
                [self.alertView show];
                NSLog(@"%@", error);
            }
            
        }
    }];
}

-(void)requestTermswithClient: (BUBrainClient*) client withUser: (NSString*) user andPassword: (NSString*) password{
    switch (_typeofTerm) {
        case BUAvailableTermsSchedule:{
            self.currentTask = [client semestersForScheduleAvailableWithCompletion:^(NSArray *bNumber, NSError *error) {
                if (!error) {
                    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
                    [cred StoreUser:user andPassword:password];
                    [self setAvailableTerms:bNumber];
                    [self.activityIndicator stopAnimating];
                    self.tableView.scrollEnabled = YES;
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    [self.tableView reloadData];
                }
                else  NSLog(@"%@", error);
            }];
        }
            break;
        case BUAvailableTermsGrade:{
            self.currentTask = [client semestersForGradesAvailableWithCompletion:^(NSArray *bNumber, NSError *error) {
                if (!error) {
                    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
                    [cred StoreUser:user andPassword:password];
                    [self setAvailableTerms:bNumber];
                    [self.activityIndicator stopAnimating];
                    self.tableView.scrollEnabled = YES;
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    [self.tableView reloadData];
                }
                else  NSLog(@"%@", error);
            }];
        }
            break;
    }




}

#pragma -mark CaptureCredentialsDelegate

-(void)didCaptureValidCredentialswithUser: (NSString*) userID andPassword: (NSString*) password{
    
    [self reloadTermsWithUser:userID andPassword:password];
}

-(void) didCancelCaptureCredentials{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UiAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
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
    return _availableTerms.count-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:REUSE_IDENTIFIER];
        
    }
   
    OGElement *ele = _availableTerms[indexPath.row+1];
    cell.textLabel.textColor = UIColorFromRGB(0x006221);
    cell.textLabel.text =  ele.text;
    cell.textLabel.font = [UIFont systemFontOfSize:21.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OGElement *ele = _availableTerms[indexPath.row+1];
    NSError *error = nil;
    NSRegularExpression *quoteRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    NSTextCheckingResult *match = [quoteRegex firstMatchInString:ele.html
                                                    options:0
                                                      range:NSMakeRange(0, [ele.html length])];
    
    NSRange accessTokenRange = [match rangeAtIndex:0];
    NSString *value = [ele.html substringWithRange:accessTokenRange];
 
    if (_typeofTerm == BUAvailableTermsSchedule) {
        ScheduleTableViewController *cc = [[ScheduleTableViewController alloc] initWithTerm:value andTitle:ele.text];
        [self.navigationController pushViewController:cc animated:YES];
    }
    else if (_typeofTerm == BUAvailableTermsGrade) {
        GradesViewController *st = [[GradesViewController alloc] initWithSemester:value andTitle:ele.text];
        [self.navigationController pushViewController:st animated:YES];
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result;
    result = 70.0f;
    return result;
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
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
}


@end
