//
//  ALCNavigator.h
//  react-native-awesome-navigation
//
//  Created by skylar on 2020/9/22.
//

#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

@class ALCNavigationController;
@class ALCTabBarViewController;

typedef NS_ENUM(NSInteger, ALCLayoutType) {
    ALCLayoutTypeTabs,
    ALCLayoutTypeStack,
    ALCLayoutTypeScreen,
};

NS_ASSUME_NONNULL_BEGIN

@interface ALCNavigatorHelper : NSObject

@property (nonatomic, assign) ALCLayoutType layoutType;

- (ALCTabBarViewController *)createTabBarControllerWithLayout:(NSDictionary *)layout;
- (ALCNavigationController *)createNavigationControllerWithLayout:(NSDictionary *)layout;
- (UIViewController *)createScreenControllerWithLayout:(NSDictionary *)layout;

- (nullable ALCNavigationController *)getNavigationController;
- (nullable ALCTabBarViewController *)getTabBarController;

- (void)handleDispatch:(NSString *)screenID
                action:(NSString *)action
                  page:(NSString *)pageName
                params:(NSDictionary *)params
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject;

@end

NS_ASSUME_NONNULL_END
