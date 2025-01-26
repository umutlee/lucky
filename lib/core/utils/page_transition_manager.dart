import 'package:flutter/material.dart';

/// 頁面切換效果類型
enum PageTransitionType {
  fade,         // 淡入淡出
  slide,        // 滑動
  scale,        // 縮放
  rotation,     // 旋轉
  slideAndFade, // 滑動並淡入淡出
}

/// 頁面切換方向
enum TransitionDirection {
  right,
  left,
  up,
  down,
}

/// 頁面切換管理器
class PageTransitionManager {
  /// 默認動畫時長
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  /// 默認曲線
  static const Curve defaultCurve = Curves.easeInOut;

  /// 創建頁面切換路由
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    PageTransitionType type = PageTransitionType.fade,
    TransitionDirection direction = TransitionDirection.right,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          type: type,
          direction: direction,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          curve: curve,
        );
      },
      transitionDuration: duration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// 構建過渡動畫
  static Widget _buildTransition({
    required PageTransitionType type,
    required TransitionDirection direction,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required Curve curve,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: child,
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: _getBeginOffset(direction),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: child,
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: child,
        );

      case PageTransitionType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: _getBeginOffset(direction),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
            child: child,
          ),
        );
    }
  }

  /// 獲取起始偏移量
  static Offset _getBeginOffset(TransitionDirection direction) {
    switch (direction) {
      case TransitionDirection.right:
        return const Offset(1.0, 0.0);
      case TransitionDirection.left:
        return const Offset(-1.0, 0.0);
      case TransitionDirection.up:
        return const Offset(0.0, -1.0);
      case TransitionDirection.down:
        return const Offset(0.0, 1.0);
    }
  }

  /// 創建頁面切換動畫控制器
  static AnimationController createController(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? defaultDuration,
    );
  }

  /// 創建頁面切換動畫
  static Animation<T> createAnimation<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = defaultCurve,
  }) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
} 