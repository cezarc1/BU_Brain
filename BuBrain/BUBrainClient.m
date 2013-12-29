//
//  BNumberRequester.m
//  BU Brain
//
//  Created by Cezar Cocu on 6/24/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "BUBrainClient.h"
@interface BUBrainClient ()
@end

@implementation BUBrainClient

+ (BUBrainClient *)sharedClient{
    static BUBrainClient * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [RedirectDetector sharedClient];
        NSURL *baseUrl = [[RedirectDetector sharedClient] baseURL];
        if (!baseUrl){
            NSString *storedDomain = [[NSUserDefaults standardUserDefaults] stringForKey:@"BU-Brain Sub Domain"];
            if (!storedDomain) {
                storedDomain = @"https://ssb.cc.binghamton.edu/";
            }
            baseUrl = [NSURL URLWithString:storedDomain];
        }
        
        
        NSLog(@"BU-Client baseURL: %@", baseUrl);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"BU Brain iOS 1.0"
                                            }];
        
        NSURLCache *cache  = [[NSURLCache alloc] initWithMemoryCapacity:5 * 1024 * 1024 // in bytes
                                                           diskCapacity:10 * 1024 * 1024
                                                               diskPath:nil];
        [config setURLCache:cache];
        
        _sharedClient  = [[BUBrainClient alloc] initWithBaseURL:baseUrl
                                              sessionConfiguration:config];
         _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"TESTID=set" forHTTPHeaderField:@"Cookie"];
        _sharedClient.username = nil;
        _sharedClient.password = nil;
        

    });
    return _sharedClient;
}

- (void) setTaskWillPerformHTTPSRedirectionBlock:(NSURLRequest *(^)(NSURLSession *, NSURLSessionTask *, NSURLResponse *, NSURLRequest *))block{
    NSLog(@"Here");
}


-(BOOL) areCredentialsStored{
    //NSLog(@"%@: %@", _username, _password);
    if (_username && _password)
        return YES;
    else
        return NO;
    
}

-(void) resetCredentials{
    NSLog(@"BUBrainClient: Credentials lost");
    _username = nil;
    _password = nil;
}

-(NSURLSessionDataTask *) requestAuthenticationWithUser: (NSString *) user
                                            andPassword: (NSString *) password
                                             completion:(void (^)(NSString * response, NSError *error) )completion {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.requestSerializer setValue:@"TESTID=set" forHTTPHeaderField:@"Cookie"]; //Need to do this to make sure I already don't have a valid token
    NSURLSessionDataTask *task = [self POST:@"/banner/twbkwbis.P_ValLogin"
                                  parameters:@{@"sid": user, @"PIN":password}
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         
                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                         NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *) task.response;
                                         if ([self isUserAuthenticatedfor:httpResponse]) {
                                             [self setUsername:user];//Storing user & password for future calls
                                             [self setPassword:password];
                                             NSString * stringResponse = [NSString stringWithUTF8String:[responseObject bytes]];
                                             completion(stringResponse, nil);
                                         }
                                         else{
                                             NSError * error = [NSError errorWithDomain:@"Invalid Credentials" code:1 userInfo:nil];
                                             [self resetCredentials];
                                             completion(nil, error);
                                         }
                                         
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                         completion(nil, error);
                                     }];

    return task;
    
}

-(NSURLSessionDataTask *) requestAuthenticationWithStoredCredentialsAndCompletion:(void (^)(NSString * response, NSError *error) )completion{
    if (![self areCredentialsStored]) {
        NSError *err = [NSError errorWithDomain:@"No credentials Found" code:5 userInfo:nil];
        completion(nil, err);
        return nil;
    }
    return [self requestAuthenticationWithUser:_username andPassword:_password completion:completion];
    
}
- (BOOL) isUserAuthenticatedfor: (NSHTTPURLResponse *)httpResponse{
    
    
    NSDictionary *header = [httpResponse allHeaderFields];
    NSString* cookie = [header objectForKey:@"Set-Cookie"];
    //NSLog(@"%@", cookie);
    if( ! [cookie  isEqualToString:@"SESSID=;expires=Mon, 01-Jan-1990 08:00:00 GMT"]){
        [self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
        
        return YES;
    }
    else {
        return NO;
    }
}

- (NSURLSessionDataTask *) requestBNumberWithCompletion:(void (^)(NSString * bNumber, NSError *error) )completion{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionDataTask *task = [self GET:@"banner/BWCKYSWPS.py_CreateSurvey"
                          parameters:@{@"app_in":@"BU_BNUMBER_LOOK"}
                             success:^( NSURLSessionDataTask *task , id responseObject){
                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                 
                                 NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *) task.response;
                                 if([self isUserAuthenticatedfor:httpResponse]){
                                     NSString * responseString = [NSString stringWithUTF8String:[responseObject bytes]];

                                     OGNode *data = [ObjectiveGumbo parseDocumentWithString: responseString];
                                     OGElement *mainLabel = [[data elementsWithClass:@"pllabel"] objectAtIndex:0];
                                     NSArray *fields = mainLabel.children;
                                     OGElement *bnumber = [fields objectAtIndex:1];
                                     if([bnumber text])
                                         completion([bnumber text], nil);
                                     else{
                                         NSError * error = [NSError errorWithDomain:@"Could not Parse BNumber" code:3 userInfo:nil];
                                         completion(nil, error);
                                     }
                                 }
                                 else{
                                     NSError * error = [NSError errorWithDomain:@"Not Authorized" code:2 userInfo:nil];
                                     completion(nil, error);
                                 }

                             }
                             failure:^( NSURLSessionDataTask *task , NSError *error ){
                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                 completion(nil, error);
                                 
                             }];
    return task;

}

-(NSURLSessionDataTask *) semestersAvailableWithCompletion:(void (^)(NSArray* bNumber, NSError *error) )completion{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSURLSessionDataTask *task = [ self GET:@"/banner/bwskfshd.P_CrseSchdDetl"
                                parameters:Nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *) task.response;
                                       if([self isUserAuthenticatedfor:httpResponse]){
                                           NSString *responseString = [NSString stringWithUTF8String:[responseObject bytes]];
                                           NSArray *terms = [self parseDocumentForSemesterIDwithString:responseString];
                                           if (!terms) {
                                               NSError * error = [NSError errorWithDomain:@"Could not Parse Terms" code:4 userInfo:nil];
                                               completion(nil,error);
                                           }
                                           else completion(terms, nil);
                                           
                                       }
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       completion(nil, error);
                                   }];
                                       
    return task;
}
-(NSURLSessionDataTask *) scheduleForSemester:(NSString *) semester andCompletion:(void (^)(NSString* classes, NSError *error) )completion{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask *task = [self POST:@"/banner/bwskfshd.P_CrseSchdDetl"
                                 parameters:@{@"term_in": semester}
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                        NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *) task.response;
                                        if([self isUserAuthenticatedfor:httpResponse]){
                                            NSString *responseString = [NSString stringWithUTF8String:[responseObject bytes]];
                                            OGNode *data = [ObjectiveGumbo parseDocumentWithString: responseString];
                                            OGElement *mainLabel = [[data elementsWithClass:@"pagebodydiv"] objectAtIndex:0];
                                            completion(mainLabel.html, nil);
                                        }
                                        else{
                                            NSError * error = [NSError errorWithDomain:@"Not Authorized" code:2 userInfo:nil];
                                            completion(nil, error);
                                        }
                                        

                                    }
                                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                        completion(nil, error);
                                    }];
    return task;
}


-(NSArray*) parseDocumentForSemesterIDwithString: (NSString*) response{
    
    OGNode *data = [ObjectiveGumbo parseDocumentWithString: response];
    OGElement *mainLabel = [[data elementsWithID:@"term_id"] objectAtIndex:0];
    if(!mainLabel) return NULL;
    NSArray *terms = mainLabel.children;
    return terms;
}

-(NSURLSessionDataTask *) scheduleGridForSemester:(NSString *) semester andCompletion:(void (^)(NSString* responseHTML, NSError *error) ) completion{
    NSLog(@"%@", semester);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask *task = [self GET:@"/banner/bwskfshd.P_CrseSchd"
                                parameters:@{@"start_date_in": semester}
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       NSHTTPURLResponse *httpResponse  = (NSHTTPURLResponse *) task.response;
                                       if([self isUserAuthenticatedfor:httpResponse]){
                                           NSString *responseString = [NSString stringWithUTF8String:[responseObject bytes]];
                                           completion([self cleanGridSemester:responseString], nil);
                                       }
                                       else{
                                           NSError * error = [NSError errorWithDomain:@"Not Authorized" code:2 userInfo:nil];
                                           completion(nil, error);
                                       }
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       NSLog(@"header: %@", [[task originalRequest]allHTTPHeaderFields]);
                                       completion(nil, error);
                                   }];
    return task;
    
}

-(NSString *)cleanGridSemester:(NSString *) responseHTML{
    OGNode *data = [ObjectiveGumbo parseDocumentWithString: responseHTML];
    OGElement *mainLabel = [[data elementsWithClass:@"pagebodydiv"] objectAtIndex:0];
    return [NSString stringWithFormat:@"<link type='text/css' href='/css/web_defaultapp.css' rel='stylesheet'></link> %@",
                                    [mainLabel html]];
}



@end
