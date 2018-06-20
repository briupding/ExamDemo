//
//  Node.h
//  TestExamDemo
//
//  Created by dingyc on 20/6/18.
//  Copyright © 2018年 cmcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface Node : NSObject

@property (nonatomic, assign) int nodeId;//服务唯一标识符

/*
 * 分配一个任务
*/
- (NSInteger)addTask:(Task *)task;

/*
 * 删除一个任务
*/
- (NSInteger)deleteTask:(Task *)task;

/*
 * 清空任务
*/
- (NSInteger)cleanTask;

/*
 * 获取当前所有任务
*/
- (NSArray *)getTaskArray;

/*
 * 服务器总资源消耗
*/
- (int)totalConsumpiton;

@end
