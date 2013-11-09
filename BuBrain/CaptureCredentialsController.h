//
//  CaptureCredentialsController.h
//  BuBrainTest
//
//  Created by Cezar Cocu on 6/15/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//
@protocol CaptureCredentialsDelegate <NSObject>

@optional
-(void)didCaptureValidCredentialswithUser: (NSString*) userID andPassword: (NSString*) password;

-(void) didCancelCaptureCredentials;

@end

#import <UIKit/UIKit.h>
#import <Security/Security.h>



@interface CaptureCredentialsController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak)  id<CaptureCredentialsDelegate> delegate;

@end


