/*
 * Version for React Native
 * © 2020 YANDEX
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://yandex.com/legal/appmetrica_sdk_agreement/
 */

package com.yandex.metrica.plugin.reactnative;

import android.app.Activity;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.yandex.metrica.Revenue;
import com.yandex.metrica.YandexMetrica;
import com.yandex.metrica.ecommerce.ECommerceCartItem;
import com.yandex.metrica.ecommerce.ECommerceEvent;
import com.yandex.metrica.ecommerce.ECommerceOrder;
import com.yandex.metrica.ecommerce.ECommerceProduct;
import com.yandex.metrica.ecommerce.ECommerceReferrer;
import com.yandex.metrica.ecommerce.ECommerceScreen;

import java.util.Arrays;
import java.util.Currency;


public class AppMetricaModule extends ReactContextBaseJavaModule {

    private static final String TAG = "AppMetricaModule";

    private final ReactApplicationContext reactContext;

    public AppMetricaModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "AppMetrica";
    }

    @ReactMethod
    public void activate(ReadableMap configMap) {
        YandexMetrica.activate(reactContext, Utils.toYandexMetricaConfig(configMap));
        enableActivityAutoTracking();
    }

    private void enableActivityAutoTracking() {
        Activity activity = getCurrentActivity();
        if (activity != null) { // TODO: check
            YandexMetrica.enableActivityAutoTracking(activity.getApplication());
        } else {
            Log.w(TAG, "Activity is not attached");
        }
    }

    @ReactMethod
    public void getLibraryApiLevel(Promise promise) {
        promise.resolve(YandexMetrica.getLibraryApiLevel());
    }

    @ReactMethod
    public void getLibraryVersion(Promise promise) {
        promise.resolve(YandexMetrica.getLibraryVersion());
    }

    @ReactMethod
    public void pauseSession() {
        YandexMetrica.pauseSession(getCurrentActivity());
    }

    @ReactMethod
    public void reportAppOpen(String deeplink) {
        YandexMetrica.reportAppOpen(deeplink);
    }

    @ReactMethod
    public void reportError(String message) {
        try {
            Integer.valueOf("00xffWr0ng");
        } catch (Throwable error) {
            YandexMetrica.reportError(message, error);
        }
    }

    @ReactMethod
    public void reportEvent(String eventName, ReadableMap attributes) {
        if (attributes == null) {
            YandexMetrica.reportEvent(eventName);
        } else {
            YandexMetrica.reportEvent(eventName, attributes.toHashMap());
        }
    }

    @ReactMethod
    public void reportRevenue(String productId, String price, ReadableMap payload) {
        long priceLong = (long)Math.pow(Integer.parseInt(price), -6);
        Revenue revenue = Revenue.newBuilderWithMicros(priceLong, Currency.getInstance("RUB"))
        .withProductID(productId)
        .withQuantity(1)
        // Passing the OrderID parameter in the .withPayload(String payload) method to group purchases.
        .withPayload(String.valueOf(payload.toHashMap()))
        .build();
        // Sending the Revenue instance using reporter.
        YandexMetrica.reportRevenue(revenue);
    }

    @ReactMethod
    public void reportECommerceScreen(String searchQuery, ReadableMap payload) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, payload);
        ECommerceEvent showScreenEvent = ECommerceEvent.showScreenEvent(screen);
        // Sending an e-commerce event.
        YandexMetrica.reportECommerce(showScreenEvent);
    }

    @ReactMethod
    public void reportECommerceProductDetails(String searchQuery, ReadableMap screenPayload, String productName, String productId, String price, ReadableMap productPayload) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, screenPayload);
        ECommerceProduct product = Utils.createECommerceProduct(productName, productId, price, productPayload);
        ECommerceReferrer referrer =  new ECommerceReferrer().setScreen(screen);
        ECommerceEvent showProductDetailsEvent = ECommerceEvent.showProductDetailsEvent(product, referrer);
        YandexMetrica.reportECommerce(showProductDetailsEvent);
    }

    @ReactMethod
    public void reportECommerceAddCartItemEvent(String searchQuery, ReadableMap screenPayload, String productName, String productId, String price, ReadableMap productPayload) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, screenPayload);
        ECommerceProduct product = Utils.createECommerceProduct(productName, productId, price, productPayload);
        ECommerceReferrer referrer =  new ECommerceReferrer().setScreen(screen);
        ECommerceCartItem cartItem = new ECommerceCartItem(product, product.getOriginalPrice(), 1.0).setReferrer(referrer); // Optional.     
        ECommerceEvent addCartItemEvent = ECommerceEvent.addCartItemEvent(cartItem);
        YandexMetrica.reportECommerce(addCartItemEvent);
    }

    @ReactMethod
    public void reportECommerceRemoveCartItemEvent(String searchQuery, ReadableMap screenPayload, String productName, String productId, String price, ReadableMap productPayload) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, screenPayload);
        ECommerceProduct product = Utils.createECommerceProduct(productName, productId, price, productPayload);
        ECommerceReferrer referrer =  new ECommerceReferrer().setScreen(screen);
        ECommerceCartItem cartItem = new ECommerceCartItem(product, product.getOriginalPrice(), 1.0).setReferrer(referrer); // Optional.
        ECommerceEvent removeCartItemEvent = ECommerceEvent.removeCartItemEvent(cartItem);
        YandexMetrica.reportECommerce(removeCartItemEvent);
    }

    @ReactMethod
    public void reportECommerceCheckout(String searchQuery, ReadableMap screenPayload, String productName, String productId, String price, ReadableMap productPayload, String orderId) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, screenPayload);
        ECommerceProduct product = Utils.createECommerceProduct(productName, productId, price, productPayload);
        ECommerceReferrer referrer =  new ECommerceReferrer().setScreen(screen);
        ECommerceCartItem cartItem = new ECommerceCartItem(product, product.getOriginalPrice(), 1.0).setReferrer(referrer); // Optional.
        // Creating an order object.
        ECommerceOrder order = new ECommerceOrder(orderId, Arrays.asList(cartItem));
        ECommerceEvent beginCheckoutEvent = ECommerceEvent.beginCheckoutEvent(order);
        // Sending an e-commerce event.
        YandexMetrica.reportECommerce(beginCheckoutEvent);
    }

    @ReactMethod
    public void reportECommercePurchase(String searchQuery, ReadableMap screenPayload, String productName, String productId, String price, ReadableMap productPayload, String orderId) {
        ECommerceScreen screen = Utils.createECommerceScreen(searchQuery, screenPayload);
        ECommerceProduct product = Utils.createECommerceProduct(productName, productId, price, productPayload);
        ECommerceReferrer referrer =  new ECommerceReferrer().setScreen(screen);

        ECommerceCartItem cartItem = new ECommerceCartItem(product, product.getOriginalPrice(), 1.0).setReferrer(referrer); // Optional.
        // Creating an order object.
        ECommerceOrder order = new ECommerceOrder(orderId, Arrays.asList(cartItem));

        ECommerceEvent purchaseEvent = ECommerceEvent.purchaseEvent(order);
        // Sending an e-commerce event.
        YandexMetrica.reportECommerce(purchaseEvent);
    }

    @ReactMethod
    public void reportReferralUrl(String referralUrl) {
        YandexMetrica.reportReferralUrl(referralUrl);
    }

    @ReactMethod
    public void requestAppMetricaDeviceID(Callback listener) {
        YandexMetrica.requestAppMetricaDeviceID(new ReactNativeAppMetricaDeviceIDListener(listener));
    }

    @ReactMethod
    public void resumeSession() {
        YandexMetrica.resumeSession(getCurrentActivity());
    }

    @ReactMethod
    public void sendEventsBuffer() {
        YandexMetrica.sendEventsBuffer();
    }

    @ReactMethod
    public void setLocation(ReadableMap locationMap) {
        YandexMetrica.setLocation(Utils.toLocation(locationMap));
    }

    @ReactMethod
    public void setLocationTracking(boolean enabled) {
        YandexMetrica.setLocationTracking(enabled);
    }

    @ReactMethod
    public void setStatisticsSending(boolean enabled) {
        YandexMetrica.setStatisticsSending(reactContext, enabled);
    }

    @ReactMethod
    public void setUserProfileID(String userProfileID) {
        YandexMetrica.setUserProfileID(userProfileID);
    }
}
