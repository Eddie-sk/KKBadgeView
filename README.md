感谢Ryan Jin提供的方案：https://www.jianshu.com/p/b6ca93f92eb3，
这里只供自己学习使用。添加部分功能:支持自定义小红点背景色，支持KeyPath绑定多个控件

使用方法：
1、添加observer：[self.badgeController observePath:DEMO_PARENT_PATH badgeView:self.rootLabel block:nil];
2、设置小红点：
  1.[KKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH];
  2.[KKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH count:1];
3、删除小红点：[KKBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH];
