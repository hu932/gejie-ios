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

+ (nonnull instancetype)shared;

@property (nonatomic, copy, nullable)   NSString *token;
@property (nonatomic, copy, nullable)   NSString *serverURL;
@property (nonatomic, assign, readonly) NSInteger finishedCount;

/// 登录
- (void)loginWithUsername:(nonnull NSString *)username
                 password:(nonnull NSString *)password
               completion:(nonnull GJLoginBlock)completion;

/// 获取任务
- (void)getTaskWithCompletion:(nonnull GJTaskBlock)completion;

/// 提交任务
- (void)submitTask:(nonnull NSDictionary *)taskData
         submitURL:(nonnull NSString *)submitURL
            result:(nonnull NSDictionary *)result
        completion:(nonnull GJSubmitBlock)completion;

/// 获取 Shopee 商品详情（解析 URL）
- (void)fetchShopeeProductFromURL:(nonnull NSString *)url
                       completion:(nonnull GJProductBlock)completion;

/// 本地计数 +1
- (void)incrementCount;

/// 读取 / 保存 token
- (void)saveToken:(nonnull NSString *)token username:(nonnull NSString *)username;
- (BOOL)loadSavedCredentials;

@end
