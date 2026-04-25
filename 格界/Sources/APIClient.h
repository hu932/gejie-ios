#pragma once
#import <Foundation/Foundation.h>

static NSString * const kServerURL   = @"https://eqwofaygdsjko.uk";
static NSString * const kTokenKey    = @"GJ_TOKEN";
static NSString * const kUsernameKey = @"GJ_USERNAME";

typedef void(^GJLoginBlock)(NSString * _Nullable token, NSString * _Nullable error);
typedef void(^GJTaskBlock)(NSDictionary * _Nullable taskData, NSString * _Nullable error);
typedef void(^GJSubmitBlock)(BOOL success, NSString * _Nullable error);
typedef void(^GJProductBlock)(NSDictionary * _Nullable product, NSString * _Nullable error);

@interface APIClient : NSObject

+ (instancetype)shared;

@property (nonatomic, copy, nullable)   NSString *token;
@property (nonatomic, copy, nullable)   NSString *serverURL;
@property (nonatomic, assign, readonly) NSInteger finishedCount;

/// 登录
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(GJLoginBlock)completion;

/// 获取任务
- (void)getTaskWithCompletion:(GJTaskBlock)completion;

/// 提交任务
- (void)submitTask:(NSDictionary *)taskData
         submitURL:(NSString *)submitURL
            result:(NSDictionary *)result
        completion:(GJSubmitBlock)completion;

/// 获取 Shopee 商品详情（解析 URL）
- (void)fetchShopeeProductFromURL:(NSString *)url
                       completion:(GJProductBlock)completion;

/// 本地计数 +1
- (void)incrementCount;

/// 读取 / 保存 token
- (void)saveToken:(NSString *)token username:(NSString *)username;
- (BOOL)loadSavedCredentials;

@end
