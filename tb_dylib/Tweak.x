#import <UIKit/UIKit.h>

// ----------------------------------------------------
// 核心逻辑：从淘宝乱七八糟的文案中提取纯净链接
// ----------------------------------------------------
static NSString *extractPureTaobaoLink(NSString *input) {
    if (!input || ![input isKindOfClass:[NSString class]]) return input;
    
    // 快速预判：如果不含淘宝特征，直接原样返回，减少性能损耗
    if (!([input containsString:@"【淘宝】"] || [input containsString:@"tb.cn"] || [input containsString:@"taobao.com"])) {
        return input;
    }

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray<NSTextCheckingResult *> *matches = [detector matchesInString:input options:0 range:NSMakeRange(0, input.length)];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.URL) {
            NSString *urlStr = match.URL.absoluteString;
            // 净化：去掉 ?tk=... 等追踪参数
            if ([urlStr containsString:@"?"]) {
                urlStr = [[urlStr componentsSeparatedByString:@"?"] firstObject];
            }
            // 净化：去掉短链接最后的斜杠
            if ([urlStr hasSuffix:@"/"]) {
                urlStr = [urlStr substringToIndex:urlStr.length - 1];
            }
            return urlStr;
        }
    }
    return input;
}

// ----------------------------------------------------
// 拦截 UIPasteboard 的所有写入方式
// ----------------------------------------------------
%hook UIPasteboard

// 1. 基础写入
- (void)setString:(NSString *)string {
    %orig(extractPureTaobaoLink(string));
}

// 2. 批量写入 (淘宝经常用这个)
- (void)setItems:(NSArray<NSDictionary<NSString *,id> *> *)items {
    NSMutableArray *newItems = [NSMutableArray array];
    for (NSDictionary *dict in items) {
        NSMutableDictionary *newDict = [dict mutableCopy];
        for (NSString *key in dict.allKeys) {
            if ([dict[key] isKindOfClass:[NSString class]]) {
                newDict[key] = extractPureTaobaoLink(dict[key]);
            }
        }
        [newItems addObject:newDict];
    }
    %orig(newItems);
}

// 3. 带选项的批量写入
- (void)setItems:(NSArray<NSDictionary<NSString *,id> *> *)items options:(NSDictionary<UIPasteboardOption,id> *)options {
    NSMutableArray *newItems = [NSMutableArray array];
    for (NSDictionary *dict in items) {
        NSMutableDictionary *newDict = [dict mutableCopy];
        for (NSString *key in dict.allKeys) {
            if ([dict[key] isKindOfClass:[NSString class]]) {
                newDict[key] = extractPureTaobaoLink(dict[key]);
            }
        }
        [newItems addObject:newDict];
    }
    %orig(newItems, options);
}

// 4. 对象写入 (iOS 10+ 常用)
- (void)setObjects:(NSArray<id<NSItemProviderWriting>> *)objects {
    NSMutableArray *newObjects = [NSMutableArray array];
    for (id obj in objects) {
        if ([obj isKindOfClass:[NSString class]]) {
            [newObjects addObject:extractPureTaobaoLink((NSString *)obj)];
        } else {
            [newObjects addObject:obj];
        }
    }
    %orig(newObjects);
}

// 5. 带选项的对象写入
- (void)setObjects:(NSArray<id<NSItemProviderWriting>> *)objects options:(NSDictionary<UIPasteboardOption,id> *)options {
    NSMutableArray *newObjects = [NSMutableArray array];
    for (id obj in objects) {
        if ([obj isKindOfClass:[NSString class]]) {
            [newObjects addObject:extractPureTaobaoLink((NSString *)obj)];
        } else {
            [newObjects addObject:obj];
        }
    }
    %orig(newObjects, options);
}

// 6. 指定类型的写入
- (void)setValue:(id)value forPasteboardType:(NSString *)pasteboardType {
    if ([value isKindOfClass:[NSString class]]) {
        value = extractPureTaobaoLink((NSString *)value);
    }
    %orig(value, pasteboardType);
}

%end

// ----------------------------------------------------
// 额外拦截：分享面板 (双重保险)
// ----------------------------------------------------
%hook UIActivityViewController
- (instancetype)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities {
    NSMutableArray *newItems = [NSMutableArray array];
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            [newItems addObject:extractPureTaobaoLink((NSString *)item)];
        } else {
            [newItems addObject:item];
        }
    }
    return %orig(newItems, applicationActivities);
}
%end
