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

static UIView* _splash = nil;
static BOOL visible = false;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SplashScreen)

+ (void)setSplash: (UIView *)splash{
  _splash = splash;
}

+ (void)show {
  if (!visible){
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:_splash];
    visible = true;
  }
}

+ (void)hide {
  if (visible) {
    [_splash removeFromSuperview];
    visible = false;
  }
}

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

@end
