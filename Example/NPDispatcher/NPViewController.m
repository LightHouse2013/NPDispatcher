//
//  NPViewController.m
//  NPDispatcher
//
//  Created by zhang.wenhai on 06/03/2017.
//  Copyright (c) 2017 zhang.wenhai. All rights reserved.
//

#import "NPViewController.h"
#import <NPDispatcher/NPDispatcher.h>

@interface NPViewController ()

@property (nonatomic, strong) NPDispatcher *dispatcher;
@property (nonatomic, strong) NSMutableArray<NPTask *> *ts;
@property (nonatomic, assign) NSInteger index;

@end

@implementation NPViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _ts = [NSMutableArray arrayWithCapacity:10];
    __weak typeof(self)weakSelf = self;
    _dispatcher = [NPDispatcher dispatcherWithMaxTaskCount:5 taskArrivedCallBack:^(NSArray<NPTask *> *tasks) {
        [weakSelf processTasks:tasks];
    }];
    
    NSMutableArray<NPTask *> *testTasks = [NSMutableArray arrayWithCapacity:10];
    for (int index = 0; index < 10; index ++) {
        NPTask *task = [NPTask taskWithIdentifier:index dataObject:nil];
        [task start];
        task.successCallBack = ^(NPTask *t) {
            NSLog(@"task %lu success.", t.identifier);
            [weakSelf.dispatcher removeTask:t];
        };
        task.failedCallBack = ^(NPTask *t, NSError *error) {
            NSLog(@"task %lu failed:%@.", t.identifier, t.error.description);
            [weakSelf.dispatcher removeTask:t];
        };
        
        [testTasks addObject:task];
    }
    [_dispatcher addTasks:testTasks];
}

- (void)processTasks:(NSArray<NPTask *> *)tasks {
    [_ts addObjectsFromArray:tasks];
    
    NSUInteger taskCount = _ts.count;
    for (NSUInteger index = 0; index < taskCount; index ++) {
        NPTask *task = [_ts firstObject];
        [_ts removeObject:task];
        
        if (_index % 2 == 0) {
            [task commit];
        }
        else {
            [task fail:[NSError errorWithDomain:@"NPDispatcher" code:-1 userInfo:@{@"error" : @"I`m uncareful failed."}]];
        }
        _index ++;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
