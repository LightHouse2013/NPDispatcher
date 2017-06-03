# NPDispatcher

[![CI Status](http://img.shields.io/travis/zhang.wenhai/NPDispatcher.svg?style=flat)](https://travis-ci.org/zhang.wenhai/NPDispatcher)
[![Version](https://img.shields.io/cocoapods/v/NPDispatcher.svg?style=flat)](http://cocoapods.org/pods/NPDispatcher)
[![License](https://img.shields.io/cocoapods/l/NPDispatcher.svg?style=flat)](http://cocoapods.org/pods/NPDispatcher)
[![Platform](https://img.shields.io/cocoapods/p/NPDispatcher.svg?style=flat)](http://cocoapods.org/pods/NPDispatcher)

NPDispatcher is a task dispatcher library for iOS and Mac OS X, It can limit max count of running tasks at the same time.

Choose NPDispatcher for your next project, you'll be happy you did!

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
| NPDispatcher Version | Minimum iOS Target  | Minimum OS X Target  | Minimum watchOS Target  | Minimum tvOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:----------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
| 1.x | iOS 8 | OS X 10.9 | watchOS 2.0 | tvOS 9.0 | Xcode 7+ is required. 

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like NPDispatcher in your projects.You can install it with the following command:
```bash
$ gem install cocoapods
```
> CocoaPods 0.39.0+ is required to build NPDispatcher 1.0.0.

#### Podfile

To integrate NPDispatcher into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'NPDispatcher', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage
#### NPTask
> NPTask is a carrier for task, distinguish the task with Identifier. create the task with following method and start it.

``` Objective-C
+ (id)taskWithIdentifier:(NSUInteger)identifier dataObject:(id)data;
- (id)initWithIdentifier:(NSUInteger)identifier dataObject:(id)data;
```
``` Objective-C
- (void)start;
```

And when the task complete, you can commit(success) or fail it.
``` Objective-C
- (void)commit;
- (void)fail:(NSError *)error;
```

#### NPDispatcher
> NPDispatcher is the manager of task running and pending.　　　　　　

　　　　　　
> 1 . initial it. set max count of the running tasks at the same time and new task dispatched call back.

``` Objective-C
+ (NPDispatcher *)dispatcherWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack;
- (NPDispatcher *)initWithMaxTaskCount:(NSUInteger)maxCount taskArrivedCallBack:(NPTaskArrivedCallBack)callBack;
```
> 2 . add tasks.

``` Objective-C
- (void)addTask:(NPTask *)task;
- (void)addTasks:(NSArray<NPTask *> *)tasks;
- (void)insertTask:(NPTask *)task atIndex:(NSInteger)index; 
```

> 3 . remove task when complete.

``` Objective-C
- (void)removeTask:(NPTask *)task;
```
> 4 . cancel not start tasks if not necessary to execute.

``` Objective-C
- (NSArray<NPTask *> *)cancelNotStartTasks;
```

### Example Usage
> 1 . Define
``` Objective-C
@property (nonatomic, strong) NPDispatcher *dispatcher;
```
> 2 . Initial
``` Objective-C
__weak typeof(self)weakSelf = self;
_dispatcher = [NPDispatcher dispatcherWithMaxTaskCount:5 taskArrivedCallBack:^(NSArray<NPTask *> *tasks) {
    NSUInteger taskCount = tasks.count;
    for (NSUInteger index = 0; index < taskCount; index ++) {
        NPTask *task = [tasks firstObject];
        //If Success
        [task commit];
        //If Fail
        [task fail:[NSError errorWithDomain:@"NPDispatcher" code:-1 userInfo:@{@"error" : @"I`m uncareful failed."}]];
    }
}];
```
> 3 . Add Tasks
``` Objective-C
NSMutableArray<NPTask *> *testTasks = [NSMutableArray arrayWithCapacity:10];
for (int index = 0; index < 10; index ++) {
    //1. Create task
    NPTask *task = [NPTask taskWithIdentifier:index dataObject:nil];
    //2. Start task
    [task start];
    //3. Set success call back
    task.successCallBack = ^(NPTask *t) {
        NSLog(@"task %lu success.", t.identifier);
        //6. Remove complete task from dispatcher
        [weakSelf.dispatcher removeTask:t];
    };
    //4. Set failed call back
    task.failedCallBack = ^(NPTask *t, NSError *error) {
        NSLog(@"task %lu failed:%@.", t.identifier, t.error.description);
        //6. Remove complete task from dispatcher
        [weakSelf.dispatcher removeTask:t];
    };
    [testTasks addObject:task];
}
//5. Add tasks
[_dispatcher addTasks:testTasks];
```

## Author

zhang.wenhai, zhang_mr1989@163.com

## License

NPDispatcher is available under the MIT license. See the LICENSE file for more info.
