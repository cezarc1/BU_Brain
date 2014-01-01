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
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeRight);
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.navigationSubItem setTitle:[NSString stringWithFormat:@"%@ - Grid", _termTitle]];
    self.navigationBar.barTintColor =  UIColorFromRGB(0x009933);
    self.navigationBar.translucent = YES;
    
    self.webView.frame = self.view.bounds;
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    
    UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(handleSwipeRight:)];
    [swipeRight setEdges:UIRectEdgeLeft];
    [swipeRight setDelegate:self];
    [self.webView addGestureRecognizer:swipeRight];
    
    [self sendRequestForGridSchedule];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpActivityIndicator];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTask cancel];
    _currentTask = nil;
}

-(void)sendRequestForGridSchedule{
    BUBrainClient *client = [BUBrainClient sharedClient];
    NSAssert(_term, @"term must be valid");
    _currentTask = [client requestAuthenticationWithStoredCredentialsAndCompletion:^(NSString *response, NSError *error) {
        if (!error) {
            _currentTask =  [client scheduleGridForSemester:[self GridDateforTerm:_term]
                                              andCompletion:^(NSString *responseHTML, NSError *error) {
                                                  if (!error) {
                                                      [self setBaseHTML:responseHTML];
                                                      [self.webView loadHTMLString:responseHTML
                                                                           baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"BU-Brain Sub Domain"]]];
                                                  }
                                                  else
                                                      NSLog(@"Error: Grid %@", [error description]);
                                              }];
        }
        else {
            NSLog(@"Error: Could not log in");
        }
    }];

}

-(NSString *)GridDateforTerm: (NSString *) term{
    NSString *year =  [term substringWithRange:NSMakeRange(0, 4)];
    NSString *month =  [term substringWithRange:NSMakeRange(4, 1)];
    NSString *date = [NSString stringWithFormat:@"0%@/15/%@", month, year];
    //NSLog(@"date %@ for term %@", date, term);
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

-(void) setUpActivityIndicator{
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    self.activityIndicator.color = UIColorFromRGB(0x009933);
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

#pragma -mark WebView Delegate



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
}
#pragma -mark UIScreenEdgePanGestureRecognizer delegate

- (void)handleSwipeRight:(UIScreenEdgePanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint vel = [recognizer velocityInView:recognizer.view];
        if (vel.x > 500.0f) {
            if(_baseHTML){
                [[self webView] loadHTMLString:[self baseHTML]
                                       baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"BU-Brain Sub Domain"]]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
