# "Bitcoinノードの最新ブロックと、Explorerの最新ブロックのブロック差分を監視するスクリプト"

## 実装概要

- `rake check_diff` タスクとして実装されています
- 起動すると、指定された Bitcoin ノードに接続し、block height を取得します
- 続けて Blockchain.com の Query API から latest block number を取得します
- 両者を比較し diff が3以上あれば、指定された Slack (Webhook URL) に通知します

## 動作確認方法

`.env` ファイルを作成し編集、`SLACK_WEBHOOK_URL` を差し替えます。

```sh
cp .env.sample .env
vim .env
```

`Dockerfile` にて、`rake` タスクを毎分実行する docker イメージを定義しています。

動作確認用に `docker-compose.yml` にて、そのイメージを使った `app` コンテナと、`bitcoind` コンテナを繋ぎ込んであります。

まとめて起動します。

```sh
docker compose up -d
```

`bitcoind` がブロックチェーンの同期を始めます。

```sh
# 同期ログの確認
docker compose logs --tail=10 -f bitcoind
```

※ ブロックチェーンの同期が進みながら latest block number のチェックも始まるので、
同期が完了するまでかなり長い間、1分に1回 Slack に通知が行きます。

`app` の様子を確認したり止めたりします

```sh
# 動作ログの確認
docker compose logs -f app

# チェックを止める
docker compose stop app
```
