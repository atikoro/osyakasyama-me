# Podcast公開手順

## 公開ファイル

以下を`https://atikoro.github.io/osyakasyama-me/`配下へ配置する。

```text
podcast/
├── cover.jpg
├── feed.xml
└── episodes/
    └── episode-001.m4a
```

リポジトリ内の音声ファイルは次にある。

```text
episodes/001-state-of-mind/audio/episode-001.m4a
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
- M4AのContent-Typeを`audio/mp4`または`audio/x-m4a`にする。

## 公開後の確認URL

- 番組ページ: https://atikoro.github.io/osyakasyama-me/
- RSS: https://atikoro.github.io/osyakasyama-me/feed.xml
- カバー: https://atikoro.github.io/osyakasyama-me/cover.jpg
- 第1話: https://atikoro.github.io/osyakasyama-me/episodes/episode-001.m4a

## 配信サービスへの登録

GitHub Pages上の各ファイルを確認した後、RSS URLをApple Podcasts ConnectとSpotify for Creatorsへ登録する。
