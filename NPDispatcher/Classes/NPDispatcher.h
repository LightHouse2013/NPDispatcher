//
//  NPDispatcher.h
//  Pods
//
//  Created by zhang.wenhai on 6/3/17.
//
//

#import <Foundation/Foundation.h>
#import "NPTask.h"


typedef void(^NPDispatchTasksCallBack)(NSArray<NPTask *> *tasks);
@interface NPDispatcher : NSObject

+ (id)dispatcherWithMaxTaskCount:(NSUInteger)maxCount;
- (id)initWithMaxTaskCount:(NSUInteger)maxCount;

- (void)dispatchTasksCallBack:(NPDispatchTasksCallBack)callBack;

- (void)addTask:(NPTask *)task;
- (void)addTasks:(NSArray<NPTask *> *)tasks;
- (void)insertTask:(NPTask *)task atIndex:(NSInteger)index;
- (void)cancelTask:(NPTask *)task;
- (NSArray<NPTask *> *)cancelNotStartTasks;

@end
