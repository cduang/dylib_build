#import <UIKit/UIKit.h>

// ----------------------------------------------------
// 辅助函数：提取文本中的纯 URL
// ----------------------------------------------------
static NSString *cleanTaobaoString(NSString *originalString) {
    if (!originalString || ![originalString isKindOfClass:[NSString class]]) return originalString;
    
    // 只有包含淘宝相关特征的文案才处理
    if (!([originalString containsString:@"【淘宝】"] || 
          [originalString containsString:@"tb.cn"] || 
          [originalString containsString:@"taobao.com"])) {
        return originalString;
    }

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray<NSTextCheckingResult *> *matches = [detector matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.URL) {
            NSString *urlStr = match.URL.absoluteString;
            // 进一步去掉淘宝链接后的打点追踪参数 (如 ?tk=xxx)
            if ([urlStr containsString:@"?"]) {
                NSArray *parts = [urlStr componentsSeparatedByString:@"?"];
                return parts[0];
            }
            return urlStr;
        }
    }
    return originalString;
}

// ----------------------------------------------------
// 1. 深度拦截剪贴板 (涵盖淘宝常用的多种写入方式)
// ----------------------------------------------------
%hook UIPasteboard

// 拦截最基础的 setString
- (void)setString:(NSString *)string {
    %orig(cleanTaobaoString(string));
}

// 拦截现代 App 常用的 setValue:forPasteboardType:
- (void)setValue:(id)value forPasteboardType:(NSString *)pasteboardType {
    if ([value isKindOfClass:[NSString class]]) {
        value = cleanTaobaoString((NSString *)value);
    }
    %orig(value, pasteboardType);
}

// 拦截批量写入 setItems:
- (void)setItems:(NSArray<NSDictionary<NSString *,id> *> *)items {
    NSMutableArray *newItems = [items mutableCopy];
    for (NSUInteger i = 0; i < newItems.count; i++) {
        NSMutableDictionary *dict = [newItems[i] mutableCopy];
        // 遍历字典，处理所有可能的文本类型
        for (NSString *key in dict.allKeys) {
            if ([dict[key] isKindOfClass:[NSString class]]) {
                dict[key] = cleanTaobaoString(dict[key]);
            }
        }
        newItems[i] = dict;
    }
    %orig(newItems);
}

%end

// ----------------------------------------------------
// 2. 拦截系统分享面板
// ----------------------------------------------------
%hook UIActivityViewController

- (instancetype)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities {
    NSMutableArray *modifiedItems = [NSMutableArray arrayWithCapacity:activityItems.count];
    
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            [modifiedItems addObject:cleanTaobaoString((NSString *)item)];
        } else {
            [modifiedItems addObject:item];
        }
    }
    return %orig(modifiedItems, applicationActivities);
}

%end
