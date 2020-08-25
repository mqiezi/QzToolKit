//
//  QzQueue.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/4/24.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 定义一个线程安全的队列泛型类用于存储缓冲数据
 */
@interface QzQueue<__covariant ObjectType> : NSObject

@property (readonly) NSUInteger count;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)numItems NS_DESIGNATED_INITIALIZER;
+ (instancetype)queueWithCapacity:(NSUInteger)numItems;

/**
 * 返回队列首个元素
 */
- (nullable ObjectType)first;

/**
 * 用新的元素替换队列中的首个元素；
 */
- (void)replaceFirst:(nonnull ObjectType)object;

/**
 * 返回队列最后一个元素
 */
- (nullable ObjectType)last;

/**
 * 返回队列首个元素并删除
 */
- (nullable ObjectType)take;
/**
 * 在队列末尾添加元素
 */
- (void)put:(nonnull ObjectType)object;

/**
 * 清空队列
 */
- (void)clear;

@end


NS_ASSUME_NONNULL_END
