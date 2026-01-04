# リポジトリ名の変更手順

## GitHubでのリポジトリ名変更

1. **GitHubのリポジトリページにアクセス**
   - https://github.com/あなたのユーザー名/drop_counter

2. **Settings（設定）を開く**
   - リポジトリページの上部にある「Settings」タブをクリック

3. **リポジトリ名を変更**
   - 「Repository name」セクションで `drop_counter` を `Nocoris` に変更
   - 「Rename」ボタンをクリック

4. **ローカルリポジトリのリモートURLを更新**
   ```bash
   cd /Users/hiranotomomi/Desktop/product/drop_counter
   git remote set-url origin https://github.com/あなたのユーザー名/Nocoris.git
   ```

5. **変更を確認**
   ```bash
   git remote -v
   ```

## ローカルディレクトリ名の変更（オプション）

リポジトリ名を変更した後、ローカルのディレクトリ名も変更できます：

```bash
cd /Users/hiranotomomi/Desktop/product
mv drop_counter Nocoris
cd Nocoris
```

## 注意事項

- リポジトリ名を変更すると、古いURLは自動的に新しいURLにリダイレクトされます
- ただし、できるだけ早く新しいURLを使用することを推奨します
- CI/CDや外部サービスで使用しているURLも更新が必要です

## 完了後の確認

```bash
# リモートURLの確認
git remote -v

# プッシュして確認
git push origin feature/update-repository
```

