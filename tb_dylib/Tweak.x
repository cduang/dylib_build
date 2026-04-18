#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 提取链接的逻辑保持不变
static NSString *extractPureLink(NSString *input) {
    if (![input isKindOfClass:[NSString class]] || input.length == 0) return input;
    if (!([input containsString:@"tb.cn"] || [input containsString:@"taobao.com"])) return input;

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSTextCheckingResult *match = [detector firstMatchInString:input options:0 range:NSMakeRange(0, input.length)];
    
    if (match && match.URL) {
        NSString *url = match.URL.absoluteString;
        return [url componentsSeparatedByString:@"?"].firstObject;
    }
    return input;
}

// 原生 Swizzling 函数，不依赖 CydiaSubstrate
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@interface UIPasteboard (Clean)
@end

@implementation UIPasteboard (Clean)
// 我们的新方法
- (void)my_setString:(NSString *)string {
    [self my_setString:extractPureLink(string)];
}
@end

// 插件加载入口
%ctor {
    @autoreleasepool {
        // 使用原生运行时交换方法
        swizzleMethod([UIPasteboard class], @selector(setString:), @selector(my_setString:));
        
        // 如果想拦截更多，可以照葫芦画瓢交换 setObjects: 等
        NSLog(@"[TaobaoCleanShare] 插件已加载，原生 Hook 已生效");
    }
}
