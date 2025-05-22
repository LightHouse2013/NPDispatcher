#import "NPDispatcher.h"
#include <pthread.h>
#import "PriorityQueue.h"

@interface NPDispatcher ()

@property (nonatomic, strong) PriorityQueue<NPTask *> *pendingTasks;
@property (nonatomic, strong) PriorityQueue<NPTask *> *runningTasks;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, assign) NSUInteger maxTaskCount;
@property (nonatomic, copy) NPTaskArrivedCallBack callBack;

@end

@implementation NPDispatcher

#pragma mark - Initial
+ (NPDispatcher *)dispatcherWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack {
    return [[self alloc] initWithMaxTaskCount:maxCount taskArrivedCallBack:callBack];
}

- (NPDispatcher *)initWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack {
    if (self = [super init]) {
        _maxTaskCount = maxCount;
        _callBack = callBack;
        _pendingTasks = [[PriorityQueue alloc] init];
        _runningTasks = [[PriorityQueue alloc] initWithCapacity:maxCount];
        
        _taskQueue = dispatch_queue_create("com.darckknightone.dispatcher.queue", DISPATCH_QUEUE_SERIAL);
        
        int lck = pthread_mutex_init(&_lock, NULL);
        if (lck != 0) {
            NSLog(@"[%@] init pthread lock failed:%d", [self class], lck);
        }
    }
    return self;
}

- (void)dealloc {
    _taskQueue = nil;
    pthread_mutex_destroy(&_lock);
}

#pragma mark - Interface
- (void)addTask:(NPTask *)task {
    if (task) {
        pthread_mutex_lock(&_lock);
        [_pendingTasks addObject:task];
        pthread_mutex_unlock(&_lock);
    }
    [self dispatchTasks];
}

- (void)addTasks:(NSArray<NPTask *> *)tasks {
    if (tasks.count) {
        pthread_mutex_lock(&_lock);
        [_pendingTasks addObjectsFromArray:tasks];
        pthread_mutex_unlock(&_lock);
    }
    [self dispatchTasks];
}

- (void)insertTask:(NPTask *)task atIndex:(NSInteger)index {
    if (task) {
        pthread_mutex_lock(&_lock);
        if (index <= _pendingTasks.count) {
            [_pendingTasks insertObject:task atIndex:index];
        }
        else {
            [_pendingTasks addObject:task];
        }
        pthread_mutex_unlock(&_lock);
    }
    [self dispatchTasks];
}

- (void)removeTask:(NPTask *)task {
    pthread_mutex_lock(&_lock);
    if ([_runningTasks containsObject:task]) {
        [_runningTasks removeObject:task];
    }
    pthread_mutex_unlock(&_lock);
    [self dispatchTasks];
}

- (NSArray<NPTask *> *)cancelNotStartTasks {
    NSArray *leftTasks;
    pthread_mutex_lock(&_lock);
    leftTasks = [NSArray arrayWithArray:_pendingTasks];
    [_pendingTasks removeAllObjects];
    pthread_mutex_unlock(&_lock);
    return leftTasks;
}

#pragma mark - Private
- (void)dispatchTasks {
    pthread_mutex_lock(&_lock);
    if (_runningTasks.count == _maxTaskCount) {
        pthread_mutex_unlock(&_lock);
    }
    else {
        NSMutableArray *newTasks = [NSMutableArray array];
        NSInteger loopCount = _pendingTasks.count;
        for (int index = 0; index < loopCount; index ++) {
            NPTask *t = [_pendingTasks firstObject];
            if (![_runningTasks containsObject:t]) {
                [_runningTasks addObject:t];
                [newTasks addObject:t];
                [_pendingTasks removeObject:t];
            }
            if (_runningTasks.count == _maxTaskCount) {
                break;
            }
        }
        pthread_mutex_unlock(&_lock);
        [self postTasksNotify:newTasks];
    }
}

- (void)popTask:(NPTask *)task {
    pthread_mutex_lock(&_lock);
    if ([_runningTasks containsObject:task]) {
        [_runningTasks removeObject:task];
    }
    pthread_mutex_unlock(&_lock);
}

- (void)postTasksNotify:(NSArray<NPTask *> *)tasks {
    if (_callBack) {
        dispatch_async(_taskQueue, ^{
            _callBack(tasks);
        });
    }
}

@end
