//
//  QzQueue.m
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/4/24.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import "QzQueue.h"

@interface QzQueue<__covariant ObjectType> ()

@property (strong) NSMutableArray<ObjectType> *buffer;
@property (strong) NSLock *bufferLock;

@end

@implementation QzQueue

- (instancetype)init{
    if (self = [super init]) {
        _buffer = [[NSMutableArray alloc] initWithCapacity:0];
        _bufferLock = [[NSLock alloc] init];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems{
    if(self = [super init]){
        _buffer = [[NSMutableArray alloc] initWithCapacity:numItems];
        _bufferLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc{
    [self.bufferLock lock];
    [self.buffer removeAllObjects];
    self.buffer=nil;
    [self.bufferLock unlock];
    self.bufferLock=nil;
}

+ (instancetype)queueWithCapacity:(NSUInteger)numItems{
    return [[QzQueue alloc] initWithCapacity:numItems];
}

- (NSUInteger)count{
    [self.bufferLock lock];
    NSUInteger count = [self.buffer count];
    [self.bufferLock unlock];
    return count;
}

-(nullable id)first{
    [self.bufferLock lock];
    id object = [self.buffer firstObject];
    [self.bufferLock unlock];
    return object;
}

-(nullable id)last{
    [self.bufferLock lock];
    id object = [self.buffer lastObject];
    [self.bufferLock unlock];
    return object;
}

- (void)replaceFirst:(nonnull id)object{
    if(!object){
        return;
    }
    
    [self.bufferLock lock];
    [self.buffer replaceObjectAtIndex:0 withObject:object];
    [self.bufferLock unlock];
}


-(nullable id)take{
    [self.bufferLock lock];
    id object = [self.buffer firstObject];
    if([self.buffer count]>0){
         [self.buffer removeObjectAtIndex:0];
    }
    [self.bufferLock unlock];
    return object;
}

-(void)put:(nonnull id)object{
    if(!object){
        return;
    }
    [self.bufferLock lock];
    [self.buffer addObject:object];
    [self.bufferLock unlock];
}

-(void)clear{
    [self.bufferLock lock];
    [self.buffer removeAllObjects];
    [self.bufferLock unlock];
}

@end
