import 'package:flutter/material.dart';

/// アプリケーションのカラーパレット
/// 
/// リスをイメージした温かみのある茶色・ベージュ・オレンジ系の色を使用
class AppColors {
  AppColors._(); // プライベートコンストラクタ

  // === プライマリカラー（茶色系） ===
  /// メインの茶色 - リスの体の色をイメージ
  static const Color primary = Color(0xFF8B6F47);
  static const Color primaryLight = Color(0xFFA68A64);
  static const Color primaryDark = Color(0xFF6B5437);

  // === セカンダリカラー（ベージュ系） ===
  /// ベージュ - 優しく温かみのある背景色
  static const Color secondary = Color(0xFFF5E6D3);
  static const Color secondaryLight = Color(0xFFFFF8F0);
  static const Color secondaryDark = Color(0xFFE8D4BD);

  // === アクセントカラー（オレンジ系） ===
  /// ライトオレンジ - 強調やアクション用
  static const Color accent = Color(0xFFE8A87C);
  static const Color accentLight = Color(0xFFFFBE95);
  static const Color accentDark = Color(0xFFD89563);

  // === エラー・警告カラー ===
  /// ピーチ/サーモンピンク - エラーや警告用
  static const Color error = Color(0xFFE89B9B);
  static const Color errorLight = Color(0xFFFFB3B3);
  static const Color errorDark = Color(0xFFD88383);

  // === 成功カラー ===
  /// グリーン系 - 成功メッセージ用
  static const Color success = Color(0xFF9BC995);
  static const Color successLight = Color(0xFFB3DEAD);
  static const Color successDark = Color(0xFF83B47D);

  // === ニュートラルカラー ===
  /// テキストカラー
  static const Color textPrimary = Color(0xFF2C2416);
  static const Color textSecondary = Color(0xFF6B5F4F);
  static const Color textTertiary = Color(0xFF9B8F7F);

  /// 背景カラー
  static const Color background = Color(0xFFFFFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0EA);

  // === カードカラーバリエーション ===
  /// アイテムカード用の背景色バリエーション
  static const List<Color> cardBackgrounds = [
    Color(0xFFFFF8F0), // ベージュ
    Color(0xFFFFEFE0), // ライトオレンジ
    Color(0xFFFFF0E6), // ピーチ
    Color(0xFFF5E6D3), // ベージュ2
    Color(0xFFFFE8D6), // アプリコット
  ];

  // === シャドウ ===
  /// カードやボタンのシャドウカラー
  static const Color shadow = Color(0x1A8B6F47);
  static const Color shadowLight = Color(0x0D8B6F47);
  static const Color shadowDark = Color(0x338B6F47);

  // === ボーダー ===
  /// ボーダーカラー
  static const Color border = Color(0xFFE8D4BD);
  static const Color borderLight = Color(0xFFF5E6D3);
  static const Color borderDark = Color(0xFFD8C4AD);

  // === 透明度付きカラー ===
  /// 半透明のオーバーレイ
  static const Color overlay = Color(0x808B6F47);
  static const Color overlayLight = Color(0x408B6F47);

  /// カードの背景色をインデックスに基づいて取得
  static Color getCardBackground(int index) {
    return cardBackgrounds[index % cardBackgrounds.length];
  }

  /// カラーの明度を調整
  static Color adjustBrightness(Color color, double factor) {
    assert(factor >= 0 && factor <= 2, 'Factor must be between 0 and 2');
    
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    
    return hsl.withLightness(adjustedLightness).toColor();
  }

  /// カラーに透明度を適用
  static Color withAlpha(Color color, int alpha) {
    assert(alpha >= 0 && alpha <= 255, 'Alpha must be between 0 and 255');
    return color.withAlpha(alpha);
  }
}

