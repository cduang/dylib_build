#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 提取链接的逻辑
static NSString *extractPureLink(id input) {
    if (![input isKindOfClass:[NSString class]]) return input;
    NSString *str = (NSString *)input;
    if (!([str containsString:@"tb.cn"] || [str containsString:@"taobao.com"])) return str;

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSTextCheckingResult *match = [detector firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    
    if (match && match.URL) {
        NSString *url = match.URL.absoluteString;
        return [url componentsSeparatedByString:@"?"].firstObject;
    }
    return str;
}

// 执行 Hook 的工具函数
void swizzle(Class cls, SEL origSel, SEL newSel) {
    Method origMethod = class_getInstanceMethod(cls, origSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    method_exchangeImplementations(origMethod, newMethod);
}

// 定义一个分类来存放我们的新逻辑
@implementation UIPasteboard (TaobaoHook)

- (void)hook_setString:(NSString *)string {
    // 这里的 [self hook_setString:] 实际上是调用原生的 setString:
    [self hook_setString:extractPureLink(string)];
}

- (void)hook_setObjects:(NSArray *)objects {
    NSMutableArray *newObjects = [NSMutableArray array];
    for (id obj in objects) {
        [newObjects addObject:extractPureLink(obj)];
    }
    [self hook_setObjects:newObjects];
}

@end

// 插件加载点：不需要 %hook 关键字
__attribute__((constructor)) static void init() {
    @autoreleasepool {
        Class cls = [UIPasteboard class];
        // 交换 setString:
        swizzle(cls, @selector(setString:), @selector(hook_setString:));
        // 交换 setObjects: (淘宝 2026 年常用的方法)
        swizzle(cls, @selector(setObjects:), @selector(hook_setObjects:));
        
        NSLog(@"[TaobaoCleanShare] 纯原生 Hook 已加载，无需 Substrate");
    }
}
