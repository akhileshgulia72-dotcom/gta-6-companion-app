#import "NewsNativeAdFactory.h"

@implementation NewsNativeAdFactory

- (GADNativeAdView *)createNativeAd:(GADNativeAd *)nativeAd
                      customOptions:(NSDictionary *)customOptions {
  GADNativeAdView *adView = [[GADNativeAdView alloc]
      initWithFrame:CGRectMake(0, 0, 320, 300)];
  adView.translatesAutoresizingMaskIntoConstraints = NO;

  UILabel *headline = [[UILabel alloc] init];
  headline.font = [UIFont boldSystemFontOfSize:16];
  headline.numberOfLines = 2;
  headline.textColor = UIColor.labelColor;
  headline.text = nativeAd.headline;
  headline.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:headline];
  adView.headlineView = headline;

  GADMediaView *media = [[GADMediaView alloc] init];
  media.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:media];
  adView.mediaView = media;

  UILabel *body = [[UILabel alloc] init];
  body.font = [UIFont systemFontOfSize:13];
  body.numberOfLines = 2;
  body.textColor = UIColor.secondaryLabelColor;
  body.text = nativeAd.body;
  body.hidden = nativeAd.body == nil;
  body.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:body];
  adView.bodyView = body;

  UIImageView *icon = [[UIImageView alloc] init];
  icon.contentMode = UIViewContentModeScaleAspectFit;
  icon.image = nativeAd.icon.image;
  icon.hidden = nativeAd.icon == nil;
  icon.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:icon];
  adView.iconView = icon;

  UIButton *callToAction = [UIButton buttonWithType:UIButtonTypeSystem];
  [callToAction setTitle:nativeAd.callToAction forState:UIControlStateNormal];
  callToAction.titleLabel.font = [UIFont boldSystemFontOfSize:14];
  callToAction.backgroundColor = UIColor.systemBlueColor;
  [callToAction setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  callToAction.layer.cornerRadius = 6;
  callToAction.hidden = nativeAd.callToAction == nil;
  callToAction.userInteractionEnabled = NO;
  callToAction.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:callToAction];
  adView.callToActionView = callToAction;

  UILayoutGuide *layout = adView.safeAreaLayoutGuide;
  [NSLayoutConstraint activateConstraints:@[
    [headline.topAnchor constraintEqualToAnchor:layout.topAnchor constant:8],
    [headline.leadingAnchor constraintEqualToAnchor:layout.leadingAnchor constant:12],
    [headline.trailingAnchor constraintEqualToAnchor:layout.trailingAnchor constant:-12],
    [media.topAnchor constraintEqualToAnchor:headline.bottomAnchor constant:8],
    [media.leadingAnchor constraintEqualToAnchor:layout.leadingAnchor constant:12],
    [media.trailingAnchor constraintEqualToAnchor:layout.trailingAnchor constant:-12],
    [media.heightAnchor constraintEqualToConstant:140],
    [body.topAnchor constraintEqualToAnchor:media.bottomAnchor constant:8],
    [body.leadingAnchor constraintEqualToAnchor:layout.leadingAnchor constant:12],
    [body.trailingAnchor constraintEqualToAnchor:layout.trailingAnchor constant:-12],
    [icon.topAnchor constraintEqualToAnchor:body.bottomAnchor constant:8],
    [icon.leadingAnchor constraintEqualToAnchor:layout.leadingAnchor constant:12],
    [icon.widthAnchor constraintEqualToConstant:36],
    [icon.heightAnchor constraintEqualToConstant:36],
    [callToAction.centerYAnchor constraintEqualToAnchor:icon.centerYAnchor],
    [callToAction.trailingAnchor constraintEqualToAnchor:layout.trailingAnchor constant:-12],
    [callToAction.heightAnchor constraintGreaterThanOrEqualToConstant:36],
    [callToAction.widthAnchor constraintGreaterThanOrEqualToConstant:100],
    [icon.bottomAnchor constraintLessThanOrEqualToAnchor:layout.bottomAnchor constant:-8],
  ]];

  adView.nativeAd = nativeAd;
  return adView;
}

@end
