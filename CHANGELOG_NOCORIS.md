# Nocoris リブランディング 🐿️

## 変更内容

### アプリ名の変更
- **旧名**: CountDrop
- **新名**: Nocoris（ノコリス）

### 更新されたファイル

#### アプリケーション設定
- ✅ `lib/core/constants/app_constants.dart` - アプリ名定数を更新
- ✅ `lib/app.dart` - MaterialAppのtitleとthemeModeを更新
- ✅ `ios/Runner/Info.plist` - iOS表示名を「Nocoris」に変更
- ✅ `android/app/src/main/AndroidManifest.xml` - Android表示名を「Nocoris」に変更
- ✅ `pubspec.yaml` - 説明文を更新、flutter_launcher_iconsを追加

#### ドキュメント
- ✅ `README.md` - タイトルと説明を更新、リスの絵文字を追加
- ✅ `TODO.md` - タイトルと説明を更新、リスの絵文字を追加
- ✅ `ICON_SETUP.md` - アイコン設定手順を新規作成
- ✅ `RENAME_REPOSITORY.md` - リポジトリ名変更手順を新規作成

#### テスト
- ✅ `test/widget_test.dart` - アプリ名のテストを更新
- ✅ すべてのテスト（41個）が正常にパス

## アイコン設定（次のステップ）

提供されたリスのアイコン画像を使用してアプリアイコンを設定します：

1. **画像を保存**
   - リスのアイコン画像を `assets/icon/app_icon.png` として保存
   - 推奨サイズ: 1024x1024 px

2. **アイコンを生成**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **アプリを再ビルド**
   ```bash
   flutter build ios
   flutter build apk
   flutter build macos
   ```

詳細は `ICON_SETUP.md` を参照してください。

## リポジトリ名の変更（次のステップ）

GitHubでリポジトリ名を `drop_counter` から `Nocoris` に変更します。

詳細は `RENAME_REPOSITORY.md` を参照してください。

## テスト結果

```
✅ 41 tests passed
✅ No linter errors
✅ No analyzer warnings
```

## ブランチ情報

- ブランチ名: `feature/update-repository`
- コミット: `feat: アプリ名を「Nocoris」に変更 🐿️`

---

**Nocoris** - かわいいリスと一緒に、残数管理を楽しく便利に！ 🐿️
