# Something like podcast 配信計画

## 1. 目的

「[Something like blog](https://blog.osyakasyama.me/wiliki/)」の記事を、できるだけ原文のまま朗読し、Podcastとして継続配信する。

## 2. 現在の状態

- 番組名: **Something like podcast**
- 制作方式: 音声向け編集とAI音声
- AI音声: OpenAI `tts-1-hd` / `coral`
- 配信形式: AAC / M4A、24 kHz、モノラル、約64 kbps
- ホスティング: GitHub Pages
- 番組ページ: https://atikoro.github.io/osyakasyama-me/
- RSS: https://atikoro.github.io/osyakasyama-me/feed.xml
- 公開済み: 第1話「気持ちの持たされよう」
- デプロイ: `master`へのpushを契機にGitHub Actionsで自動実行

第1話では原稿レビュー、AI音声生成、試聴、配信用圧縮、RSS生成、GitHub Pages公開、HTTP HEAD・Rangeリクエストの確認まで完了した。

## 3. 制作方針

- 1エピソードにつき1記事を扱う。
- ブログ本文をできるだけ原文のまま朗読する。
- 要約や論旨の組み替えは原則として行わない。
- 別のブログエントリを参照する箇所では、説明欄にリンクがあることを音声で案内する。
- 原文の主張を変更しない。
- 長い一文、視覚表現、コード、表、URL、埋め込み動画などを音声向けに調整する。
- 公開前に原稿と生成音声を人間が確認する。
- 元記事、著者、ライセンス、Podcast向けに変更した事実を明記する。
- 公開後のGUIDと音声URLは変更しない。

長さは記事内容を優先する。第1話は約4分44秒であり、今後も一律の尺へ引き延ばさない。

## 4. エピソード制作フロー

1. 候補記事の内容とライセンスを確認する。
2. 原文を保存し、音声化しない要素を特定する。
3. 音声用原稿を作成する。
4. 原文との意味の一致を確認する。
5. 必須の`pronunciations.yaml`を作成し、発音確認リストを確定する。
6. 発音辞書を適用した`tts-input.txt`を自動生成し、朗読原稿との差分を確認する。
7. `tts-input.txt`からAI音声を生成する。
8. 発音確認リストに沿って、読み間違い、間、話速、聞きやすさを試聴する。
9. AAC / M4Aへ最適化する。
10. `metadata.yaml`を承認済みにする。
11. RSSとGitHub Pages artifactを生成・検証する。
12. `master`へ反映し、公開URLを確認する。

## 5. 配信構成

```text
WiLiKiの記事
    ↓
音声用原稿とメタデータ
    ↓
必須の発音辞書を適用したTTS入力
    ↓
OpenAI TTSによる元音声
    ↓
AAC / M4Aへ圧縮・音量調整
    ↓
GitHub Actions
    ↓
https://atikoro.github.io/osyakasyama-me/
    ├── index.html
    ├── feed.xml
    ├── cover.jpg
    └── episodes/*.m4a
```

RSSと番組ページは`podcast/feed-config.yaml`と`episodes/*/metadata.yaml`から生成する。公開用artifactは`scripts/build_pages_site.sh`で作成する。

## 6. 著作権とライセンス

確認できた記事にはCreative Commons 表示-非営利 4.0（CC BY-NC 4.0）の表記がある。記事ごとに音声化前の再確認を行う。

各エピソードには次を記載する。

> 原作: pleasure666「記事タイトル」<br>
> 原文: 記事URL<br>
> ライセンス: CC BY-NC 4.0<br>
> 画像、コード、外部リンクなど、音声化できない箇所のみ一部調整しています。

第三者が権利を持つ画像、動画、音楽、引用部分は、記事本文と同じ条件で利用できるとは限らないため、原則として音声版へ含めない。

## 7. 品質基準

### 原稿

- 原文の主張やニュアンスが維持されている。
- 文章を見なくても論旨を追える。
- 読み上げに不向きな記号や視覚表現が残っていない。
- クレジットと変更表示がある。
- `pronunciations.yaml`が存在し、すべての登録語が原稿へ適用される。
- `tts-input.txt`と朗読原稿の差分が発音調整に限定されている。

### 音声

- 読み間違いや不自然なアクセントがない。
- 話速と間が聞きやすい。
- Integrated loudnessが概ね`-16 LUFS ± 1`に収まる。
- True Peakが`-1 dBTP`を超えない。
- 24 kHzモノラルの場合、ビットレートを40〜80 kbps程度にする。

### 配信

- RSS XMLが妥当である。
- GUIDが固有かつ不変である。
- カバーが3000×3000 JPEGである。
- 音声がHTTP HEADとRangeリクエストへ応答する。
- RSS、カバー、音声のContent-Typeが適切である。

## 8. GitHub Pagesの運用上限

GitHub Pagesには公開サイト1 GB、リポジトリ推奨1 GB、月間100 GBのソフト帯域制限がある。

第1話の配信用音声は約2.3 MBである。同程度の音声を10本追加した場合でも、音声本体は合計約25 MBであり、初期運用では十分に余裕がある。ただし、音声の差し替えはGit履歴を増やすため、公開前に確定版を作成する。

## 9. 次のマイルストーン

次期エピソード候補として、ブログから約10記事を選定する。

選定では次を重視する。

- 音声だけで理解しやすい。
- ブログのテーマの幅を示せる。
- 第三者素材への依存が少ない。
- 原稿編集量が過大でない。
- 公開順に変化があり、似た話題が連続しない。

候補を確定した後、原稿制作を一括で進めず、数本ずつ原稿・音声・試聴を完了させる。

## 10. 現時点で行わないこと

- 全記事の無確認な一括音声化
- 人間の確認を行わない完全自動公開
- 有料配信や広告挿入
- 複雑な管理画面の開発
- 複数話者による本格的な番組制作

## 参考資料

- [Something like blog](https://blog.osyakasyama.me/wiliki/)
- [GitHub Pages](https://atikoro.github.io/osyakasyama-me/)
- [Apple Podcasts: Podcast RSS feed requirements](https://podcasters.apple.com/support/823-podcast-requirements)
- [Apple Podcasts: Audio requirements](https://podcasters.apple.com/support/893-audio-requirements)
- [Creative Commons 表示-非営利 4.0 International](https://creativecommons.org/licenses/by-nc/4.0/)
