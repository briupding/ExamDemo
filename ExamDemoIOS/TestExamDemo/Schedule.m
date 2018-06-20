//
//  Schedule.m
//  ExamDemo
//
//  Created by George She on 2018/6/8.
//  Copyright © 2018年 CMRead. All rights reserved.
//

#import "Schedule.h"
#import "ReturnCodeKeys.h"
#import "Node.h"
#import "Task.h"
#import "TaskInfo.h"

@interface Schedule ()

@property (nonatomic, strong) NSMutableArray *nodeArray;//服务节点数组
@property (nonatomic, strong) NSMutableArray *taskArray;//挂起任务队列
@property (nonatomic, assign) int iMaxValue;//系统规模范围最大值

@end

@implementation Schedule
-(int)clean{
    
    _nodeArray = [NSMutableArray array];
    _taskArray = [NSMutableArray array];
    _iMaxValue = 50;

    return kE001;
}

-(int)registerNode:(int)nodeId{

    if (nodeId <= 0)
    {
        return kE004;
    }
    
    for (NSInteger i=0; i<_nodeArray.count; i++)
    {
        Node *node = _nodeArray[i];
        if (nodeId == node.nodeId)
        {
            return kE005;
        }
    }
    
    Node *newNode = [[Node alloc] init];
    newNode.nodeId = nodeId;
    [_nodeArray addObject:newNode];

    return kE003;
}

-(int)unregisterNode:(int)nodeId{

    if (nodeId <= 0)
    {
        return kE004;
    }
    
    for (NSInteger i=0; i<_nodeArray.count; i++)
    {
        Node *node = _nodeArray[i];
        if (nodeId == node.nodeId)
        {
            NSArray *taskArray = [node getTaskArray];
            [_nodeArray removeObjectAtIndex:i];
            [_taskArray addObjectsFromArray:taskArray];
            
            return kE006;
        }
    }

    return kE007;
}

-(int)addTask:(int)taskId withConsumption:(int)consumption{

    if (taskId <= 0)
    {
        return kE009;
    }
    
    for (NSInteger i=0; i<_taskArray.count; i++)
    {
        Task *task = _taskArray[i];
        if (taskId == task.taskId)
        {
            return kE010;
        }
    }
    
    Task *newTask = [[Task alloc] init];
    newTask.taskId = taskId;
    newTask.consumption = consumption;
    [_taskArray addObject:newTask];
    
    return kE008;
}

-(int)deleteTask:(int)taskId{

    if (taskId <= 0)
    {
        return kE009;
    }
    
    for (NSInteger i=0; i<_taskArray.count; i++)
    {
       Task *task = _taskArray[i];
       if (taskId == task.taskId)
       {
            [_taskArray removeObjectAtIndex:i];
            return kE011;
       }
    }
    
    for (NSInteger j=0; j<_nodeArray.count; j++)
    {
        Node *node = _nodeArray[j];
        NSArray *taskArray = [node getTaskArray];
        
        for (NSInteger k=0; k<taskArray.count; k++)
        {
            Task *task = taskArray[k];
            if (taskId == task.taskId)
            {
                [node deleteTask:task];
                return kE011;
            }
        }
    }
    
    return kE012;
}

/*
 * 这个还是搞不定
 * 1、首先计算出服务 * 任务数
 * 2、计算出最大的资源数和平均数(已经运行在服务器上的和挂起的两部分)
 * 3、只要在平均数范围内的小任务都往小服务器分配
*/
-(int)scheduleTask:(int)threshold{

    if (threshold <= 0)
    {
        return kE002;
    }
    
    int nodeNum = (int)[_nodeArray count];
    int taskNum = _iMaxValue/nodeNum;//最大允许的任务数
    int total = 0;
    int average = 0;
    
    //正在运行的任务和资源
    for (NSInteger i=0; i<nodeNum; i++)
    {
        Node *node = _nodeArray[i];
        total += [node totalConsumpiton];
        
        taskNum -= [[node getTaskArray] count];
    }
    
    if (taskNum > [_taskArray count])
    {
        taskNum = [_taskArray count];
    }
    
    //等待分配的资源
    for (NSInteger i=0; i<taskNum; i++)
    {
        Task *task = _taskArray[i];
        total += task.consumption;
    }
    average = total/nodeNum;
    
    //任务网服务分配
    NSInteger i=0;
    for (i=0; i<taskNum; i++)
    {
        Task *task = _taskArray[i];
        
        NSInteger j=0;
        for (j=0; j<nodeNum; j++)
        {
            Node *node = _nodeArray[j];
            int totalConsumption = [node totalConsumpiton];
            
            if (totalConsumption < average)
            {
                [node addTask:task];
                break;
            }
        }
        if (nodeNum == j)
        {
            //任务无法分配到服务，退出
            return kE014;
        }
    }

    if (taskNum < [_taskArray count])
    {
        _taskArray = [_taskArray subarrayWithRange:NSMakeRange(taskNum, _taskArray.count - taskNum)];
    }
    else
    {
        [_taskArray removeAllObjects];
    }
    
    for (NSInteger i=0; i<_nodeArray.count; i++)
    {
        Node *node = _nodeArray[i];
        int total1 = [node totalConsumpiton];
        
        for (NSInteger j=i+1; j<_nodeArray.count; j++)
        {
            Node *node2 = _nodeArray[j];
            int total2 = [node2 totalConsumpiton];
            
            if (abs(total2 - total1) >= threshold)
            {
                return kE014;
            }
        }
    }
    
    return kE013;
}

-(int)queryTaskStatus:(NSMutableArray<TaskInfo *> *)tasks{

    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<_nodeArray.count; i++)
    {
        Node *node = _nodeArray[i];
        NSArray *taskArray = [node getTaskArray];
        
        for (NSInteger j=0; j<taskArray.count; j++)
        {
            Task *task = taskArray[j];
            TaskInfo *taskInfo = [[TaskInfo alloc] init];
            taskInfo.taskId = task.taskId;
            taskInfo.nodeId = node.nodeId;
            
            [tempArray addObject:taskInfo];
        }
    }
    
    for (NSInteger j=0; j<_taskArray.count; j++)
    {
        Task *task = _taskArray[j];
        TaskInfo *taskInfo = [[TaskInfo alloc] init];
        taskInfo.taskId = task.taskId;
        taskInfo.nodeId = -1;
        
        [tempArray addObject:taskInfo];
    }
    
    if (0 == [tempArray count])
    {
        return kE016;
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"taskId" ascending:YES];
    NSArray *sortArray = [(NSArray *)tempArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    for (NSInteger i=0; i<sortArray.count; i++)
    {
        [tasks addObject:sortArray[i]];
    }
    
    return kE015;
}

@end
