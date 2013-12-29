//
//  GridScheduleViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 12/29/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "GridScheduleViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GridScheduleViewController ()

@end

@implementation GridScheduleViewController

- (id) initWithTerm:(NSString *) term andTitle: (NSString *) title{
    
    self = [super init];
    if(self){
        _term = term;
        _termTitle =  title;
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
    }
    return self;
}
- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//

- (void)viewDidLoad
{
    [super viewDidLoad];
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft);
    [self.navigationBar setTitle:[NSString stringWithFormat:@"%@ - Grid", _termTitle]];
    [self.webView setDelegate:self];
    [self sendRequestForGridSchedule];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTask cancel];
    _currentTask = nil;
}

-(void)sendRequestForGridSchedule{
    BUBrainClient *client = [BUBrainClient sharedClient];
    NSAssert(_term, @"term must be valid");
    _currentTask =  [client scheduleGridForSemester:[self GridDateforTerm:_term]
                                      andCompletion:^(NSString *responseHTML, NSError *error) {
                                          if (!error) {
                                              [self.webView loadHTMLString:responseHTML
                                                                   baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"BU-Brain Sub Domain"]]];
                                          }
                                          else
                                              NSLog(@"Error: Grid %@", [error description]);
                                          
                                      }];
}

-(NSString *)GridDateforTerm: (NSString *) term{
    NSString *year =  [term substringWithRange:NSMakeRange(0, 4)];
    NSString *month =  [term substringWithRange:NSMakeRange(4, 1)];
    NSString *date = [NSString stringWithFormat:@"0%@/01/%@", month, year];
    NSLog(@"date %@ for term %@", date, term);
    return date;
}
#pragma -mark Forced Portrait Rotations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma -mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    self.activityIndicator.color = UIColorFromRGB(0x009933);
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
