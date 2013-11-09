//
//  BNumberControllerViewController.m
//  BuBrainTest
//
//  Created by Cezar Cocu on 6/13/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "BNumberControllerViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BNumberControllerViewController(){
    bool _attemptedTogetCredentails;
}

@end

@implementation BNumberControllerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.service = @"BUBrain";
        self.serviceNumber = @"BUBrainNumber";
        self.userNameWasStored = NO;
        self.didAuthenticate = NO;
        self.receivedBNumber = NO;
        self.sid = @"";
        self.pin = @"";
        _attemptedTogetCredentails = NO;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
              
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"BNumber";
    _BNumber.text = nil;
    _attemptedTogetCredentails = NO;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (!_attemptedTogetCredentails) {
        //Must get credentials first
        BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
        NSArray * credentials =[cred getCredentials];
        if(credentials){
            [self didCaptureValidCredentialswithUser:credentials[0] andPassword:credentials[1]];
            
        }
        else{//not in Keychain
            _attemptedTogetCredentails = YES;
            CaptureCredentialsController *capCredentialsController = [[CaptureCredentialsController alloc] init];
            capCredentialsController.delegate = self;
            [self presentViewController:capCredentialsController animated:YES completion:nil];
            
        }

    }
    
}


-(void)didCaptureValidCredentialswithUser: (NSString*) userID andPassword: (NSString*) password{
    
    _sid = userID;
    _pin = password;
    [self prepareForAuthentication];
    _attemptedTogetCredentails = YES;
}

-(void)didCancelCaptureCredentials{
    _attemptedTogetCredentails = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) prepareForAuthentication{
    _receivedBNumber = NO;
    _didAuthenticate = NO;
    _BNumber.text = @"Retrieving...";
    [self initializeAndStartActivityView];
    [self requestBNumber];
}
-(void) requestBNumber{
    
    
    BUBrainClient *request = [BUBrainClient sharedClient];
    [request requestAuthenticationWithUser: _sid
                               andPassword: _pin
                                completion:^(NSString * response, NSError *error){
                                    if (!error) {
                                        [request requestBNumberWithCompletion:^(NSString *bNumber, NSError *error) {
                                            if (!error) {
                                                [self BNumberRetrieved:bNumber];
                                            }
                                            else {//Error
                                                [self errorOccured:error];
                                            }
                                        }];
                                    }
                                    else{ //Error
                                        [self errorOccured:error];
                                    }
                                }];

}

-(void) initializeAndStartActivityView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.activityIndicator.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    self.activityIndicator.color = UIColorFromRGB(0x009933);
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)BNumberRetrieved:(NSString *) bNumber{
    [self.activityIndicator stopAnimating];
    _BNumber.text = bNumber;
    
    BuBrainCredentials *cred = [BuBrainCredentials sharedInstance];
    [cred StoreUser:_sid andPassword:_pin];
    
    _receivedBNumber = YES;
    _userNameWasStored = YES;

}
-(void) errorOccured: (NSError *) error{
    NSLog(@"Error: %@", error);
    
    _BNumber.text = [error domain];
    if( _userNameWasStored && [error code] == 1){
        _userNameWasStored = NO;
        [SSKeychain deletePasswordForService:_service account:_sid];
        [SSKeychain deletePasswordForService:_serviceNumber account:_sid];
        [self doNotStoreCredentails];
        
    }
    
}



- (void)doNotStoreCredentails{
    _sid = nil;
    _pin = nil;
    _userNameWasStored = NO;
    _receivedBNumber = NO;
    [[BUBrainClient sharedClient] resetCredentials];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _sid =nil;
    _pin = nil;
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
 
    [self setBNumber:nil];
    [self setSid:nil];
    [self setPin:nil];
    [self setActivityIndicator:nil];
    // Release any retained subviews of the main view.
}


@end
