# 第1話「気持ちの持たされよう」制作メモ

## 状態

- [x] 題材決定
- [x] 音声向け原稿の初稿作成
- [x] エピソード情報の初稿作成
- [x] 発音確認リストの作成
- [x] 原文との照合
- [x] 原稿レビュー
- [x] AI音声の生成
- [x] 試聴と修正
- [x] AI文字起こしによる音声レビュー
- [x] 配信用M4A書き出し
- [x] RSSへの登録

## 制作方針

- 原文の主張を変えない。
- 視覚的な区切りに頼らず、耳だけで論旨を追える構成にする。
- 長い一文を分割する。
- 野球の例は残すが、Podcastでは冗長にならないよう整理する。
- 冒頭と末尾に番組固有の案内を追加する。
- AI音声で不自然になる箇所は、意味を変えない範囲で言い換える。

## 原文

- タイトル: 気持ちの持たされよう
- 公開日: 2025年7月1日
- URL: https://blog.osyakasyama.me/wiliki/20250701-state-of-mind
- タグ: 哲学
- 著者表記: pleasure666

## 成果物

- `script.md`: 音声用原稿
- `metadata.yaml`: エピソード情報
- `pronunciations.md`: 発音確認リスト
- `audio/`: 試作音声の保存先

## AI音声生成

OpenAI Audio APIの`tts-1-hd`と`coral`音声を使用する。

```sh
python3 scripts/extract_narration.py \
  episodes/001-state-of-mind/script.md \
  episodes/001-state-of-mind/narration.txt

scripts/generate_openai_tts_long.sh \
  episodes/001-state-of-mind/narration.txt \
  episodes/001-state-of-mind/audio/episode-001-source.mp3
```

API呼び出しには`OPENAI_API_KEY`が必要。キーはリポジトリへ保存しない。

## 元音声の生成結果

- ファイル: `audio/episode-001-source.mp3`
- 音声: OpenAI `tts-1-hd` / `coral`
- 再生時間: 約7分35秒
- 形式: MP3、24 kHz、モノラル、160 kbps
- ファイルサイズ: 9,092,685 bytes（約8.7 MB）
- SHA-256: `5283733471b66df8eb65e60e13d5ea263611e7c41e5aad7f64193d639b3aca46`

音声ファイルの生成、形式検証、試聴まで完了。読み間違い、不自然な間、話速について、公開を妨げる違和感は確認されなかった。

## 配信用最適化

配信には元のMP3ではなく、`audio/episode-001.m4a`を使用する。

- 形式: AAC / M4A
- サンプルレート: 24 kHz
- チャンネル: モノラル
- ビットレート: 約68 kbps
- 再生時間: 約7分35秒
- ファイルサイズ: 3,962,342 bytes（約3.8 MB）
- Integrated loudness: -17.13 LUFS
- True peak: -2.24 dBTP
- SHA-256: `3cf0befde10880101efd26b73e4551e82771f784523c1e38ab459643a31e424e`
- 元MP3からの削減率: 56.4%

Apple Podcastsが24 kHzモノラルに推奨する40〜80 kbpsの範囲に収まり、ラウドネスとTrue Peakも推奨範囲を満たす。

### 試聴結果

- 初回AI文字起こしレビュー: 要修正
- 修正後AI文字起こしレビュー: 承認
- レポート: `review/audio-review.md`
- 修正内容: 発音指定、括弧表現の音声向け展開、語間の明瞭化
- 確認項目: 読み間違い、不自然な間、話速、全体的な聞きやすさ
- 公開状態: GitHub Pagesで公開済み
- 公開URL: https://atikoro.github.io/osyakasyama-me/episodes/episode-001.m4a
