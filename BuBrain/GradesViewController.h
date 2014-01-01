//
//  GradesViewController.h
//  BU Brain
//
//  Created by Cezar Cocu on 12/31/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BUBrainClient.h"

@interface GradesViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic, readonly) NSString *semester;
@property (strong, nonatomic) NSURLSessionDataTask *currentTask;
@property (strong, nonatomic) NSString *baseHTML;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIAlertView *alertView;

-(id)initWithSemester: (NSString *) semester andTitle: (NSString *) title;

@end
