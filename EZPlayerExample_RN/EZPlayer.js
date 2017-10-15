// Sprite component bridged with native component (react-native 0.34)
// By William Ngan, 10/2016

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  NativeModules,
  findNodeHandle,
  ViewPropTypes,  
  View
} from 'react-native';

// refers to Sprite.swift we have in XCode
const EZRNPlayerViewNative = requireNativeComponent('EZRNPlayerView', EZPlayer);

// refers to SpriteManager.swift
const EZRNPlayerViewManager = NativeModules.EZRNPlayerViewManager;

class EZPlayer extends Component {
  static propTypes = {
    ...ViewPropTypes,
    source: PropTypes.object,
    autoPlay: PropTypes.bool,
    videoGravity: PropTypes.string,//aspect,aspectFill,scaleFill
    videoGravity: PropTypes.string,//portrait,landscape
    
  };

  static defaultProps = {
    ...Component.defaultProps,
    source:null,
    autoPlay: true,
    videoGravity:'landscape'
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
      isLive:undefined,      
      rate:0,
      systemVolume:0,
      isM3U8:false,

      displayMode: undefined,//none,embedded,fullscreen,float   
      
      isLoading:true,
      
    };

  }

  componentWillUnmount(){
    console.log("[EZPlayer] 播放器销毁")
    // alert('播放器销毁') stop
    
}

  componentWillReceiveProps(newProps){
    // if (newProps.playData && this.props.playData && newProps.playData.tvid != this.props.playData.tvid){
    //     this.stop(); // 先销毁旧的播放器实例
    // }
    // alert(JSON.stringify(newProps))
        // alert(this.player.ref.autoPlay)

    // alert(this.player.source)
    // autoPlay={this.props.autoPlay}
    // source={this.props.source}
}

// shouldComponentUpdate(nextProps, nextState) {
//   return true
// }


  /**
   | -------------------------------------------------------
   | 播放器事件
   | -------------------------------------------------------
  */
  _onPlayerHeartbeat(event) {
    this.player.currentTime = event.nativeEvent.currentTime
    this.player.duration = event.nativeEvent.duration
    this.player.isLive = event.nativeEvent.isLive
    this.player.rate = event.nativeEvent.rate    
    this.player.systemVolume = event.nativeEvent.systemVolume
    this.player.isM3U8 = event.nativeEvent.isM3U8

    console.log("[EZPlayer] onPlayerHeartbeat " + JSON.stringify(event.nativeEvent));
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
    this.player.displayMode = event.nativeEvent.displayMode
    
    console.log("[EZPlayer] onPlayerDisplayModeDidChange " + JSON.stringify(event.nativeEvent));
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

  play(){
    EZRNPlayerViewManager.play(findNodeHandle(this))
  }

  pause(){
    EZRNPlayerViewManager.pause(findNodeHandle(this))
  }

  stop(){
    EZRNPlayerViewManager.stop(findNodeHandle(this))
  }

  seek(time,callback){
    EZRNPlayerViewManager.seek(findNodeHandle(this),time,(finished) => callback && callback(finished))    
  }

  replaceToPlay(source){
    EZRNPlayerViewManager.replaceToPlay(findNodeHandle(this),source)
  }

  rate(rate){
    EZRNPlayerViewManager.rate(findNodeHandle(this),rate)    
  }

  autoPlay(autoPlay){
    EZRNPlayerViewManager.autoPlay(findNodeHandle(this),autoPlay)    
  }

  videoGravity(videoGravity){
    EZRNPlayerViewManager.videoGravity(findNodeHandle(this),videoGravity)    
  }

  toEmbedded(animated = true,callback ){
    EZRNPlayerViewManager.toEmbedded(findNodeHandle(this),animated,(finished) => callback && callback(finished))    
  }

  toFloat(animated = true,callback ){
    EZRNPlayerViewManager.toFloat(findNodeHandle(this),animated,(finished) => callback && callback(finished))    
  }

  //orientation : landscapeLeft , landscapeRight
  toFull(orientation = 'landscapeLeft', animated = true,callback ){
    EZRNPlayerViewManager.toFull(findNodeHandle(this),orientation,animated,(finished) => callback && callback(finished))    
  }

  //fullScreenMode:portrait , landscape
  fullScreenMode(fullScreenMode){
    EZRNPlayerViewManager.fullScreenMode(findNodeHandle(this),fullScreenMode)    
  }
  
  // // Bridge to Sprite.swift's function
  // createSequence(nameWithPath, count, format, duration) {
  //   // Use findNodeHandle from react-native.
  //   SpriteManager.createSequence(findNodeHandle(this), nameWithPath, count || 1, format || "png", duration || 0.5);
  // }

  // // Bridge to Sprite.swift's function
  // animate( shouldPlay ) {
  //   SpriteManager.animate( findNodeHandle(this), shouldPlay || false );
  // }

  // componentWillReceiveProps(nextProps) {
  //   if (nextProps.imagePath != this.props.imagePath) {
  //     this.createSequence( nextProps.imagePath, nextProps.count, nextProps.format, nextProps.duration );
  //     this.animate( nextProps.animated );
  //   }
  // }

  // // On Mount, initiate the sequence from the props
  // componentDidMount() {
  //   this.createSequence( this.props.imagePath, this.props.count, this.props.format, this.props.duration );
  //   this.animate( this.props.animated );
  // }


  // _onLayout(evt) {
  //   // Handle layout changes if you need
  // }



  render() {

    // alert(this.props.autoPlay)
    return (<EZRNPlayerViewNative
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