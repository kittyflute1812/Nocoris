/// アプリケーション全体で使用する文字列定数
class AppStrings {
  AppStrings._();

  // 共通
  static const String cancel = 'キャンセル';
  static const String save = '保存';
  static const String edit = '編集';
  static const String delete = '削除';
  static const String retry = '再試行';

  // エラーメッセージ
  static const String initializationError = '初期化に失敗しました';
  static const String updateError = 'アイテムの更新に失敗しました。アイテムが削除された可能性があります。';
  static const String genericError = 'エラーが発生しました';

  // ホーム画面
  static const String noItems = 'アイテムがありません';
  static const String addItem = 'アイテムを追加';
  static const String deleteItemTitle = 'アイテムの削除';
  static String deleteItemMessage(String itemName) => '$itemNameを削除してもよろしいですか?';

  // アイテムフォーム
  static const String newItem = '新しいアイテム';
  static const String editItem = 'アイテムを編集';
  static const String itemNameLabel = 'アイテム名';
  static const String countLabel = '値';
  static const String itemNameRequired = 'アイテム名を入力してください';
  static const String countRequired = '値を入力してください';
  static const String countValidation = '0以上の数値を入力してください';
  static const String saveItemTooltip = 'アイテムを保存';

  // アイテムカード
  static const String remainingCount = '残数';
  static const String itemMenuTooltip = 'アイテムの操作メニュー';
  static const String decrementTooltip = '残数を1つ減らす';
  static const String incrementTooltip = '残数を1つ増やす';
  static String itemNameSemantics(String name) => 'アイテム名: $name';
  static String remainingCountSemantics(int count) => '残数: $count個';
}

