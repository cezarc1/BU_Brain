//
//  GridScheduleViewController.h
//  BU Brain
//
//  Created by Cezar Cocu on 12/29/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "objc/message.h"
#import "BuBrainCredentials.h"
#import "BUBrainClient.h"

@interface GridScheduleViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString *term;// eg. 201420
@property (strong, nonatomic) NSString *termTitle;// eg. 201420
@property (strong, nonatomic) NSString *baseHTML;// only set after a sucessfull lookup
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSURLSessionDataTask *currentTask;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationSubItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (id) initWithTerm:(NSString *) term andTitle: (NSString *) title;
- (void)handleSwipeRight:(UIScreenEdgePanGestureRecognizer *)recognizer;

@end
