//
//  TranscriptViewController.h
//  BU Brain
//
//  Created by Cezar Cocu on 12/29/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUBrainClient.h"
#import "CaptureCredentialsController.h"

@interface TranscriptViewController : UIViewController <UIWebViewDelegate, CaptureCredentialsDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURLSessionDataTask *currentTask;
@property (strong, nonatomic) NSString *baseHTML;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIAlertView *alertView;


@end
