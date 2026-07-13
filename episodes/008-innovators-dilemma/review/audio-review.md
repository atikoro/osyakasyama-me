# 第8話 AI音声レビュー

## 判定

- **承認**
- `changes_required: false`
- 原稿の順序と意味を維持し、初期レビューで検出した発音・欠落・音声上の曖昧さを修正した。
- 確定音声の全文レビューと独立モデルによる対象区間レビューで、公開を妨げる問題は残っていない。

## 確定音声

- 配信用M4A: `audio/episode-008.m4a`
- 再生時間: 703.900秒
- サンプルレート: 24000 Hz
- チャンネル: 1
- サイズ: 6148629 bytes
- M4A SHA-256: `3f2057eba83f167c0c78ca50d634ab7cab85f2fbb8fe75bec4c7a6a9e146b0df`
- ソースMP3 SHA-256: `1571770b31e4b4572e240798040d508a2070537d0f0bad7150111f7f4102b05c`
- Integrated loudness: -16.94 LUFS
- True peak: 2.43 dBTP

## 初期問題と修正

- 日付、M&A、固有名詞・仏教語、括弧表現、冒頭接続、ことわざの音声表現を修正。
- 再生成途中で検出した冒頭後の区間欠落と中盤の反復を不承認とし、TTSを450文字単位に細分化して再生成した。
- 「思い立ったが吉日」「フッ軽」「躊躇う」「怠さ」「稀代」などの読みを発音辞書で明示し、「秩序だった組織内」の文は音声で欠落しにくい表現へ整えた。
- `pronunciations.yaml`を新設し、`tts-input.txt`と`pronunciations.md`を自動生成した。
- 視覚的な括弧・記号は、意味と順序を変えず、耳で追える接続語・句読点へ展開した。
- `script.md`を追加し、`narration.txt`と機械的に一致する状態にした。

## レビュー証跡

- 初期全文: `gpt-4o-transcribe`、60秒、2秒重複、12チャンク
- 独立初期全文: `gpt-4o-mini-transcribe`、60秒、2秒重複、12チャンク
- 最終全文: `gpt-4o-transcribe`、60秒、2秒重複、12チャンク
- 最終対象区間: `gpt-4o-mini-transcribe`、重要区間・冒頭・クレジット、5件
- 第10話と第11話の重要技術語は`whisper-1`でも追加確認した。

## 最終確認結果

- 冒頭の日付、タイトル、話数を確認した。
- 最終全文で原稿の冒頭からクレジットまで順序どおり存在し、区間欠落・長区間反復がないことを確認した。
- 修正した組織内の説明、田中角栄、諸行は壊法、結論、クレジットを短区間で再文字起こしし、`gpt-4o-mini-transcribe`と`whisper-1`で照合した。
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
  episodes/008-innovators-dilemma/audio/episode-008-source.mp3 \
  episodes/008-innovators-dilemma/review/final
```
