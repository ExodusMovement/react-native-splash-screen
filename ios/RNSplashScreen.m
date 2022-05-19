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
#import <AVFoundation/AVFoundation.h>

static bool showing = false;
static bool showingVideo = false;
static AVPlayer *lastPlayer = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SplashScreen)

NSInteger const RNSplashScreenOverlayTag = 39293;
NSString* RNSplashScreenOverlayName = @"splashscreenVideo";

+ (void)showVideo {
  [RNSplashScreen showVideo:(NSDictionary *)@{}];
}

+ (void)showVideo:(NSDictionary *)config {
  if (showingVideo || showing) return;

  NSString *videoPath=[[NSBundle mainBundle] pathForResource:@"splashscreen" ofType:@"mp4"];
  if (videoPath == nil) return;
  showingVideo = true;

  UIView *rootView = UIApplication.sharedApplication.keyWindow.subviews.lastObject;

  NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
  AVPlayer *player = [AVPlayer playerWithURL:videoURL];
  lastPlayer = player;
  __weak AVPlayer *_player = player;

  NSNumber *pauseAfterMs = config[@"pauseAfterMs"];
  if (pauseAfterMs != nil) {
      [player addBoundaryTimeObserverForTimes: @[[NSValue valueWithCMTime:CMTimeMake([pauseAfterMs intValue], 1000)]]
                                                    queue:NULL // main queue
                                               usingBlock:^() {
          if (_player == nil) {
              return;
          }
          _player.rate = 0;
          [_player pause];
      }];
  }

  AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
  playerLayer.frame = rootView.bounds;
  playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [playerLayer setName:RNSplashScreenOverlayName];

  [rootView.layer addSublayer:playerLayer];
  [player play];

  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(hideVideo:)
                                               name: AVPlayerItemDidPlayToEndTimeNotification
                                             object: [player currentItem]];
}

+ (void) hideVideo {
  UIView *rootView = UIApplication.sharedApplication.keyWindow.subviews.lastObject;

  for (CALayer *layer in rootView.layer.sublayers) {
    if ([[layer name] isEqualToString:RNSplashScreenOverlayName]) {
      [layer removeFromSuperlayer];
      showingVideo = false;
      return;
    }
  }
  showingVideo = false;
  lastPlayer = nil;
}

+ (void) hideVideo:(AVPlayerItem*)playerItem {
  [self hideVideo];
}

+ (void)resumeVideo {

}

+ (void)removeVideoPauseOption {

}

+ (void)show {
  if (showingVideo || showing) return;

  UIViewController *launchScreen = [[UIStoryboard storyboardWithName: @"LaunchScreen" bundle: [NSBundle mainBundle]] instantiateInitialViewController];
  UIView *launchView = [launchScreen view];
  if (launchView != nil) {
    launchView.tag = RNSplashScreenOverlayTag;
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:launchView];
    showing = true;
  }
}

+ (void)hide {
  // let's try to hide, even if showing == false, ...just in case

  UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:RNSplashScreenOverlayTag];
  if (imageView != nil) {
    [imageView removeFromSuperview];
  }

  showing = false;
}

+ (NSString *)launchImageNameForOrientation:(UIDeviceOrientation)orientation {
  CGSize viewSize = [[UIScreen mainScreen] bounds].size;
  NSString* viewOrientation = @"Portrait";
  if (UIDeviceOrientationIsLandscape(orientation)) {
    viewSize = CGSizeMake(viewSize.height, viewSize.width);
    viewOrientation = @"Landscape";
  }

  NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
  NSString* fallback = nil;
  for (NSDictionary* dict in imagesDict) {
    CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
    NSString *imageName = dict[@"UILaunchImageName"];
    if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
      return imageName;

    // TODO: find best matching fallback image
    if (fallback == nil) fallback = imageName;
  }

  return fallback;
}

RCT_EXPORT_METHOD(hide) {
  [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
  [RNSplashScreen show];
}

RCT_EXPORT_METHOD(hideVideo) {
  [RNSplashScreen hideVideo];
}

RCT_EXPORT_METHOD(showVideo) {
  [RNSplashScreen showVideo];
}

RCT_EXPORT_METHOD(resumeVideo) {
  [RNSplashScreen resumeVideo];
}

RCT_EXPORT_METHOD(removeVideoPauseOption) {
  [RNSplashScreen removeVideoPauseOption];
}

@end
