//
//  GridScheduleViewController.h
//  BU Brain
//
//  Created by Cezar Cocu on 12/29/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "objc/message.h"
#import "BUBrainClient.h"

@interface GridScheduleViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) NSString *term;// eg. 201420
@property (strong, nonatomic) NSString *termTitle;// eg. 201420
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSURLSessionDataTask *currentTask;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (id) initWithTerm:(NSString *) term andTitle: (NSString *) title;

@end
