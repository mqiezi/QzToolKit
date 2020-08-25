//
//  QzMacros.h
//  QzToolKit
//
//  Created by JzProl.m.Qiezi on 2020/8/3.
//  Copyright © 2020 com.mqiezi. All rights reserved.
//

#ifndef QzMacros_h
#define QzMacros_h


#pragma mark -

#define QzDeprecated(instead) __attribute__((deprecated(instead)))
#define QzUnavailable(instead) __attribute__((unavailable(instead)))

#pragma mark -

#ifndef NS_ENUM
    #define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#ifndef NS_OPTIONS
    #define NS_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#pragma mark - GCD

#if OS_OBJECT_USE_OBJC
    #undef QzDispatchQueueRelease
    #undef QzDispatchQueueSetterSementics
    #define QzDispatchQueueRelease(q)
    #define QzDispatchQueueSetterSementics strong
#else
    #undef QzDispatchQueueRelease
    #undef QzDispatchQueueSetterSementics
    #define QzDispatchQueueRelease(q) (dispatch_release(q))
    #define QzDispatchQueueSetterSementics assign
#endif

#define QzDispatchMainSyncSafe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_sync(dispatch_get_main_queue(), block);\
}

#define QzDispatchMainAsyncSafe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#define QzMainQueue dispatch_get_main_queue()
#define QzHighQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define QzDefaultQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define QzBackgroudQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

#define QzWeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define QzStrongObj(o) autoreleasepool{} __strong typeof(o) o##Strong = o##Weak;

#pragma mark -

#if OS_OBJECT_USE_OBJC
    #undef QzDispatchQueueRelease
    #undef QzDispatchQueueSetterSementics
    #define QzDispatchQueueRelease(q)
    #define QzDispatchQueueSetterSementics strong
#else
    #undef QzDispatchQueueRelease
    #undef QzDispatchQueueSetterSementics
    #define QzDispatchQueueRelease(q) (dispatch_release(q))
    #define QzDispatchQueueSetterSementics assign
#endif

#pragma mark -
#define QzIgnorePerformSelectorLeaksWarning(Stuff) \
{ \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
}

#define QzIgnoreUndeclaredSelectorWarning(Stuff) \
{ \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
}

#pragma mark -
#define QzIsSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#pragma mark -
#define kQzScreenH [UIScreen mainScreen].bounds.size.height
#define kQzScreenW [UIScreen mainScreen].bounds.size.width



#endif /* QzMacros_h */
