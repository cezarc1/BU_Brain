//
//  CaptureCredentialsController.m
//  BuBrainTest
//
//  Created by Cezar Cocu on 6/15/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "CaptureCredentialsController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CaptureCredentialsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (IBAction)loginPressed:(id)sender {
    if (![self.userId.text isEqualToString:@""] && ![self.password.text isEqualToString:@""]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(didCaptureValidCredentialswithUser:andPassword:)] )
                [self.delegate didCaptureValidCredentialswithUser:_userId.text andPassword:_password.text];
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Login!"
                                                        message:@"Please enter non-blank username and password"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }

}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate respondsToSelector:@selector(didCancelCaptureCredentials)])
            [self.delegate didCancelCaptureCredentials];
    }];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setTintColor:UIColorFromRGB(0x009933)];
    [_userId setDelegate:self];
    [_password setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationLandscapeRight  || orientation == UIDeviceOrientationLandscapeLeft) {
        self.disclaimer.hidden = YES;
    }
}



-(void)storeCredentialsforUser: (NSString*) user
                   andPassword: (NSString*) password {

}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            self.disclaimer.hidden = NO;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.disclaimer.hidden = YES;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.disclaimer.hidden = YES;
            break;
        default:
            break;
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidUnload{
    [self setUserId:nil];
    [self setPassword:nil];
}

-(void)dismissKeyboard {
    [_password resignFirstResponder];
    [_userId resignFirstResponder];
}

#pragma -mark Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self loginPressed:self];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
