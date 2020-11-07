/*
 * Version for React Native
 * © 2020 YANDEX
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

#import <CoreLocation/CoreLocation.h>
#import <YandexMobileMetrica/YandexMobileMetrica.h>
#import <YandexMobileMetrica/YMMYandexMetricaReporting.h>
#import <YandexMobileMetrica/YMMECommerce.h>

@interface AppMetricaUtils : NSObject

+ (YMMYandexMetricaConfiguration *)configurationForDictionary:(NSDictionary *)configDict;
+ (CLLocation *)locationForDictionary:(NSDictionary *)locationDict;
+ (NSString *)stringFromRequestDeviceIDError:(NSError *)error;
+ (YMMECommerceScreen *)createECommerceScreen:(NSString *)searchQuery payload:(NSDictionary *)payload;
+ (YMMECommerceProduct *)createECommerceProduct:(NSString *)productId price:(NSString *)price payload:(NSDictionary *)payload;
@end
