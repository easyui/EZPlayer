/**
 * @format
 */

import {AppRegistry} from 'react-native';
import {name as appName} from './app.json';
// import App from './App';
// AppRegistry.registerComponent(appName, () => App);

// import BasePlayerExample from './BasePlayerExample'; //视频基础功能demo
// AppRegistry.registerComponent(appName, () => BasePlayerExample);

import TablePlayerExample from './TablePlayerExample'; //列表中视频demo
AppRegistry.registerComponent(appName, () => TablePlayerExample);
