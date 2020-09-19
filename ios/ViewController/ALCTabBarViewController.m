//
//  ALCTabBarViewController.m
//  CocoaAsyncSocket
//
//  Created by skylar on 2020/9/16.
//

#import "ALCTabBarViewController.h"
#import "ALCNavigationManager.h"
#import "UIViewController+ALC.h"
#import "UITabBar+DotBadge.h"

#import <React/RCTRootView.h>
#import <React/RCTRootViewDelegate.h>

@interface ALCTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UIViewController *previousController;

@property (nonatomic, strong) RCTRootView *rootView;

@property (nonatomic, assign) BOOL hasCustomTabBar;

@end

@implementation ALCTabBarViewController

- (instancetype)initWithTabBarOptions:(NSDictionary *)options {
    _hasCustomTabBar = YES;
    return [super init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    if (self.hasCustomTabBar) {
        [self customTabBar];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.hasCustomTabBar) {
        [self removeTabBarAboriginal];
        [self.tabBar bringSubviewToFront:self.rootView];
    }
}

- (void)customTabBar {
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[ALCNavigationManager shared].bridge moduleName:@"TabBar" initialProperties:nil];
    
    rootView.frame = CGRectMake(0, 1, CGRectGetWidth(self.tabBar.bounds), 48);
    [self.tabBar addSubview:rootView];
    self.rootView = rootView;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.childViewControllers.count == 0) {
        // TODO:
        [ALCNavigationManager sendEvent:@"NavigationEvent" data:
        @{
          @"event": @"did_select_button_tab",
        }];
        return NO;
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (self.previousController == viewController) {
        UINavigationController *nav = (UINavigationController *)viewController;
        [ALCNavigationManager sendEvent:@"NavigationEvent" data:
        @{
          @"event": @"did_select_tab",
          @"screen_id": nav.childViewControllers.firstObject.screenID
        }];
    }
    self.previousController = viewController;
}

- (void)removeTabBarAboriginal {
    NSUInteger count = self.tabBar.subviews.count;
    for (NSInteger i = count -1; i > -1; i --) {
        UIView *view = self.tabBar.subviews[i];
        NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([viewName isEqualToString:@"UITabBarButton"]) {
            [view removeFromSuperview];
        }
    }
}

- (void)setTabBadge:(NSArray<NSDictionary *> *)options {
    for (NSDictionary *option in options) {
        NSUInteger index = option[@"index"] ? [option[@"index"] integerValue] : 0;
        BOOL hidden = option[@"hidden"] ? [option[@"hidden"] boolValue] : YES;
        
        NSString *text = hidden ? nil : (option[@"text"] ? option[@"text"] : nil);
        BOOL dot = hidden ?  NO : (option[@"dot"] ? [option[@"dot"] boolValue] : NO);
        
        if (self.hasCustomTabBar) {
//            NSMutableDictionary *tab = [self tabAtIndex:index];
//            tab[@"dot"] = @(dot);
//            tab[@"badgeText"] = text ?: NSNull.null;
        } else {
            UIViewController *vc = self.viewControllers[index];
            vc.tabBarItem.badgeValue = text;
            UITabBar *tabBar = self.tabBar;
            if (dot) {
                [tabBar showDotBadgeAtIndex:index];
            } else {
                [tabBar hideDotBadgeAtIndex:index];
            }
        }
    }
}

@end