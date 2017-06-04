//
//  NPTask.m
//  Pods
//
//  Created by zhang.wenhai on 6/3/17.
//
//

#import "NPTask.h"

@implementation NPTask

+ (id)taskWithIdentifier:(NSUInteger)identifier dataObject:(id)data {
    return [[self alloc] initWithIdentifier:identifier dataObject:data];
}

- (id)initWithIdentifier:(NSUInteger)identifier dataObject:(id)data {
    if (self = [super init]) {
        _identifier = identifier;
        _dataObject = data;
        _state = kNPTaskStateInitial;
    }
    return self;
}

- (void)start {
    _state = kNPTaskStateProcessing;
    _beginDate = [NSDate date];
}

- (void)commit {
    _state = kNPTaskStateSuccess;
    _endDate = [NSDate date];
    
    if (_successCallBack) {
        _successCallBack(self);
    }
}

- (void)fail:(NSError *)error {
    _state = kkNPTaskStateFailed;
    _error = error;
    _endDate = [NSDate date];
    
    if (_failedCallBack) {
        _failedCallBack(self);
    }
}

- (BOOL)isEqual:(id)object {
    NPTask *t = object;
    return (t.identifier == self.identifier);
}

@end
