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
        UIWindow *keyWindow;
        
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow && window.isHidden == NO) {
                        keyWindow = window;
                        break;
                    }
                }
                if (keyWindow) {
                    break;
                }
            }
        }
        
        [keyWindow.subviews.lastObject addSubview:_splash];
        visible = true;
    }
}

+ (void) removeFromSuperview{
    [_splash removeFromSuperview];
    visible = false;
}

+ (void)hide {
    [RNSplashScreen hide: @{}];
}


+ (void)hide: (NSDictionary *) opts {
    if (visible) {
        NSNumber * hideDuration = [opts valueForKey:@"hideDuration"];
        if(hideDuration && hideDuration.intValue > 0){
            [UIView animateWithDuration:hideDuration.intValue/1000 animations:^{
                _splash.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [RNSplashScreen removeFromSuperview];
                }
            }];
        }else{
            [RNSplashScreen removeFromSuperview];
        }
    }
}

RCT_EXPORT_METHOD(hide: (NSDictionary *) opts) {
    [RNSplashScreen hide: opts];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

@end
