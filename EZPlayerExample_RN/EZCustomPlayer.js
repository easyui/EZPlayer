import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {
    ViewPropTypes,
    View,
    Text,
    TouchableWithoutFeedback,
    TouchableHighlight,
    Animated,
    StyleSheet,
    Image,
    PanResponder,
    Easing
} from 'react-native';

import EZPlayer from './EZPlayer'

const bottomHeight = 36

let lastPlayPauseIcon = require('./images/play.png')
let lastCurrentTime = 0

export default class EZCustomPlayer extends Component {
    static propTypes = {
        ...ViewPropTypes,
    };

    static defaultProps = {
        ...Component.defaultProps,
        showControls: true,        
    };


    /**
    | -------------------------------------------------------
    | 播放器组件生命周期
    | -------------------------------------------------------
    */
    constructor(props) {
        super(props);

        this.state = {
            state: 'unknown',
            currentTime: undefined,
            duration: undefined,
            seekerFillWidth: 0,
            seekerPosition: 0,
            seekerOffset: 0,
            isLoading: true,
            isLive: undefined
        };
        /**
         * 播放器事件
         */
        this.events = {
            onPlayerHeartbeat: this._onPlayerHeartbeat.bind(this),
            onPlayerPlaybackTimeDidChange: this._onPlayerPlaybackTimeDidChange.bind(this),
            onPlayerStatusDidChange: this._onPlayerStatusDidChange.bind(this),
            onPlayerPlaybackDidFinish: this._onPlayerPlaybackDidFinish.bind(this),
            onPlayerLoadingDidChange: this._onPlayerLoadingDidChange.bind(this),
            onPlayerTapGestureRecognizer: this._onPlayerTapGestureRecognizer.bind(this),
        };

        /**
          * 播放器属性
          */
        this.player = {
            ref: EZPlayer,
            seekerWidth: 0,
            isSeekingBySliding: false,
            controlTimeoutDelay: this.props.controlTimeout || 5000,
            controlTimeout: null,
            showControls: this.props.showControls ,
            isloadingAnimation: false

        };

        /**
         * 播放器操作行为
         */
        this.action = {
            onScreenTouch: this._onScreenTouch.bind(this),
            togglePlayPause: this._togglePlayPause.bind(this),
            seekPanResponder: PanResponder,
        };

        /**
         * 播放器动画
         */
        this.animations = {
            bottomControl: {
                marginBottom: new Animated.Value(0),//修复透明度为零响应事件
                opacity: new Animated.Value(1),
            },
            loader: {
                rotate: new Animated.Value(0),
                MAX_VALUE: 360,
            }
        };

    }


    componentWillMount() {
        this.initSeekPanResponder();
    }

    componentDidMount() {
        if (this.player.showControls) {
            this.showControlAnimation();
            this.setControlTimeout();
        }
        else {
            this.hideControlAnimation();
            this.clearControlTimeout();
        }

    }

    componentWillUnmount() {
        console.log("[EZCustomPlayer] 播放器销毁")
        if (typeof this.props.dealloc === 'function') {
            this.props.dealloc(...arguments);
        }
    }

    /**
     | -------------------------------------------------------
     | 播放器事件
     | -------------------------------------------------------
    */
    _onPlayerHeartbeat(event) {
        let state = this.state;
        state.state = this.player.ref.player.state;
        state.currentTime = this.player.ref.player.currentTime;
        state.duration = this.player.ref.player.duration;
        state.isLive = this.player.ref.player.isLive

        if (!this.player.isSeekingBySliding) {
            const position = this.calculateSeekerPosition();
            this.setSeekerPosition(position);
        }
        this.setState(state);

        if (typeof this.props.onPlayerHeartbeat === 'function') {
            this.props.onPlayerHeartbeat(...arguments);
        }
    }

    _onPlayerPlaybackTimeDidChange(event) {
        if (typeof this.props.onPlayerPlaybackTimeDidChange === 'function') {
            this.props.onPlayerPlaybackTimeDidChange(...arguments);
        }
    }

    _onPlayerStatusDidChange(event) {
        if (typeof this.props.onPlayerStatusDidChange === 'function') {
            this.props.onPlayerStatusDidChange(...arguments);
        }
    }

    _onPlayerPlaybackDidFinish(event) {
        if (typeof this.props.onPlayerPlaybackDidFinish === 'function') {
            this.props.onPlayerPlaybackDidFinish(...arguments);
        }
    }

    _onPlayerLoadingDidChange(event) {
        let state = this.state;
        state.isLoading = this.player.ref.player.isLoading;
        this.setState(state);
        if (typeof this.props.onPlayerLoadingDidChange === 'function') {
            this.props.onPlayerLoadingDidChange(...arguments);
        }
    }

    _onPlayerTapGestureRecognizer(event) {
        // 其实这个可以替代 onScreenTouch
        if (typeof this.props.onPlayerTapGestureRecognizer === 'function') {
            this.props.onPlayerTapGestureRecognizer(...arguments);
        }
    }

    /**
    | -------------------------------------------------------
    | 播放器接口
    | -------------------------------------------------------
    */
    play() {
        this.player.ref.play()
    }

    pause() {
        this.player.ref.pause()
    }

    stop() {
        this.player.ref.stop()
    }

    seek(time, callback) {
        this.player.ref.seek(time, (finished) => callback && callback(finished))
    }

    replaceToPlay(source) {
        this.player.ref.replaceToPlay(source)
    }

    rate(rate) {
        this.player.ref.rate(rate)
    }

    autoPlay(autoPlay) {
        this.player.ref.autoPlay(autoPlay)
    }

    videoGravity(videoGravity) {
        this.player.ref.videoGravity(videoGravity)
    }

    toEmbedded(animated = true, callback) {
        this.player.ref.toEmbedded(animated, (finished) => callback && callback(finished))
    }

    toFloat(animated = true, callback) {
        this.player.ref.toFloat(animated, (finished) => callback && callback(finished))
    }

    //orientation : landscapeLeft , landscapeRight
    toFull(orientation = 'landscapeLeft', animated = true, callback) {
        this.player.ref.toFull(orientation, animated, (finished) => callback && callback(finished))
    }

    //fullScreenMode:portrait , landscape
    fullScreenMode(fullScreenMode) {
        this.player.ref.fullScreenMode(fullScreenMode)
    }

    /**
    | -------------------------------------------------------
    | 播放器操作行为
    | -------------------------------------------------------
    */

    _onScreenTouch() {
        this.player.showControls = !this.player.showControls;

        if (this.player.showControls) {
            this.showControlAnimation();
            this.setControlTimeout();
        } else {
            this.hideControlAnimation();
            this.clearControlTimeout();
        }
    }

    _togglePlayPause() {
        const playerState = this.state.state
        if (playerState === 'playing') {
            this.pause()
        } else {
            this.play()
        }
    }


    /**
    | -------------------------------------------------------
    | Private
    | -------------------------------------------------------
    */
    loadAnimation() {
        if (this.state.isLoading) {
            Animated.sequence([
                Animated.timing(
                    this.animations.loader.rotate,
                    {
                        toValue: this.animations.loader.MAX_VALUE,
                        duration: 1500,
                        easing: Easing.linear,
                    }
                ),
                Animated.timing(
                    this.animations.loader.rotate,
                    {
                        toValue: 0,
                        duration: 0,
                        easing: Easing.linear,
                    }
                ),
            ]).start(this.loadAnimation.bind(this));
        } else {
            this.player.isloadingAnimation = false
        }
    }

    resetControlTimeout() {
        this.clearControlTimeout();
        this.setControlTimeout();
    }

    clearControlTimeout() {
        clearTimeout(this.player.controlTimeout);
    }

    setControlTimeout() {
        this.player.controlTimeout = setTimeout(() => {
            this.player.showControls = false;
            this.hideControlAnimation();
        }, this.player.controlTimeoutDelay);
    }

    initSeekPanResponder() {
        this.action.seekPanResponder = PanResponder.create({

            onStartShouldSetPanResponder: (evt, gestureState) => this.state.state != 'unknown' && !this.state.isLive,
            onMoveShouldSetPanResponder: (evt, gestureState) => true,

            onPanResponderGrant: (evt, gestureState) => {
                // let state = this.state;
                this.clearControlTimeout();
                this.player.isSeekingBySliding = true
                // this.setState(state);
            },

            onPanResponderMove: (evt, gestureState) => {
                const position = this.state.seekerOffset + gestureState.dx;
                this.setSeekerPosition(position);
            },

            onPanResponderRelease: (evt, gestureState) => {
                this._seekRelease()
            },

            onPanResponderTerminate: (evt, gestureState) => {
                this._seekRelease()
            }
        });
    }

    _seekRelease() {
        const time = this.calculateTimeFromSeekerPosition();
        let state = this.state;

        this.setControlTimeout();
        this.player.isSeekingBySliding = false
        if (time >= state.duration && !state.loading) {
            this.stop()
        } else {
            this.seek(time);
        }
        this.setState(state);
    }
    //格式化时间
    formatTime(time = 0) {
        if (this.state.isLive) {
            return 'Live'
        }
        if (isNaN(time) || isNaN(this.state.duration)) {
            return ''
        }
        let pad = function (num, digit) {
            num = String(num);
            if (num.length > digit) {
                return num
            }
            var padArr = new Array(digit - num.length + 1)
            return padArr.join("0") + num
        }
        time = Math.min(
            Math.max(time, 0),
            this.state.duration
        );
        const formattedHours = pad(Math.floor(time / 3600).toFixed(0), 2);
        const formattedMinutes = pad(Math.floor(time % 3600 / 60).toFixed(0), 2);
        const formattedSeconds = pad(Math.floor(time % 60).toFixed(0), 2);

        return `${formattedHours === '00' ? '' : (formattedHours + ':')}${formattedMinutes}:${formattedSeconds}`;
    }


    hideControlAnimation() {
        Animated.sequence([
            Animated.timing(
                this.animations.bottomControl.opacity,
                {
                    toValue: 0,
                    duration: 300
                }
            ),
            Animated.timing(
                this.animations.bottomControl.marginBottom,
                {
                    toValue: -100,
                    duration: 0
                }
            ),
        ]).start();
    }


    showControlAnimation() {
        let state = this.state;

        const currentTime = state.currentTime
        if (isFinite(currentTime)) {
            state.currentTime = currentTime
        }
        // const duration = parseInt(this.state.duration)
        const duration = state.duration
        if (isFinite(duration)) {
            state.duration = duration
        }

        if (!this.player.isSeekingBySliding) {
            // if (!(playerState === 'seekingBackward' || playerState === 'seekingForward')) {
            const position = this.calculateSeekerPosition();
            this.setSeekerPosition(position);
        }
        this.setState(state);

        Animated.sequence([
            Animated.timing(
                this.animations.bottomControl.marginBottom,
                {
                    toValue: 0,
                    duration: 0
                }
            ),
            Animated.timing(
                this.animations.bottomControl.opacity,
                {
                    toValue: 1,
                    duration: 300,
                    delay: 0
                }
            ),
        ]).start();
    }


    //定位到播放进度位置
    setSeekerPosition(position = 0) {
        if (!isFinite(position)) {
            return
        }
        position = this.constrainToSeekerMinMax(position);
        let state = this.state;

        state.seekerFillWidth = position + 5;
        state.seekerPosition = position;

        if (!this.player.isSeekingBySliding) {
            // if (!(playerState === 'seekingBackward' || playerState === 'seekingForward')) {

            state.seekerOffset = position;
        }
        this.setState(state);
    }

    constrainToSeekerMinMax(val = 0) {
        if (val <= 0) {
            return 0;
        }
        else if (val >= this.player.seekerWidth) {
            return this.player.seekerWidth;
        }
        return val;
    }

    //计算播放了的进度条长度
    calculateSeekerPosition() {
        if (this.state.isLive) {
            return this.player.seekerWidth
        }
        const percent = this.state.currentTime / this.state.duration;
        return this.player.seekerWidth * percent;
    }

    //根据拖动的位置计算时间
    calculateTimeFromSeekerPosition() {
        const percent = this.state.seekerPosition / this.player.seekerWidth;
        return this.state.duration * percent;
    }

    /**
    | -------------------------------------------------------
    | 播放器UI
    | -------------------------------------------------------
    */
    renderBottomControls() {
        if (this.player.showControls) {
            return (
                <Animated.View style={[
                    styles.controls.bottom,
                    {
                        opacity: this.animations.bottomControl.opacity,
                        marginBottom: this.animations.bottomControl.marginBottom,
                    }
                ]}>
                    <Image
                        source={require('./images/bottom-vignette.png')}
                        style={styles.controls.bottomBG}>
                        {this.renderPlayPause()}
                        {this.renderTimer()}
                        {this.renderSeekbar()}
                        {this.renderDuration()}
                    </Image>
                </Animated.View>
            );
        } else {
            return null
        }
    }

    renderPlayPause() {
        const playerState = this.state.state
        let icon = lastPlayPauseIcon
        if (playerState === 'playing' || playerState === 'buffering') {
            icon = require('./images/pause.png')
        } else if (this.player.isSeekingBySliding == true || playerState === 'seekingBackward' || playerState === 'seekingForward') {

        } else {
            icon = require('./images/play.png')
        }
        lastPlayPause = lastPlayPauseIcon
        return this.renderControl(
            <Image source={icon} />,
            this.action.togglePlayPause,
            styles.controls.playPause
        );
    }


    renderTimer() {
        const playerState = this.state.state
        let time = 0
        if (this.player.isSeekingBySliding == true) {
            time = this.formatTime(this.calculateTimeFromSeekerPosition())
        } else {
            time = this.formatTime(this.state.currentTime)
        }
        lastCurrentTime = time
        return (<Text style={styles.controls.timerText}>{time}</Text>)
    }

    renderSeekbar() {
        return (
            <View style={styles.seekbar.container}>
                <View
                    style={styles.seekbar.track}
                    onLayout={event => {
                        this.player.seekerWidth = event.nativeEvent.layout.width - 12
                    }}>
                    <View style={[
                        styles.seekbar.fill,
                        {
                            width: this.state.seekerFillWidth,
                        }
                    ]} />
                </View>
                <View
                    style={[
                        styles.seekbar.handle,
                        { left: this.state.seekerPosition }
                    ]}
                    { ...this.action.seekPanResponder.panHandlers }
                >
                    <Image source={require('./images/seek_point.png')} style={[
                        styles.seekbar.circle,
                    ]}
                    />
                </View>
            </View>
        );
    }

    renderDuration() {
        return <Text style={[styles.controls.timerText, { textAlign: 'left' }]}>{this.formatTime(this.state.duration)}</Text>
    }


    renderControl(children, callback, style = {}) {
        return (
            <TouchableHighlight
                underlayColor="transparent"
                activeOpacity={0.3}
                onPress={() => {
                    this.resetControlTimeout();
                    callback();
                }}
                style={[
                    styles.controls.control,
                    style
                ]}
            >
                {children}
            </TouchableHighlight>
        );
    }


    renderLoader() {
        if (this.state.isLoading) {
            if (!this.player.isloadingAnimation) {
                this.player.isloadingAnimation = true
                this.loadAnimation()
            }

            return (
                <View style={styles.loader.container}>
                    <Animated.Image source={require('./images/loader-icon.png')} style={[
                        styles.loader.icon,
                        {
                            transform: [
                                {
                                    rotate: this.animations.loader.rotate.interpolate({
                                        inputRange: [0, 360],
                                        outputRange: ['0deg', '360deg']
                                    })
                                }
                            ]
                        }
                    ]} />
                </View>
            );
        }
        return null;
    }
    render() {
        return (
            <TouchableWithoutFeedback onPress={this.action.onScreenTouch}>
                <View>
                    <EZPlayer
                        {...this.props}
                        useDefaultUI={false}
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
                    {this.renderLoader()}
                    {this.renderBottomControls()}
                </View>
            </TouchableWithoutFeedback>

        )
    }

}


const styles = {
    player: StyleSheet.create({

    }),
    error: StyleSheet.create({

    }),
    loader: StyleSheet.create({

    }),
    controls: StyleSheet.create({
        control: {
            padding: 0,
        },
        bottom: {
            position: 'absolute',
            left: 0,
            bottom: 0,
            right: 0,
            height: bottomHeight,
            backgroundColor: 'transparent'
        },
        bottomBG: {
            flex: 1,
            backgroundColor: 'transparent',
            resizeMode: 'stretch',
            width: undefined,
            height: undefined,
            flexDirection: 'row',
            alignItems: 'center',

        },
        playPause: {
            height: bottomHeight,
            width: 40,
            backgroundColor: 'transparent',
            alignItems: 'center',
            justifyContent: 'center',
        },
        timerText: {
            backgroundColor: 'transparent',
            color: '#FFF',
            fontSize: 10,
            textAlign: 'right',
            width: 44
        },
    }),
    seekbar: StyleSheet.create({
        container: {
            justifyContent: 'center',
            marginLeft: 10,
            marginRight: 10,
            flex: 1,
            backgroundColor: 'transparent',
            height: 28,
        },
        track: {
            backgroundColor: 'rgba(255, 255, 255, 0.4)',
            height: 2,
        },
        fill: {
            backgroundColor: '#FFF',
            height: 2,
        },
        handle: {
            position: 'absolute',
            marginLeft: -8,
            height: 28,
            width: 28,
            top: -4,
            backgroundColor: 'transparent',
        },
        circle: {
            borderRadius: 12,
            top: 8,
            left: 8,
            height: 20,
            width: 20,
        },
    }),
    loader: StyleSheet.create({
        container: {
            position: 'absolute',
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            alignItems: 'center',
            justifyContent: 'center',
        },
        icon: {
            height: 30,
            width: 30,
        },
    }),
};
