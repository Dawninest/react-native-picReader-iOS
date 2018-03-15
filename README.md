# react-native-picReader-iOS
ReactNative NativeModule picReader (iOS only)


RN项目中实际使用遇到的情况，Android版的就自己打开系统自带的图片查看器打开图片了，
作为一个尊贵的 表面做ReactNative开发的iOS Developer，
让我用RN代码写一个图片查看页面是抗拒的，
所以自己写了一个 UIView 放RN界面之上，
缩放拖动手势，长按保存，基本就这点功能

使用：
将这里的四个文件放 RN工程文件目录/ios/ 之下
然后在RN需要用的的 js 文件中

import {NativeModules} from 'react-native';

NativeModules.PicReader.loadPicReader(picPath);
// 这里的picPath给绝对路径


