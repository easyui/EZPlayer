//
//  EZRNPlayerViewBridge.m
//  EZPlayerExample_RN
//
//  Created by IQIYI on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "EZRNPlayerViewBridge.h"

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(EZRNPlayerViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(autoPlay, BOOL)
RCT_EXPORT_VIEW_PROPERTY(videoGravity, NSString)
RCT_EXPORT_VIEW_PROPERTY(fullScreenMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(useDefaultUI, BOOL)


RCT_EXPORT_VIEW_PROPERTY(onPlayerHeartbeat, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerPlaybackTimeDidChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerStatusDidChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerPlaybackDidFinish, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerLoadingDidChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerControlsHiddenDidChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerDisplayModeDidChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerDisplayModeChangedWillAppear, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerDisplayModeChangedDidAppear, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerTapGestureRecognizer, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPlayerDidPersistContentKey, RCTBubblingEventBlock)

RCT_EXTERN_METHOD( play: (nonnull NSNumber *)reactTag )
RCT_EXTERN_METHOD( pause: (nonnull NSNumber *)reactTag )
RCT_EXTERN_METHOD( stop: (nonnull NSNumber *)reactTag )
RCT_EXTERN_METHOD( seek: (nonnull NSNumber *)reactTag time:(double *)time callback:( RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD( replaceToPlay: (nonnull NSNumber *)reactTag source:(NSDictionary*) source)

RCT_EXTERN_METHOD( rate: (nonnull NSNumber *)reactTag rate:(float *)rate )
RCT_EXTERN_METHOD( autoPlay: (nonnull NSNumber *)reactTag autoPlay:(BOOL *)autoPlay )

RCT_EXTERN_METHOD( videoGravity: (nonnull NSNumber *)reactTag videoGravity:(NSString *)videoGravity )

RCT_EXTERN_METHOD( toEmbedded: (nonnull NSNumber *)reactTag animated:(BOOL *)animated callback:( RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD( toFloat: (nonnull NSNumber *)reactTag animated:(BOOL *)animated callback:( RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD( toFull: (nonnull NSNumber *)reactTag orientation:(NSString*)orientation animated:(BOOL *)animated callback:( RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD( fullScreenMode: (nonnull NSNumber *)reactTag fullScreenMode:(NSString *)fullScreenMode )

//RCT_EXPORT_VIEW_PROPERTY(imageNumber, NSInteger)
//
//RCT_EXPORT_VIEW_PROPERTY(repeatCount, NSInteger)
//
//RCT_EXPORT_VIEW_PROPERTY(imageLayout, NSString)
//
//RCT_EXPORT_VIEW_PROPERTY(animated, BOOL)
//
//RCT_EXPORT_VIEW_PROPERTY(duration, double)
//
//RCT_EXTERN_METHOD( createSequence: (nonnull NSNumber *)reactTag nameWithPath:(NSString *)nameWithPath count:(NSInteger *)count format:(NSString *)format duration:(double *)duration )
//
//RCT_EXTERN_METHOD( animate: (nonnull NSNumber *)reactTag shouldPlay:(BOOL *)shouldPlay )
@end


