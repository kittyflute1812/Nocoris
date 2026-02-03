import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

/// 絵文字ピッカーウィジェット
/// 
/// アイテムのアイコンとして使用する絵文字を選択するためのウィジェット
class EmojiPickerWidget extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final String? selectedEmoji;

  const EmojiPickerWidget({
    required this.onEmojiSelected, super.key,
    this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 選択された絵文字の表示
        if (selectedEmoji != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '選択中のアイコン',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedEmoji!,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
        // 絵文字ピッカー
        Expanded(
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              onEmojiSelected(emoji.emoji);
            },
            config: Config(
              emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 28 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.20
                        : 1.0),
              ),
              categoryViewConfig: CategoryViewConfig(
                iconColorSelected: Theme.of(context).colorScheme.primary,
              ),
              bottomActionBarConfig: BottomActionBarConfig(
                buttonColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                buttonIconColor: Theme.of(context).colorScheme.onSurface,
              ),
              searchViewConfig: SearchViewConfig(
                buttonIconColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 絵文字選択ボトムシート
/// 
/// 絵文字ピッカーをボトムシートとして表示するヘルパー関数
Future<String?> showEmojiPickerBottomSheet({
  required BuildContext context,
  String? currentEmoji,
}) async {
  String? selectedEmoji = currentEmoji;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                Text(
                  'アイコンを選択',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedEmoji),
                  child: const Text('完了'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 絵文字ピッカー
          Expanded(
            child: EmojiPickerWidget(
              selectedEmoji: selectedEmoji,
              onEmojiSelected: (emoji) {
                selectedEmoji = emoji;
              },
            ),
          ),
        ],
      ),
    ),
  );
}

