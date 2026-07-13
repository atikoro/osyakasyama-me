# 第6話 AI音声レビュー

## 判定

- **承認**
- `changes_required: false`
- 原稿の順序と意味を維持し、初期レビューで検出した発音・欠落・音声上の曖昧さを修正した。
- 確定音声の全文レビューと独立モデルによる対象区間レビューで、公開を妨げる問題は残っていない。

## 確定音声

- 配信用M4A: `audio/episode-006.m4a`
- 再生時間: 465.400秒
- サンプルレート: 24000 Hz
- チャンネル: 1
- サイズ: 4037285 bytes
- M4A SHA-256: `d2886aeef6db02492af8011e66cf64e90ddbc64cb95497ff87cb8e22670cd330`
- ソースMP3 SHA-256: `7bc6d7fe4db2af23ded75f355b6351d11227e72aec8b9f58354d464ef6654c6b`
- Integrated loudness: -16.96 LUFS
- True peak: -2.52 dBTP

## 初期問題と修正

- 日付、珍プレー／好プレー、Git／GitHub、nits、ピープルウェアの説明を修正。
- `pronunciations.yaml`を新設し、`tts-input.txt`と`pronunciations.md`を自動生成した。
- 視覚的な括弧・記号は、意味と順序を変えず、耳で追える接続語・句読点へ展開した。
- `script.md`を追加し、`narration.txt`と機械的に一致する状態にした。

## レビュー証跡

- 初期全文: `gpt-4o-transcribe`、60秒、2秒重複、6チャンク
- 独立初期全文: `gpt-4o-mini-transcribe`、60秒、2秒重複、6チャンク
- 最終全文: `gpt-4o-transcribe`、60秒、2秒重複、8チャンク
- 最終対象区間: `gpt-4o-mini-transcribe`、重要区間・冒頭・クレジット、3件
- 第10話と第11話の重要技術語は`whisper-1`でも追加確認した。

## 最終確認結果

- 冒頭の日付、タイトル、話数を確認した。
- 初期レビューで問題となった語句と音声向け修正区間を独立モデルで確認した。
- 著者名、ライセンス、終端まで含むクレジットを確認した。
- 同音語の漢字表記、英語／カタカナ、数字表記などのASR正規化差は音声欠陥として扱っていない。
- 第10話の「ユビキタス言語」と第11話のコマンド名は、一音ずつまたは英字単位で説明し、前後の意味も音声内に保持した。

## 再現コマンド

```sh
TRANSCRIPTION_CHUNK_SECONDS=60 \
TRANSCRIPTION_OVERLAP_SECONDS=2 \
TRANSCRIPTION_LANGUAGE=ja \
TRANSCRIPTION_PROMPT='日本語の一人語りのPodcastです。聞こえた内容を省略せず文字起こししてください。' \
scripts/transcribe_episode_audio.sh \
  episodes/006-review-and-psychological-safety/audio/episode-006-source.mp3 \
  episodes/006-review-and-psychological-safety/review/final
```
