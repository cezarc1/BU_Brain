//
//  GradesViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 12/31/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "GradesViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GradesViewController ()

@end

@implementation GradesViewController

-(id)initWithSemester: (NSString *) semester andTitle: (NSString *) title{
    self = [super init];
    if(self){
        _semester = semester;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.view addSubview:_webView];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.webView.frame= self.view.frame;
    [self requestGrades];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTask cancel];
    [self.alertView dismissWithClickedButtonIndex:0
                                         animated:YES];
    self.currentTask = nil;
    self.alertView = nil;
}

- (void)requestGrades{
    BUBrainClient *client = [BUBrainClient sharedClient];
    self.currentTask = [client requestAuthenticationWithStoredCredentialsAndCompletion:^(NSString *response, NSError *error) {
        if (!error) {
            self.currentTask = [client getGradesforSemester:_semester WithCompletion:^(NSString *responseHTML, NSError *error) {
                if (!error) {
                    [self setBaseHTML:responseHTML];
                    [self.webView loadHTMLString:responseHTML
                                         baseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"BU-Brain Sub Domain"]]];
                }
                else{
                    [self.activityIndicator stopAnimating];
                    if ([error code] != -999) {//cancel
                        self.alertView = [[UIAlertView alloc] initWithTitle:@"Application Error!"
                                                                    message:[error localizedDescription]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                        [self.alertView show];
                    }
                    NSLog(@"Transcript Error: %@", [error description]);
                }
            }];
        }
        else{
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
    [self setUpActivityIndicator];
    
}
-(void) setUpActivityIndicator{
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect screenRect = self.view.bounds;
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
        self.activityIndicator.color = UIColorFromRGB(0x009933);
        [self.view addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.webView.frame = self.view.bounds;
    
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
    //[self.webView stringByEvaluatingJavaScriptFromString:@" location.hash = '#trans_totals' "];
}
#pragma mark - UiAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
