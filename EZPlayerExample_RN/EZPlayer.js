import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  NativeModules,
  findNodeHandle,
  ViewPropTypes,
  View,
  Text
} from 'react-native';
// refers to EZRNPlayerView.swift we have in XCode
const EZRNPlayerViewNative = requireNativeComponent('EZRNPlayerView', EZPlayer);

// refers to EZRNPlayerViewManager.swift
const EZRNPlayerViewManager = NativeModules.EZRNPlayerViewManager;

class EZPlayer extends Component {
  static propTypes = {
    ...ViewPropTypes,
    source: PropTypes.object,
    autoPlay: PropTypes.bool,
    useDefaultUI: PropTypes.bool,
    videoGravity: PropTypes.string,//aspect,aspectFill,scaleFill
    fullScreenMode: PropTypes.string,//portrait,landscape

    onPlayerHeartbeat: PropTypes.func,
    onPlayerPlaybackTimeDidChange: PropTypes.func,
    onPlayerStatusDidChange: PropTypes.func,
    onPlayerPlaybackDidFinish: PropTypes.func,
    onPlayerLoadingDidChange: PropTypes.func,
    onPlayerControlsHiddenDidChange: PropTypes.func,
    onPlayerDisplayModeDidChange: PropTypes.func,
    onPlayerDisplayModeChangedWillAppear: PropTypes.func,
    onPlayerDisplayModeChangedDidAppear: PropTypes.func,
    onPlayerTapGestureRecognizer: PropTypes.func,
    onPlayerDidPersistContentKey: PropTypes.func,


  };

  static defaultProps = {
    ...Component.defaultProps,
    source: null,
    autoPlay: true,
    useDefaultUI: true,
    videoGravity: 'aspect',
    fullScreenMode: 'landscape'
  };


  /**
   | -------------------------------------------------------
   | EZPlayer 组件生命周期
   | -------------------------------------------------------
  */
  constructor(props) {
    super(props);

    /**
     * 播放器事件
     */
    this.events = {
      onPlayerHeartbeat: this._onPlayerHeartbeat.bind(this),
      onPlayerPlaybackTimeDidChange: this._onPlayerPlaybackTimeDidChange.bind(this),
      onPlayerStatusDidChange: this._onPlayerStatusDidChange.bind(this),
      onPlayerPlaybackDidFinish: this._onPlayerPlaybackDidFinish.bind(this),
      onPlayerLoadingDidChange: this._onPlayerLoadingDidChange.bind(this),
      onPlayerControlsHiddenDidChange: this._onPlayerControlsHiddenDidChange.bind(this),
      onPlayerDisplayModeDidChange: this._onPlayerDisplayModeDidChange.bind(this),
      onPlayerDisplayModeChangedWillAppear: this._onPlayerDisplayModeChangedWillAppear.bind(this),
      onPlayerDisplayModeChangedDidAppear: this._onPlayerDisplayModeChangedDidAppear.bind(this),
      onPlayerTapGestureRecognizer: this._onPlayerTapGestureRecognizer.bind(this),
      onPlayerDidPersistContentKey: this._onPlayerDidPersistContentKey.bind(this),
    };

    /**
      * 播放器
      */
    this.player = {
      ref: EZRNPlayerViewNative,

      state: 'unknown',//unknown,readyToPlay,buffering,bufferFinished,playing,seekingForward,seekingBackward,pause,stopped,error.invalidContentURL,error.playerFail

      currentTime: undefined,
      duration: undefined,
      isLive: undefined,
      rate: 0,
      systemVolume: 0,
      isM3U8: false,
      displayMode: undefined,//none,embedded,fullscreen,float   
      isLoading: true,

      firstReady: false
    };

  }

  componentWillUnmount() {
    console.log("[EZPlayer] componentWillUnmount")
    this.player.firstReady = false
    this.stop()
  }


  /**
   | -------------------------------------------------------
   | 播放器事件
   | -------------------------------------------------------
  */
  _onPlayerHeartbeat(event) {
    console.log("[EZPlayer] onPlayerHeartbeat " + JSON.stringify(event.nativeEvent));
    if (this.player.firstReady) {
      this.player.currentTime = event.nativeEvent.currentTime
      this.player.duration = event.nativeEvent.duration
      this.player.isLive = event.nativeEvent.isLive
      this.player.rate = event.nativeEvent.rate
      this.player.systemVolume = event.nativeEvent.systemVolume
      this.player.isM3U8 = event.nativeEvent.isM3U8
      this.player.state = event.nativeEvent.state
    }

    if (typeof this.props.onPlayerHeartbeat === 'function') {
      this.props.onPlayerHeartbeat(...arguments);
    }
  }

  _onPlayerPlaybackTimeDidChange(event) {
    console.log("[EZPlayer] onPlayerPlaybackTimeDidChange " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerPlaybackTimeDidChange === 'function') {
      this.props.onPlayerPlaybackTimeDidChange(...arguments);
    }
  }

  _onPlayerStatusDidChange(event) {
    console.log("[EZPlayer] onPlayerStatusDidChange " + JSON.stringify(event.nativeEvent));
    if ((event.nativeEvent.oldState === 'unknown') && (event.nativeEvent.newState === 'readyToPlay')) {
      this.player.firstReady = true
    }
    this.player.state = event.nativeEvent.newState
    if (typeof this.props.onPlayerStatusDidChange === 'function') {
      this.props.onPlayerStatusDidChange(...arguments);
    }
  }

  _onPlayerPlaybackDidFinish(event) {
    console.log("[EZPlayer] onPlayerPlaybackDidFinish " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerPlaybackDidFinish === 'function') {
      this.props.onPlayerPlaybackDidFinish(...arguments);
    }
  }

  _onPlayerLoadingDidChange(event) {
    console.log("[EZPlayer] onPlayerLoadingDidChange " + JSON.stringify(event.nativeEvent));
    this.player.isLoading = event.nativeEvent.EZPlayerLoadingDidChangeKey
    if (typeof this.props.onPlayerLoadingDidChange === 'function') {
      this.props.onPlayerLoadingDidChange(...arguments);
    }
  }

  _onPlayerControlsHiddenDidChange(event) {
    console.log("[EZPlayer] onPlayerControlsHiddenDidChange " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerControlsHiddenDidChange === 'function') {
      this.props.onPlayerControlsHiddenDidChange(...arguments);
    }
  }

  _onPlayerDisplayModeDidChange(event) {
    console.log("[EZPlayer] onPlayerDisplayModeDidChange " + JSON.stringify(event.nativeEvent));    
    this.player.displayMode = event.nativeEvent.displayMode
    if (typeof this.props.onPlayerDisplayModeDidChange === 'function') {
      this.props.onPlayerDisplayModeDidChange(...arguments);
    }
  }

  _onPlayerDisplayModeChangedWillAppear(event) {
    console.log("[EZPlayer] onPlayerDisplayModeChangedWillAppear " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerDisplayModeChangedWillAppear === 'function') {
      this.props.onPlayerDisplayModeChangedWillAppear(...arguments);
    }
  }

  _onPlayerDisplayModeChangedDidAppear(event) {
    console.log("[EZPlayer] onPlayerDisplayModeChangedDidAppear " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerDisplayModeChangedDidAppear === 'function') {
      this.props.onPlayerDisplayModeChangedDidAppear(...arguments);
    }
  }

  _onPlayerTapGestureRecognizer(event) {
    console.log("[EZPlayer] onPlayerTapGestureRecognizer " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerTapGestureRecognizer === 'function') {
      this.props.onPlayerTapGestureRecognizer(...arguments);
    }
  }

  _onPlayerDidPersistContentKey(event) {
    console.log("[EZPlayer] onPlayerDidPersistContentKey " + JSON.stringify(event.nativeEvent));
    if (typeof this.props.onPlayerDidPersistContentKey === 'function') {
      this.props.onPlayerDidPersistContentKey(...arguments);
    }
  }


  /**
   | -------------------------------------------------------
   | 播放器行为
   | -------------------------------------------------------
  */
  play() {
    EZRNPlayerViewManager.play(findNodeHandle(this._getEZRNPlayerViewNativeHandle()))
  }

  pause() {
    EZRNPlayerViewManager.pause(findNodeHandle(this._getEZRNPlayerViewNativeHandle()))
  }

  stop() {
    EZRNPlayerViewManager.stop(findNodeHandle(this._getEZRNPlayerViewNativeHandle()))
  }

  seek(time, callback) {
    if (isNaN(time)) {
      return
    }
    EZRNPlayerViewManager.seek(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), time, (finished) => callback && callback(finished))
  }

  replaceToPlay(source) {
    EZRNPlayerViewManager.replaceToPlay(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), source)
  }

  rate(rate) {
    EZRNPlayerViewManager.rate(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), rate)
  }

  autoPlay(autoPlay) {
    EZRNPlayerViewManager.autoPlay(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), autoPlay)
  }

  videoGravity(videoGravity) {
    EZRNPlayerViewManager.videoGravity(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), videoGravity)
  }

  toEmbedded(animated = true, callback) {
    EZRNPlayerViewManager.toEmbedded(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), animated, (finished) => callback && callback(finished))
  }

  toFloat(animated = true, callback) {
    EZRNPlayerViewManager.toFloat(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), animated, (finished) => callback && callback(finished))
  }

  //orientation : landscapeLeft , landscapeRight
  toFull(orientation = 'landscapeLeft', animated = true, callback) {
    EZRNPlayerViewManager.toFull(findNodeHandle(this._getEZRNPlayerViewNativeHandle()), orientation, animated, (finished) => callback && callback(finished))
  }

  //fullScreenMode:portrait , landscape
  fullScreenMode(fullScreenMode) {
    EZRNPlayerViewManager.fullScreenMode(this._getEZRNPlayerViewNativeHandle(), fullScreenMode)
  }


  /**
   | -------------------------------------------------------
   | Priavate
   | -------------------------------------------------------
  */
  _getEZRNPlayerViewNativeHandle() {
    return findNodeHandle(this.player.ref);
  }

  render() {
    return (
      <EZRNPlayerViewNative
        {...this.props}
        ref={(nativePlayer) => this.player.ref = nativePlayer}
        style={this.props.style}
        onPlayerHeartbeat={this.events.onPlayerHeartbeat}
        onPlayerPlaybackTimeDidChange={this.events.onPlayerPlaybackTimeDidChange}
        onPlayerStatusDidChange={this.events.onPlayerStatusDidChange}
        onPlayerPlaybackDidFinish={this.events.onPlayerPlaybackDidFinish}
        onPlayerLoadingDidChange={this.events.onPlayerLoadingDidChange}
        onPlayerControlsHiddenDidChange={this.events.onPlayerControlsHiddenDidChange}
        onPlayerDisplayModeDidChange={this.events.onPlayerDisplayModeDidChange}
        onPlayerDisplayModeChangedWillAppear={this.events.onPlayerDisplayModeChangedWillAppear}
        onPlayerDisplayModeChangedDidAppear={this.events.onPlayerDisplayModeChangedDidAppear}
        onPlayerTapGestureRecognizer={this.events.onPlayerTapGestureRecognizer}
        onPlayerDidPersistContentKey={this.events.onPlayerDidPersistContentKey}
      />
    )
  }
}

module.exports = EZPlayer;