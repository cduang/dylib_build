#import <UIKit/UIKit.h>

// 辅助函数：从任意字符串中提取第一个有效的 URL
static NSString *extractURLFromText(NSString *text) {
    if (!text || text.length == 0) return text;
    
    NSError *error = nil;
    // 使用 NSDataDetector 识别文本中的链接
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray<NSTextCheckingResult *> *matches = [detector matchesInString:text 
                                                                 options:0 
                                                                   range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.URL) {
            // 返回匹配到的第一个纯 URL 字符串
            return match.URL.absoluteString;
        }
    }
    
    return text; // 如果没有匹配到，原样返回
}

// ----------------------------------------------------
// 1. 拦截剪贴板 (针对用户点击淘宝内“复制链接”的情况)
// ----------------------------------------------------
%hook UIPasteboard

- (void)setString:(NSString *)string {
    // 通过判断文本中是否包含淘宝文案的常见特征来过滤
    if (string && ([string containsString:@"【淘宝】"] || [string containsString:@"tb.cn"] || [string containsString:@"taobao.com"])) {
        NSString *pureUrl = extractURLFromText(string);
        if (pureUrl) {
            %orig(pureUrl); // 写入剪贴板时仅保留纯链接
            return;
        }
    }
    %orig(string);
}

%end

// ----------------------------------------------------
// 2. 拦截系统分享面板 (针对用户点击分享到微信/备忘录等情况)
// ----------------------------------------------------
%hook UIActivityViewController

- (instancetype)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities {
    NSMutableArray *modifiedItems = [NSMutableArray arrayWithCapacity:activityItems.count];
    
    for (id item in activityItems) {
        // 遍历分享的数据源，只处理字符串类型
        if ([item isKindOfClass:[NSString class]]) {
            NSString *strItem = (NSString *)item;
            if ([strItem containsString:@"【淘宝】"] || [strItem containsString:@"tb.cn"]) {
                NSString *pureUrl = extractURLFromText(strItem);
                [modifiedItems addObject:pureUrl ? pureUrl : strItem];
            } else {
                [modifiedItems addObject:item];
            }
        } else {
            // 图片、URL 对象等非字符串类型原样保留
            [modifiedItems addObject:item];
        }
    }
    
    // 调用原方法，但传入被我们净化过的内容
    return %orig(modifiedItems, applicationActivities);
}

%end
