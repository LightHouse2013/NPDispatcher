//
//  NPDispatcher.h
//  Pods
//
//  Created by zhang.wenhai on 6/3/17.
//
//

#import <Foundation/Foundation.h>
#import "NPTask.h"

typedef void(^NPTaskArrivedCallBack)(NSArray<NPTask *> *tasks);

@interface NPDispatcher : NSObject

+ (NPDispatcher *)dispatcherWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack;
- (NPDispatcher *)initWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack;

- (void)addTask:(NPTask *)task;
- (void)addTasks:(NSArray<NPTask *> *)tasks;
- (void)insertTask:(NPTask *)task atIndex:(NSInteger)index;
- (void)removeTask:(NPTask *)task;
- (NSArray<NPTask *> *)cancelNotStartTasks;

@end
