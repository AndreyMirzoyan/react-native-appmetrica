/*
 * Version for React Native
 * © 2020 YANDEX
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

#import "AppMetrica.h"
#import "AppMetricaUtils.h"


static NSString *const kYMMReactNativeExceptionName = @"ReactNativeException";

@implementation AppMetrica

@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(activate:(NSDictionary *)configDict)
{
    [YMMYandexMetrica activateWithConfiguration:[AppMetricaUtils configurationForDictionary:configDict]];
}

RCT_EXPORT_METHOD(getLibraryApiLevel)
{
    // It does nothing for iOS
}

RCT_EXPORT_METHOD(getLibraryVersion:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([YMMYandexMetrica libraryVersion]);
}

RCT_EXPORT_METHOD(pauseSession)
{
    [YMMYandexMetrica pauseSession];
}

RCT_EXPORT_METHOD(reportAppOpen:(NSString *)deeplink)
{
    [YMMYandexMetrica handleOpenURL:[NSURL URLWithString:deeplink]];
}

RCT_EXPORT_METHOD(reportError:(NSString *)message) {
    NSException *exception = [[NSException alloc] initWithName:message reason:nil userInfo:nil];
    [YMMYandexMetrica reportError:message exception:exception onFailure:nil];
}

RCT_EXPORT_METHOD(reportRevenue:(NSString *)productID: (NSString *)priceValue: (NSDictionary *)payload) {
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:priceValue];
    // Initializing the Revenue instance.
    YMMMutableRevenueInfo *revenueInfo = [[YMMMutableRevenueInfo alloc] initWithPriceDecimal:price currency:@"RUB"];
    revenueInfo.productID = productID;
    revenueInfo.quantity = 1;
    // Setting the OrderID parameter in the payload property to group purchases
    revenueInfo.payload = payload;
    [YMMYandexMetrica reportRevenue:[revenueInfo copy] onFailure:^(NSError *error) {
        NSLog(@"Revenue error: %@", error);
    }];
}

RCT_EXPORT_METHOD(reportECommerceScreen:(NSString *)searchQuery payload:(NSDictionary *)payload) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: payload];
    [YMMYandexMetrica reportECommerce:[YMMECommerce showScreenEventWithScreen:screen] onFailure:nil];
}

RCT_EXPORT_METHOD(reportECommerceProductDetails:(NSString *)searchQuery screenPayload:(NSDictionary *)screenPayload productId:(NSString *)productId price:(NSString *)price productPayload:(NSDictionary *)productPayload) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: screenPayload];
    YMMECommerceProduct *product = [AppMetricaUtils createECommerceProduct: productId price:price payload: productPayload];
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:nil identifier:nil screen:screen];
    [YMMYandexMetrica reportECommerce:[YMMECommerce showProductDetailsEventWithProduct:product referrer:referrer] onFailure:nil];
}

RCT_EXPORT_METHOD(reportECommerceAddCartItemEvent:(NSString *)searchQuery screenPayload:(NSDictionary *)screenPayload productId:(NSString *)productId price:(NSString *)price productPayload:(NSDictionary *)productPayload) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: screenPayload];
    YMMECommerceProduct *product = [AppMetricaUtils createECommerceProduct: productId price:price payload: productPayload];
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:nil identifier:nil screen:screen];
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    YMMECommerceCartItem *cartItem = [[YMMECommerceCartItem alloc] initWithProduct: product
                                                                          quantity: quantity
                                                                          revenue: product.originalPrice
                                                                          referrer: referrer];
    [YMMYandexMetrica reportECommerce:[YMMECommerce addCartItemEventWithItem:cartItem] onFailure:nil];
}

RCT_EXPORT_METHOD(reportECommerceRemoveCartItemEvent:(NSString *)searchQuery screenPayload:(NSDictionary *)screenPayload productId:(NSString *)productId price:(NSString *)price productPayload:(NSDictionary *)productPayload) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: screenPayload];
    YMMECommerceProduct *product = [AppMetricaUtils createECommerceProduct: productId price:price payload: productPayload];
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:nil identifier:nil screen:screen];
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    YMMECommerceCartItem *cartItem = [[YMMECommerceCartItem alloc] initWithProduct: product
                                                                          quantity: quantity
                                                                          revenue: product.originalPrice
                                                                          referrer: referrer];
    [YMMYandexMetrica reportECommerce:[YMMECommerce removeCartItemEventWithItem:cartItem] onFailure:nil];
}

RCT_EXPORT_METHOD(reportECommerceCheckout:(NSString *)searchQuery screenPayload:(NSDictionary *)screenPayload productId:(NSString *)productId price:(NSString *)price productPayload:(NSDictionary *)productPayload orderId:(NSString *)orderId) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: screenPayload];
    YMMECommerceProduct *product = [AppMetricaUtils createECommerceProduct: productId price:price payload: productPayload];
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:nil identifier:nil screen:screen];
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    YMMECommerceCartItem *cartItem = [[YMMECommerceCartItem alloc] initWithProduct: product
                                                                          quantity: quantity
                                                                          revenue: product.originalPrice
                                                                          referrer: referrer];
    // Creating an order object.
    YMMECommerceOrder *order = [[YMMECommerceOrder alloc] initWithIdentifier: orderId
                                                                   cartItems:@[ cartItem ]
                                                                     payload:nil];
    [YMMYandexMetrica reportECommerce:[YMMECommerce beginCheckoutEventWithOrder:order] onFailure:nil];
}

RCT_EXPORT_METHOD(reportECommercePurchase:(NSString *)searchQuery screenPayload:(NSDictionary *)screenPayload productId:(NSString *)productId price:(NSString *)price productPayload:(NSDictionary *)productPayload orderId:(NSString *)orderId) {
    YMMECommerceScreen *screen = [AppMetricaUtils createECommerceScreen:searchQuery payload: screenPayload];
    YMMECommerceProduct *product = [AppMetricaUtils createECommerceProduct: productId price:price payload: productPayload];
    YMMECommerceReferrer *referrer = [[YMMECommerceReferrer alloc] initWithType:nil identifier:nil screen:screen];
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:@"1"];
    YMMECommerceCartItem *cartItem = [[YMMECommerceCartItem alloc] initWithProduct: product
                                                                          quantity: quantity
                                                                          revenue: product.originalPrice
                                                                          referrer: referrer];
    // Creating an order object.
    YMMECommerceOrder *order = [[YMMECommerceOrder alloc] initWithIdentifier: orderId
                                                                   cartItems:@[ cartItem ]
                                                                     payload:nil];
    
    [YMMYandexMetrica reportECommerce:[YMMECommerce purchaseEventWithOrder:order] onFailure:nil];
}

RCT_EXPORT_METHOD(reportEvent:(NSString *)eventName:(NSDictionary *)attributes)
{
    if (attributes == nil) {
        [YMMYandexMetrica reportEvent:eventName onFailure:^(NSError *error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }];
    } else {
        [YMMYandexMetrica reportEvent:eventName parameters:attributes onFailure:^(NSError *error) {
            NSLog(@"error: %@", [error localizedDescription]);
        }];
    }
}

RCT_EXPORT_METHOD(reportReferralUrl:(NSString *)referralUrl)
{
    [YMMYandexMetrica reportReferralUrl:[NSURL URLWithString:referralUrl]];
}

RCT_EXPORT_METHOD(requestAppMetricaDeviceID:(RCTResponseSenderBlock)listener)
{
    YMMAppMetricaDeviceIDRetrievingBlock completionBlock = ^(NSString *_Nullable appMetricaDeviceID, NSError *_Nullable error) {
        listener(@[[self wrap:appMetricaDeviceID], [self wrap:[AppMetricaUtils stringFromRequestDeviceIDError:error]]]);
    };
    [YMMYandexMetrica requestAppMetricaDeviceIDWithCompletionQueue:nil completionBlock:completionBlock];
}

RCT_EXPORT_METHOD(resumeSession)
{
    [YMMYandexMetrica resumeSession];
}

RCT_EXPORT_METHOD(sendEventsBuffer)
{
    [YMMYandexMetrica sendEventsBuffer];
}

RCT_EXPORT_METHOD(setLocation:(NSDictionary *)locationDict)
{
    [YMMYandexMetrica setLocation:[AppMetricaUtils locationForDictionary:locationDict]];
}

RCT_EXPORT_METHOD(setLocationTracking:(BOOL)enabled)
{
    [YMMYandexMetrica setLocationTracking:enabled];
}

RCT_EXPORT_METHOD(setStatisticsSending:(BOOL)enabled)
{
    [YMMYandexMetrica setStatisticsSending:enabled];
}

RCT_EXPORT_METHOD(setUserProfileID:(NSString *)userProfileID)
{
    [YMMYandexMetrica setUserProfileID:userProfileID];
}

- (NSObject *)wrap:(NSObject *)value
{
    if (value == nil) {
        return [NSNull null];
    }
    return value;
}

@end
