//
//  Node.m
//  TestExamDemo
//
//  Created by dingyc on 20/6/18.
//  Copyright © 2018年 cmcc. All rights reserved.
//

#import "Node.h"

@interface Node ()
@property (nonatomic, strong) NSMutableArray *taskArray;//运行的任务

@end

@implementation Node

#pragma mark - lifeCycle
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _taskArray = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - public method
- (NSInteger)addTask:(Task *)task
{
    [_taskArray addObject:task];
    return [_taskArray count];
}

- (NSInteger)deleteTask:(Task *)task
{
    [_taskArray removeObject:task];
    return [_taskArray count];
}

- (NSInteger)cleanTask
{
    [_taskArray removeAllObjects];
    return 0;
}

- (NSArray *)getTaskArray
{
    return _taskArray;
}

- (int)totalConsumpiton
{
    int iTotal = 0;
    
    for (NSInteger i=0; i<_taskArray.count; i++)
    {
        Task *task = _taskArray[i];
        iTotal += task.consumption;
    }
    
    return iTotal;
}

@end
