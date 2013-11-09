//
//  CaptureCredentialsController.m
//  BuBrainTest
//
//  Created by Cezar Cocu on 6/15/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "CaptureCredentialsController.h"

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
                                                       delegate:self cancelButtonTitle:@"OK"
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginPressed:self];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_userId setDelegate:self];
    [_password setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view from its nib.
}

-(void)dismissKeyboard {
    [_password resignFirstResponder];
    [_userId resignFirstResponder];
}

-(void)storeCredentialsforUser: (NSString*) user
                   andPassword: (NSString*) password {

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

@end
