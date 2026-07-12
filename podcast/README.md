# Podcast公開手順

## 公開ファイル

以下を`https://blog.osyakasyama.me/podcast/`配下へ配置する。

```text
podcast/
├── cover.jpg
├── feed.xml
└── episodes/
    └── episode-001-coral.mp3
```

リポジトリ内の音声ファイルは次にある。

```text
episodes/001-state-of-mind/audio/episode-001-coral.mp3
```

音声はサイズが大きいためGit管理しない。公開時にサーバーへ別途配置する。

## RSS生成

```sh
scripts/generate_podcast_feed.rb
```

生成元:

- 番組情報: `podcast/feed-config.yaml`
- エピソード情報: `episodes/*/metadata.yaml`
- 音声ファイル: 各エピソードの`audio.file`

`status: audio_approved`のエピソードだけがRSSへ追加される。

## サーバー要件

- HTTPSで公開する。
- RSS、カバー、音声に外部からアクセスできるようにする。
- 音声ファイルに対するHTTP HEADリクエストへ応答する。
- 音声ファイルに対するRangeリクエストへ応答する。
- カバー画像のLast-Modifiedヘッダーを返す。
- RSSのContent-Typeを`application/rss+xml`または互換形式にする。
- MP3のContent-Typeを`audio/mpeg`にする。

## 公開後の確認URL

- RSS: https://blog.osyakasyama.me/podcast/feed.xml
- カバー: https://blog.osyakasyama.me/podcast/cover.jpg
- 第1話: https://blog.osyakasyama.me/podcast/episodes/episode-001-coral.mp3

## 配信サービスへの登録

サーバー上の3ファイルを確認した後、RSS URLをApple Podcasts ConnectとSpotify for Creatorsへ登録する。
