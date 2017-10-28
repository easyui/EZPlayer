/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Dimensions,
  TextInput,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import EZPlayer from './EZPlayer'
import Utils from './Utils'
const { height, width } = Dimensions.get('window');

export default class EZPlayerExample_RN extends Component {
  constructor(props) {
    super(props);

    this.state = {
      urlText: 'http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8',
      source: null,
    }

    _ezPlayer: EZPlayer
  }
  render() {
    return (
      <View style={styles.container}>
        <EZPlayer
          ref={(e) => this._ezPlayer = e}
          style={styles.player}
          source={this.state.source }

          autoPlay={true}
          videoGravity={'aspect'} 
          fullScreenMode={'landscape'}
        />
        <ScrollView
          style={styles.scrollView}
          contentContainerStyle={styles.contentContainer}>
          <View style={styles.cell}>
            <TextInput
              style={styles.urlInput}
              value={this.state.urlText}
              onChangeText={(urlText) => this.setState({urlText})}
            />
            <TouchableOpacity style={[styles.button]} onPress={() => {
              {/* this.setState({
                source: { uri: this.state.urlText },
              }); */}
              this._ezPlayer.replaceToPlay({ uri: this.state.urlText })
            }}>
              <Text style={[styles.buttonText]}>play</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>Remote:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { 
              this.setState({
                source: { uri: 'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8' },
              }); }}>
              <Text style={[styles.buttonText]}>  t1  </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { 
              this.setState({
                source: { uri: 'https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8' },
              });
               }}>
              <Text style={[styles.buttonText]}>   t2   </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { 
              this.setState({
                source: { uri: 'http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4' },
              });
               }}>
              <Text style={[styles.buttonText]}>  t3  </Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>action:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.play() }}>
              <Text style={[styles.buttonText]}>play</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { 
              this._ezPlayer.pause() }}>
              <Text style={[styles.buttonText]}>pause</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.stop() }}>
              <Text style={[styles.buttonText]}>stop</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.seek(10, (finished) => console.log('seek回调: ' + finished)) }}>
              <Text style={[styles.buttonText]}>seek</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>rate:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.rate(0.5) }}>
              <Text style={[styles.buttonText]}> 0.5 </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.rate(1) }}>
              <Text style={[styles.buttonText]}>   1   </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.rate(1.5) }}>
              <Text style={[styles.buttonText]}> 1.5 </Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>Gravity:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.videoGravity('aspect') }}>
              <Text style={[styles.buttonText]}>aspect</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.videoGravity('aspectFill') }}>
              <Text style={[styles.buttonText]}>aspectFill</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.videoGravity('scaleFill') }}>
              <Text style={[styles.buttonText]}>scaleFill</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>DisplayMode:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.toEmbedded() }}>
              <Text style={[styles.buttonText]}>  em  </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { 
              this._ezPlayer.fullScreenMode('portrait')
              this._ezPlayer.toFull() 
              }}>
              <Text style={[styles.buttonText]}>fullPor</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => {
              this._ezPlayer.fullScreenMode('landscape')
               this._ezPlayer.toFull() 
               }}>
              <Text style={[styles.buttonText]}>fullLand</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.toFloat() }}>
              <Text style={[styles.buttonText]}>float</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.cell}>
          <View style={[styles.cellTitle]}><Text style={[styles.buttonText]}>stop后生效:</Text></View>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.autoPlay(true) }}>
              <Text style={[styles.buttonText]}> auto </Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.button]} onPress={() => { this._ezPlayer.autoPlay(false) }}>
              <Text style={[styles.buttonText]}>   nonauto   </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>


      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'yellow',
    marginTop: Utils.statusBarHeight,
    marginBottom: Utils.safeAreaBottomHeight        
  },
  player: {
    width: width,
    height: width / 16 * 9
  },
  scrollView: {
    backgroundColor: 'white',
    flex: 1
  },
  contentContainer: {

  },
  cell: {
    flexDirection: 'row',
    height: 40,

  },
  urlInput: {
    borderColor: 'gray',
    borderWidth: 1,
    flex: 1,
  },
  cellTitle: {
    justifyContent: 'center',
    padding: 2,
    marginVertical: 1,
    marginHorizontal: 2,
  },
  button: {
    backgroundColor: "#aaa",
    justifyContent: 'center',
    padding: 5,
    marginVertical: 1,
    marginHorizontal: 5,
  },
  buttonText: {
    // textAlign:'center',
  }

});

AppRegistry.registerComponent('EZPlayerExample_RN', () => EZPlayerExample_RN);
