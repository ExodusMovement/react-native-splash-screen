/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static UIView* splash = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
  if (splash != nil) return;
  UIViewController *sb = [[UIStoryboard storyboardWithName:@"Launch Screen" bundle:nil] instantiateInitialViewController];
  splash = sb.view;
  [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:splash];
}

+ (void)hide {
  if (splash != nil) {
    [splash removeFromSuperview];
    splash = nil;
  }
}

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

@end
