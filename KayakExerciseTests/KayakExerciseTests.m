//
//  KayakExerciseTests.m
//  KayakExerciseTests
//
//  Created by Er Li on 8/16/15.
//  Copyright (c) 2015 elieric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MasterViewController.h"
@interface KayakExerciseTests : XCTestCase
@property (nonatomic) MasterViewController *masterView;
@end

@implementation KayakExerciseTests

- (void)setUp {
    [super setUp];
    self.masterView = [[MasterViewController alloc]init];
}

-(void)testFetchingData{
    
    [self.masterView fetchDataWithUrlString:@"https://www.kayak.com/h/mobileapis/directory/airlines" block:^(BOOL succeeded, NSError *error) {
        XCTAssert(succeeded, @"Get data success");
    }];
}

- (void)tearDown {
    [super tearDown];
}


@end
