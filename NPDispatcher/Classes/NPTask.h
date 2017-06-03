//
//  NPTask.h
//  Pods
//
//  Created by zhang.wenhai on 6/3/17.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kNPTaskStateInitial,
    kNPTaskStateProcessing,
    kNPTaskStateSuccess,
    kkNPTaskStateFailed,
} NPTaskState;

@interface NPTask : NSObject

@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, assign, readonly) NPTaskState state;
@property (nonatomic, strong, readonly) NSDate *beginDate;
@property (nonatomic, strong, readonly) NSDate *endDate;

@property (nonatomic, strong) id dataObject;
@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, copy) void(^successCallBack)(NPTask *t);
@property (nonatomic, copy) void(^failedCallBack)(NPTask *t, NSError *error);

+ (id)taskWithIdentifier:(NSUInteger)identifier dataObject:(id)data;
- (id)initWithIdentifier:(NSUInteger)identifier dataObject:(id)data;

- (void)start;
- (void)commit;
- (void)fail:(NSError *)error;

@end
