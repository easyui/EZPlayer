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
  FlatList,
  InteractionManager
} from 'react-native';
import EZCustomPlayer from './EZCustomPlayer'

import TablePlayerCell from './TablePlayerCell'
import Utils from './Utils'

const { height, width } = Dimensions.get('window');

export default class EZPlayerExample_RN extends Component {
  constructor(props) {
    super(props);

    this.state = {
      dataList: [],
      playerIndex: -1,
    }


    this.fetchData = this.fetchData.bind(this)
    this.renderCell = this.renderCell.bind(this)
    this.keyExtractor = this.keyExtractor.bind(this)
    this.renderHeader = this.renderHeader.bind(this)
    this.renderFooter = this.renderFooter.bind(this)
  }

  componentDidMount() {
    InteractionManager.runAfterInteractions(() => {
      this.fetchData()
    })

  }

  fetchData() {
    let dataList = [
      { id: 0, title: 'title0', url: 'http://techslides.com/demos/samples/sample.mp4' },
      { id: 1, title: 'title1', url: 'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8' },
      { id: 2, title: 'title2', url: 'http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4' },
      { id: 3, title: 'title3', url: 'http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8' },
      { id: 4, title: 'title4', url: 'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4' },
      { id: 5, title: 'title5', url: 'http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4' },
      { id: 6, title: 'title6', url: 'http://v.yoai.com/femme_tampon_tutorial.mp4' },
      { id: 7, title: 'title7', url: 'https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8' },
      { id: 8, title: 'title8', url: 'http://cdn3.viblast.com/streams/hls/airshow/playlist.m3u8' },
      { id: 9, title: 'title9', url: 'http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8' },
      { id: 10, title: 'title10', url: 'http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8' },
      { id: 11, title: 'title11', url: 'http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch3/appleman.m3u8' },
      { id: 12, title: 'title11', url: 'http://playertest.longtailvideo.com/adaptive/captions/playlist.m3u8' },
      { id: 13, title: 'title12', url: 'http://playertest.longtailvideo.com/adaptive/oceans_aes/oceans_aes.m3u8' },
      { id: 14, title: 'title13', url: 'http://techslides.com/demos/samples/sample.mp4' },
      { id: 15, title: 'title14', url: 'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8' },
      { id: 16, title: 'title15', url: 'http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4' },
      { id: 17, title: 'title16', url: 'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4' },
      { id: 18, title: 'title17', url: 'http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8' },
      { id: 19, title: 'title19', url: 'http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4' },
      { id: 20, title: 'title20', url: 'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4' },
      { id: 21, title: 'title21', url: 'http://techslides.com/demos/samples/sample.mp4' },
      { id: 22, title: 'title22', url: 'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8' },
      { id: 23, title: 'title23', url: 'http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4' },
      { id: 24, title: 'title24', url: 'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4' },
      { id: 25, title: 'title25', url: 'http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8' },
      { id: 26, title: 'title26', url: 'http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4' },
    ]
    this.setState({
      dataList,
    });
  }

  keyExtractor(item: Object, index: number) {
    return index
  }

  renderHeader() {
    return (<View style={styles.footerContainer} >
      <Text style={styles.footerText}>我是有头有脸的</Text>
    </View>);
  }

  renderFooter() {


    return (<View style={styles.footerContainer} >
      <Text style={styles.footerText}>我是有底线的</Text>
    </View>);
  }



  renderCell(info: Object) {
    body = null
    if (info.index === this.state.playerIndex) {
      body = <EZCustomPlayer
        ref={(e) => this._ezPlayer = e}
        style={styles.player}
        source={{ uri: info.item.url }}
        showControls={true}
        controlTimeout={8000}
        onPlayerPlaybackDidFinish={(event => {
          if (info.index === this.state.playerIndex) {
            this.setState({
              playerIndex: -1
            });
          }
        })}

      />
    } else {
      body = (<TouchableOpacity style={[styles.button]} onPress={() => {
        this.setState({ playerIndex: info.index })
      }
      }>
        <Text style={[styles.buttonText]}>  {info.item.title} </Text>
      </TouchableOpacity>)
    }
    return (
      <TablePlayerCell style={styles.cell} body={body} />
    );
  }

  separator = () => {
    return <View style={{ paddingLeft: 10 }}><View style={{ height: 2, backgroundColor: 'red' }}></View></View>;
  }

  render() {
    return (
      <View style={styles.container}>
        <FlatList
          data={this.state.dataList}
          keyExtractor={this.keyExtractor}
          ListHeaderComponent={this.renderHeader}
          ListFooterComponent={this.renderFooter}
          renderItem={this.renderCell}
          ItemSeparatorComponent={this.separator}
          contentContainerStyle={{ width: width }}
          removeClippedSubviews={true}
          getItemLayout={(data, index) => {
            let itemHeight = width / 16 * 9 + 2
            return { length: itemHeight, offset: itemHeight * index, index }
          }}
          onViewableItemsChanged={(info) => {
            // console.log(info)
            let changedArray = info.changed
            for (let changedInfo of changedArray.values()) {
              if (this.state.playerIndex == changedInfo.index && !changedInfo.isViewable) {
                this.setState({
                  playerIndex: -1
                });
              }
            }
          }}
        />
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
  footerContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 10,
    backgroundColor: 'white',

  },
  footerText: {
    fontSize: 14,
    color: '#555555'
  },
  cell: {
    height: width / 16 * 9,
    justifyContent: 'center',
    alignItems: 'center',

  },
  button: {
    backgroundColor: "#aaa",
    justifyContent: 'center',
    alignItems: 'center',
    width: 80,
    height: 80
  },
  buttonText: {
  },
  player: {
    width: width,
    height: width / 16 * 9
  },
});

AppRegistry.registerComponent('EZPlayerExample_RN', () => EZPlayerExample_RN);
