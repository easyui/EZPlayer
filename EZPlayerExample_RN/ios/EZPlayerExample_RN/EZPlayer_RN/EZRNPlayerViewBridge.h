//
//  EZRNPlayerViewBridge.h
//  EZPlayerExample_RN
//
//  Created by Zhu yangjun on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <React/RCTView.h>
NS_ASSUME_NONNULL_BEGIN
@interface EZRNPlayerViewBridge : RCTView
@property (nonatomic, strong, nullable) NSDictionary *source;
@property (nonatomic, assign) BOOL *autoPlay;
@property (nonatomic, strong) NSString *videoGravity;
@property (nonatomic, strong) NSString *fullScreenMode;
@property (nonatomic, strong) NSString *floatMode;
@property (nonatomic, assign) BOOL *useDefaultUI;


@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerHeartbeat;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPlaybackTimeDidChange;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerStatusDidChange;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPlaybackDidFinish;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerLoadingDidChange;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerControlsHiddenDidChange;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerDisplayModeDidChange;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerDisplayModeChangedWillAppear;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerDisplayModeChangedDidAppear;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerTapGestureRecognizer;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerDidPersistContentKey;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPControllerWillStart;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPControllerDidStart;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPFailedToStart;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPControllerWillEnd;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPControllerDidEnd;
@property (nonatomic, strong, nullable) RCTDirectEventBlock onPlayerPIPRestoreUserInterfaceForStop;


@end
NS_ASSUME_NONNULL_END
