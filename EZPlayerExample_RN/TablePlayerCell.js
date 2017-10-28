import React, { Component } from 'react'
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    Dimensions,    
} from 'react-native'

const { height, width } = Dimensions.get('window');

export default class TablePlayerCell extends Component {
    constructor(props) {
        super(props);
    }

    componentDidMount() {
    }

    componentWillUnmount(){
        console.log("cell销毁")
    }

    render() {
        return (
          <View style={this.props.style}>
           {this.props.body}
          </View>
        );
      }

}

const styles = StyleSheet.create({

  
  });