# アプリアイコンの設定手順

## 手順

1. **アイコン画像を保存**
   - 提供されたリスのアイコン画像を `assets/icon/app_icon.png` として保存してください
   - 推奨サイズ: 1024x1024 px (最小 512x512 px)

2. **アイコンを生成**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **アプリを再ビルド**
   ```bash
   # iOS
   flutter build ios
   
   # Android
   flutter build apk
   
   # macOS
   flutter build macos
   ```

## 現在の設定

- アプリ名: **Nocoris**
- 表示名: iOS/Android/macOSで「Nocoris」と表示されます
- アイコン: リスのキャラクターアイコン（設定後）

## 注意事項

- アイコン画像は透過PNG形式を推奨します
- 背景色は白（#FFFFFF）に設定されています
- Android Adaptive Iconにも対応しています

