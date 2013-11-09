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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _availableTerms = nil;
        _attemptedToGetCredentials = NO;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Available Terms";
    
    UINib *cellNIB = [UINib nibWithNibName:@"TermCell" bundle:nil];
    if (cellNIB){
        [self.tableView registerNib:cellNIB forCellReuseIdentifier:REUSE_IDENTIFIER];
    }
    else NSLog(@"failed to load nib");


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = UIColorFromRGB(0x009933);
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
  if(!_availableTerms && !_attemptedToGetCredentials){
      [self getTerms];
  }
}

-(void)didCaptureValidCredentialswithUser: (NSString*) userID andPassword: (NSString*) password{

    [self reloadTermsWithUser:userID andPassword:password];
}

-(void) getTerms{
    
    //Must get credentials first
    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
    NSArray * credentials =[cred getCredentials];
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
    [client requestAuthenticationWithUser:user andPassword:password completion:^(NSString *response, NSError *error) {
        if (!error)
            [client semestersAvailableWithCompletion:^(NSArray *bNumber, NSError *error) {
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
        else {
            [self.activityIndicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not log in!"
                                                            message:@"Provided credentials are not valid"
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"%@", error);
            
        }
    }];
}

-(void) didCancelCaptureCredentials{
    [self.navigationController popViewControllerAnimated:YES];
}

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
    cell.textLabel.text =  ele.text;
    
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
    
    //ScheduleController *sc = [[ScheduleController alloc] initWithTerm:value andTitle:ele.text];
    
    //[self.navigationController pushViewController:sc animated:YES];
    
    ScheduleTableViewController *cc =[[ScheduleTableViewController alloc] initWithTerm:value andTitle:ele.text];
    [self.navigationController pushViewController:cc animated:YES];
    
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
