import {Dimensions, Platform} from 'react-native';

const screemHeights = [812, 896, 926, 844, 780];
const window = Dimensions.get('window');
const isIphoneX =
  Platform.OS === 'ios' &&
  !Platform.isPad &&
  !Platform.isTVOS &&
  (screemHeights.indexOf(window.height) !== -1 ||
    screemHeights.indexOf(window.width) !== -1);
const statusBarHeight = isIphoneX ? 44 : 20;
const safeAreaBottomHeight = isIphoneX ? 34 : 0;

export default {
  isIphoneX,
  statusBarHeight,
  safeAreaBottomHeight,

  ifIphoneX(iphoneXStyle, regularStyle) {
    if (isIphoneX) {
      return iphoneXStyle;
    } else {
      return regularStyle;
    }
  },
};
