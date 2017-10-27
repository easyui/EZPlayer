/**
 * Created by zhuyangjun on 2017/8/9
 * 
 * Utils
 * 
 * @flow
 * **/

import { Dimensions, Platform } from 'react-native';

const isIphoneX = Platform.OS === 'ios' && !Platform.isPad && !Platform.isTVOS && (Dimensions.get('window').height === 812 || Dimensions.get('window').width === 812);
const statusBarHeight = isIphoneX ? 44 :20;
const safeAreaBottomHeight = isIphoneX ? 34 :0;

export default {
    isIphoneX,
    statusBarHeight,
    safeAreaBottomHeight,
    
    ifIphoneX(iphoneXStyle, regularStyle) {
        if (isIphoneX) {
            return iphoneXStyle;
        } else {
            return regularStyle
        }
    },


}