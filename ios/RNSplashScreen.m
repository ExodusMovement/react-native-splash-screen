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

static bool loop = false;
static bool showing = false;
static bool showingVideo = false;
static AVPlayer *lastPlayer = nil;
static id videoPauseObserver = nil;

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

  // Start the video from defined second
  NSNumber *startSecond = config[@"startSecond"];
  if (startSecond != nil) {
    CMTime newTime = CMTimeMakeWithSeconds([startSecond floatValue], 1);
    [player seekToTime:newTime];
  }

  loop = config[@"loopVideo"];

  NSNumber *allowAudio = config[@"allowAudio"];
  if (allowAudio != nil && [allowAudio boolValue]) {
    player.muted = false;
  }
  else {
    player.muted = true;
  }

  NSNumber *pauseAfterMs = config[@"pauseAfterMs"];
  if (pauseAfterMs != nil) {
      videoPauseObserver = [player addBoundaryTimeObserverForTimes: @[[NSValue valueWithCMTime:CMTimeMake([pauseAfterMs intValue], 1000)]]
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

  player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(manageVideoEnded:)
                                               name: AVPlayerItemDidPlayToEndTimeNotification
                                             object: [player currentItem]];
}

+ (void) manageVideoEnded:(AVPlayerItem*)playerItem {
  if (loop) {
    if (lastPlayer == nil) return;
    [lastPlayer seekToTime:kCMTimeZero];
  } else {
    [self hideVideo];
  }
}

+ (void) hideVideo {
  if (showing) return;
  UIView *rootView = UIApplication.sharedApplication.keyWindow.subviews.lastObject;
  [RNSplashScreen removeVideoPauseOption];

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
  if (showing) return;
  if (lastPlayer == nil) return;
  [RNSplashScreen removeVideoPauseOption];

  lastPlayer.rate = 1;
  [lastPlayer play];
}

+ (void)removeVideoPauseOption {
  if (showing) return;
  if (videoPauseObserver == nil || lastPlayer == nil) return;

  [lastPlayer removeTimeObserver:videoPauseObserver];
  videoPauseObserver = nil;
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
  if (showingVideo) return;
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

RCT_EXPORT_METHOD(resumeVideo) {
  [RNSplashScreen resumeVideo];
}

RCT_EXPORT_METHOD(removeVideoPauseOption) {
  [RNSplashScreen removeVideoPauseOption];
}

@end
