//
//  BNumberRequester.h
//  BU Brain
//
//  Created by Cezar Cocu on 6/24/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <ObjectiveGumbo.h>
#import "BNumberControllerViewController.h"
#import "RedirectDetector.h"
#import "BuBrainCredentials.h"


@interface BUBrainClient : AFHTTPSessionManager 

@property (nonatomic, weak) NSString * username;
@property (nonatomic, weak) NSString * password;

+(BUBrainClient *)sharedClient;

-(BOOL) areCredentialsStored;
-(void) resetCredentials;

-(NSURLSessionDataTask *) requestAuthenticationWithUser: (NSString *) user
                                            andPassword: (NSString *) password
                                             completion:(void (^)(NSString * response, NSError *error) )completion;

-(NSURLSessionDataTask *) requestAuthenticationWithStoredCredentialsAndCompletion:(void (^)(NSString * response, NSError *error) )completion;

-(NSURLSessionDataTask *) requestBNumberWithCompletion:(void (^)(NSString * bNumber, NSError *error) )completion;


-(NSURLSessionDataTask *) semestersForScheduleAvailableWithCompletion:(void (^)(NSArray* bNumber, NSError *error) )completion;

-(NSURLSessionDataTask *) semestersForGradesAvailableWithCompletion:(void (^)(NSArray* bNumber, NSError *error) )completion;

-(NSURLSessionDataTask *) scheduleForSemester:(NSString *) semester andCompletion:(void (^)(NSString* classes, NSError *error) )completion;

-(NSURLSessionDataTask *) scheduleGridForSemester:(NSString *) semester andCompletion:(void (^)(NSString* responseHTML, NSError *error) ) completion;

-(NSURLSessionDataTask *) getUndergradTranscriptWithCompletion:(void (^)(NSString* responseHTML, NSError *error) )completion;

-(NSURLSessionDataTask *) getGradesforSemester:(NSString*) semester WithCompletion:(void (^)(NSString* responseHTML, NSError *error) )completion;

@end
