//
//  TranscriptViewController.m
//  BU Brain
//
//  Created by Cezar Cocu on 12/29/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "TranscriptViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TranscriptViewController ()
@property ( nonatomic) BOOL attemptedToGetCredentials;
@end

@implementation TranscriptViewController

- (id)init{
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Transcript";
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_attemptedToGetCredentials) {
        _webView =  [[UIWebView alloc]initWithFrame:self.view.bounds];
        self.webView.frame = self.view.bounds;
        [self.webView setDelegate:self];
        [self.webView setScalesPageToFit:YES];
        [self.view addSubview:_webView];
        
        [self requestTranscriptWithUser:nil
                            andPassword:nil];
    }

}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.currentTask cancel];
    [self.alertView dismissWithClickedButtonIndex:0
                                         animated:YES];
    self.currentTask = nil;
    self.alertView = nil;
}

- (void) requestTranscriptWithUser: (NSString *) user andPassword: (NSString *) password{
    
    
    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
    NSArray *arr = [cred getCredentials];
    if (!user || !password) {
        user = arr[0];
        password = arr[1];
    }
    if(user && password){
        BUBrainClient *client = [BUBrainClient sharedClient];
        _currentTask = [client requestAuthenticationWithUser:user
                                                 andPassword:password
                                                  completion:^(NSString *response, NSError *error) {
            if(!error){
                _currentTask = [client getUndergradTranscriptWithCompletion:^(NSString *responseHTML, NSError *error) {
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
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                    [self.alertView show];
                    NSLog(@"Transcript: Could not log in!");
                }
                
                NSLog(@"%@", error);
                
            }
        }];
    }
    else{//Credentials not in Keychain
        _attemptedToGetCredentials = YES;
        CaptureCredentialsController *capCredentialsController = [[CaptureCredentialsController alloc] init];
        capCredentialsController.delegate = self;
        [self presentViewController:capCredentialsController animated:YES completion:nil];
    }
    
    [self SetUpActivityIndicator];
}

-(void) SetUpActivityIndicator{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.webView.frame = self.view.bounds;
    
    CGRect screenRect = self.view.bounds;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    
    if ( UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {//only if from landscape
        [self.webView stringByEvaluatingJavaScriptFromString:@" location.hash = '#trans_totals' "];
        
    }
    else{//only if from portrait
        [self.webView stringByEvaluatingJavaScriptFromString:@" location.hash = '#trans_totals' "];

    }
}
#pragma -mark CaptureCredentialsDelegate
-(void)didCaptureValidCredentialswithUser: (NSString*) userID andPassword: (NSString*) password{
    
    [self requestTranscriptWithUser:userID andPassword:password];
}

-(void) didCancelCaptureCredentials{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark WebView Delegate


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
    [self.webView stringByEvaluatingJavaScriptFromString:@" location.hash = '#trans_totals' "];
}

#pragma mark - UiAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
