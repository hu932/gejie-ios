#import "APIClient.h"

@interface APIClient ()
@property (nonatomic, assign) NSInteger _finishedCount;
@end

@implementation APIClient

+ (instancetype)shared {
    static APIClient *ins;
    static dispatch_once_t t;
    dispatch_once(&t, ^{ ins = [self new]; });
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _serverURL = kServerURL;
        __finishedCount = 0;
        [self loadSavedCredentials];
    }
    return self;
}

- (NSInteger)finishedCount { return __finishedCount; }

- (void)incrementCount {
    __finishedCount++;
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"GJCountUpdated" object:nil
        userInfo:@{@"count": @(__finishedCount)}];
}

// ─────────────────────────────────────────────
// Token 持久化
// ─────────────────────────────────────────────
- (void)saveToken:(NSString *)token username:(NSString *)username {
    self.token = token;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:token    forKey:kTokenKey];
    [ud setObject:username forKey:kUsernameKey];
    [ud synchronize];
}

- (BOOL)loadSavedCredentials {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *t = [ud objectForKey:kTokenKey];
    if (t.length > 0) {
        self.token = t;
        return YES;
    }
    return NO;
}

// ─────────────────────────────────────────────
// 通用 HTTP 请求
// ─────────────────────────────────────────────
- (NSURLSession *)session {
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    cfg.timeoutIntervalForRequest = 30;
    return [NSURLSession sessionWithConfiguration:cfg];
}

- (NSDictionary *)authHeaders {
    if (self.token.length > 0) {
        return @{
            @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.token],
            @"Content-Type":  @"application/json",
        };
    }
    return @{@"Content-Type": @"application/json"};
}

// ─────────────────────────────────────────────
// 1. 登录
// ─────────────────────────────────────────────
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(GJLoginBlock)completion {
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/user/login",
                        [self.serverURL stringByTrimmingCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{@"username": username, @"password": password};
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];

    [[[self session] dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) { dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, e.localizedDescription); }); return; }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        NSString *token = json[@"data"][@"token"];
        if (token.length > 0) {
            [self saveToken:token username:username];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(token, nil); });
        } else {
            NSString *msg = json[@"msg"] ?: json[@"message"] ?: @"登录失败";
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, msg); });
        }
    }] resume];
}

// ─────────────────────────────────────────────
// 2. 获取任务
// ─────────────────────────────────────────────
- (void)getTaskWithCompletion:(GJTaskBlock)completion {
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/task/take",
                        [self.serverURL stringByTrimmingCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"GET";
    [[self authHeaders] enumerateKeysAndObjectsUsingBlock:^(id k, id v, BOOL *s) {
        [req setValue:v forHTTPHeaderField:k];
    }];

    [[[self session] dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) { dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, e.localizedDescription); }); return; }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        NSString *code = [NSString stringWithFormat:@"%@", json[@"code"]];
        NSDictionary *data = json[@"data"];
        if ([code isEqualToString:@"200"] && data[@"taskUrl"]) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(data, nil); });
        } else {
            NSString *msg = json[@"msg"] ?: json[@"message"] ?: @"暂无任务";
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, msg); });
        }
    }] resume];
}

// ─────────────────────────────────────────────
// 3. 提交任务
// ─────────────────────────────────────────────
- (void)submitTask:(NSDictionary *)taskData
         submitURL:(NSString *)submitURL
            result:(NSDictionary *)result
        completion:(GJSubmitBlock)completion {
    NSString *urlStr = [NSString stringWithFormat:@"%@/api/task/submit/v2",
                        [self.serverURL stringByTrimmingCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [[self authHeaders] enumerateKeysAndObjectsUsingBlock:^(id k, id v, BOOL *s) {
        [req setValue:v forHTTPHeaderField:k];
    }];

    // 构造 payload
    NSMutableDictionary *payload = [@{
        @"appVersion": @"vv2",
        @"url": submitURL ?: @"",
        @"result": [self jsonStringFromObject:result],
    } mutableCopy];

    // 提取任务 ID
    NSArray *idKeys = @[@"deal_id", @"dealId", @"task_id", @"taskId", @"id"];
    for (NSString *key in idKeys) {
        if (taskData[key]) { payload[key] = taskData[key]; break; }
    }

    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [[[self session] dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) { dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, e.localizedDescription); }); return; }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        NSString *code = [NSString stringWithFormat:@"%@", json[@"code"]];
        if ([code isEqualToString:@"200"]) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(YES, nil); });
        } else {
            NSString *msg = json[@"msg"] ?: json[@"message"] ?: @"提交失败";
            dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, msg); });
        }
    }] resume];
}

// ─────────────────────────────────────────────
// 4. 获取 Shopee 商品详情
// ─────────────────────────────────────────────
- (void)fetchShopeeProductFromURL:(NSString *)urlStr
                       completion:(GJProductBlock)completion {
    // 解析 Shopee 商品 URL，提取 shopId / itemId
    // URL 格式: https://shopee.tw/xxx-i.shopId.itemId
    //        或: https://shopee.tw/product/shopId/itemId
    NSString *shopId = nil, *itemId = nil;

    NSRegularExpression *re1 = [NSRegularExpression
        regularExpressionWithPattern:@"i\\.(\\d+)\\.(\\d+)" options:0 error:nil];
    NSTextCheckingResult *m1 = [re1 firstMatchInString:urlStr
        options:0 range:NSMakeRange(0, urlStr.length)];
    if (m1 && m1.numberOfRanges >= 3) {
        shopId = [urlStr substringWithRange:[m1 rangeAtIndex:1]];
        itemId = [urlStr substringWithRange:[m1 rangeAtIndex:2]];
    }

    if (!shopId || !itemId) {
        NSRegularExpression *re2 = [NSRegularExpression
            regularExpressionWithPattern:@"/product/(\\d+)/(\\d+)" options:0 error:nil];
        NSTextCheckingResult *m2 = [re2 firstMatchInString:urlStr
            options:0 range:NSMakeRange(0, urlStr.length)];
        if (m2 && m2.numberOfRanges >= 3) {
            shopId = [urlStr substringWithRange:[m2 rangeAtIndex:1]];
            itemId = [urlStr substringWithRange:[m2 rangeAtIndex:2]];
        }
    }

    if (!shopId || !itemId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, @"无法解析商品 URL");
        });
        return;
    }

    // 调用 Shopee API
    NSString *apiURL = [NSString stringWithFormat:
        @"https://shopee.tw/api/v4/item/get?itemid=%@&shopid=%@", itemId, shopId];
    NSURL *url = [NSURL URLWithString:apiURL];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15"
       forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"https://shopee.tw" forHTTPHeaderField:@"Referer"];

    [[[self session] dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) { dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, e.localizedDescription); }); return; }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        NSDictionary *item = json[@"data"][@"item"];
        if (item) {
            NSDictionary *product = @{
                @"itemId":   itemId,
                @"shopId":   shopId,
                @"name":     item[@"name"] ?: @"",
                @"price":    item[@"price"] ?: @0,
                @"currency": item[@"currency"] ?: @"TWD",
                @"stock":    item[@"stock"] ?: @0,
                @"rating":   item[@"item_rating"][@"rating_star"] ?: @0,
                @"shopName": item[@"shop_name"] ?: @"",
                @"images":   item[@"images"] ?: @[],
                @"url":      urlStr,
            };
            dispatch_async(dispatch_get_main_queue(), ^{ completion(product, nil); });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, @"获取商品信息失败"); });
        }
    }] resume];
}

// ─────────────────────────────────────────────
// 辅助
// ─────────────────────────────────────────────
- (NSString *)jsonStringFromObject:(id)obj {
    if (!obj) return @"{}";
    NSData *d = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return d ? [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] : @"{}";
}

@end
