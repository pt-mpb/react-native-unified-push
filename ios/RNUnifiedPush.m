#import "RNUnifiedPush.h"
#import <React/RCTConvert.h>
#import <AeroGearPush/AeroGearPush.h>

@implementation RNUnifiedPush

NSData * curDeviceToken;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNS Success");
    curDeviceToken = deviceToken;
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AGPushAnalytics sendMetricsWhenAppLaunched:launchOptions];
    return YES;
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [AGPushAnalytics sendMetricsWhenAppAwoken:application.applicationState userInfo:userInfo];
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init:(NSDictionary *)details successCallback:(RCTResponseSenderBlock)successCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    AGDeviceRegistration *registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:[RCTConvert NSString:details[@"url"]]]];
    
    [registration registerWithClientInfo:^(id <AGClientDeviceInformation> clientInfo) {
        
        // apply the token, to identify this device
        [clientInfo setDeviceToken:curDeviceToken];
        
        [clientInfo setVariantID:[RCTConvert NSString:details[@"variantId"]]];
        [clientInfo setVariantSecret:[RCTConvert NSString:details[@"secret"]]];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        [clientInfo setOperatingSystem:[currentDevice systemName]];
        [clientInfo setOsVersion:[currentDevice systemVersion]];
        [clientInfo setDeviceType:[currentDevice model]];
        
    } success:^() {
        successCallback([NSArray arrayWithObjects: @"UPS registration worked", nil]);
        
    } failure:^(NSError *error) {
        errorCallback([NSArray arrayWithObjects:(@"UPS registration Error: %@", error), nil]);
    }];

}

@end
