# GitHub Pagesホスティング検討

## 結論

初期の小規模配信先としてGitHub Pagesを利用する。

DNS設定を追加せず、GitHub Pagesが提供する`atikoro.github.io`の無料ドメインを使用する。

## 想定URL

```text
https://atikoro.github.io/osyakasyama-me/feed.xml
https://atikoro.github.io/osyakasyama-me/cover.jpg
https://atikoro.github.io/osyakasyama-me/episodes/episode-001.m4a
```

## 容量試算

第1話の配信用ファイルは約2.3 MB。

| 更新頻度 | 年間追加容量 | 1 GB到達の概算 |
| --- | ---: | ---: |
| 月1本 | 約29 MB | 約34年 |
| 月2本 | 約59 MB | 約17年 |
| 月4本 | 約118 MB | 約8年 |

実際には画像、履歴、Git内部データも増えるため、余裕を持って評価する。ただし月1〜2本の初期運用では、GitHub Pagesの公開サイト上限1 GBとリポジトリ推奨1 GBをすぐに圧迫する規模ではない。

## 帯域試算

GitHub Pagesの月間ソフト帯域上限は100 GB。

第1話が2,452,205 bytesの場合、他の転送を無視すると、月間約4万回の全編ダウンロードに相当する。初期検証には十分な余裕がある。

## 利点

- 追加のホスティング契約が不要。
- GitHub Actionsによる自動公開を構築できる。
- RSS、カバー、音声を同一オリジンで配信できる。
- 公開内容をGitの履歴として管理できる。

## 注意点

- GitHub Pagesには公開サイト1 GB、リポジトリ推奨1 GB、月間100 GBのソフト帯域制限がある。
- 音声をGitへ追加するたび、過去バージョンが履歴に残る。公開後の音声ファイルを同じ名前で繰り返し更新しない。
- 音声ファイルのGUIDとURLは公開後に変更しない。
- 大規模化した場合は、音声のみCloudflare R2などへ移行する。
- GitHub Pagesを有効化するまでは外部公開されない。

## 推奨構成

```text
Gitリポジトリ
├── podcast/cover.jpg
├── podcast/feed.xml
└── episodes/*/audio/*.m4a
        ↓ GitHub Actions
GitHub Pages公開用artifact
├── feed.xml
├── cover.jpg
└── episodes/*.m4a
```

## 公開前の残作業

1. GitHubリポジトリのPages設定で公開元をGitHub Actionsにする。
2. デプロイワークフローを実行する。
3. 公開後にHEAD、Range、Content-Typeを検証する。
