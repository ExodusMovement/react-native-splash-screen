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

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(SplashScreen)

NSInteger const RNSplashScreenOverlayTag = 39293;
NSString* RNSplashScreenOverlayName = @"splashscreenVideo";

+ (void)showVideo {
  if (showingVideo || showing) return;

  NSString *videoPath=[[NSBundle mainBundle] pathForResource:@"splashscreen" ofType:@"mp4"];
  if (videoPath == nil) return;
  showingVideo = true;

  UIView *rootView = UIApplication.sharedApplication.keyWindow.subviews.lastObject;

  NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
  AVPlayer *player = [AVPlayer playerWithURL:videoURL];
  playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

  AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
  playerLayer.frame = rootView.bounds;
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
}

+ (void) hideVideo:(AVPlayerItem*)playerItem {
  [self hideVideo];
}

+ (void)show {
  if (showingVideo || showing) return;

  NSString* launchImageName = [RNSplashScreen launchImageNameForOrientation:((UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation])];
  UIImage *image = [UIImage imageNamed:launchImageName];
  // currently, this depends on having all required launch screen images
  if (image == nil) return;

  showing = true;
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  // Give some decent tagvalue or keep a reference of imageView in self
  imageView.tag = RNSplashScreenOverlayTag;
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:imageView];
}

+ (void)hide {
  // let's try to hide, even if showing == false, ...just in case

  NSArray *subviews = UIApplication.sharedApplication.keyWindow.subviews;
  UIImageView *imageView = (UIImageView *)[subviews.lastObject viewWithTag:RNSplashScreenOverlayTag];

  #ifdef DEBUG
  if (imageView == nil && subviews.count > 1) {
    // Allows the SplashScreen to be removed even when the perf monitor is the last subview.
    imageView = (UIImageView *)[subviews[subviews.count - 2] viewWithTag:RNSplashScreenOverlayTag];
  }
  #endif

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

@end
