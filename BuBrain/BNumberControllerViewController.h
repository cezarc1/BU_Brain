//
//  BNumberControllerViewController.h
//  BuBrainTest
//
//  Created by Cezar Cocu on 6/13/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIProgressView+AFNetworking.h"
#import "SSKeychain.h"
#import <ObjectiveGumbo.h>
#import "BuBrainCredentials.h"
#import "CaptureCredentialsController.h"
#import "BUBrainClient.h"
#import "UIProgressView+AFNetworking.h"

@interface BNumberControllerViewController : UIViewController <CaptureCredentialsDelegate>

@property (weak, nonatomic) IBOutlet UILabel *BNumber;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString* sid;
@property (strong, nonatomic) NSString* pin;
@property (strong, nonatomic) NSString* service;
@property (strong, nonatomic) NSString* serviceNumber;
@property BOOL receivedBNumber;
@property  BOOL didAuthenticate;
@property BOOL userNameWasStored;

-(void)doNotStoreCredentails;
-(void)BNumberRetrieved:(NSString *) bNumber;



@end
