# 第3話 AI音声レビュー

## 判定

- **承認**
- `changes_required: false`
- 原稿の順序と意味を維持し、初期レビューで検出した発音・欠落・音声上の曖昧さを修正した。
- 確定音声の全文レビューと独立モデルによる対象区間レビューで、公開を妨げる問題は残っていない。
- 2026年7月21日、`リズムゲーム`へ展開していた読みを原文どおり`リズムゲー`へ戻し、`割いて`を`さいて`、`各々`を`おのおの`と発音指定して全編を再生成・再レビューした。

## 確定音声

- 配信用M4A: `audio/episode-003.m4a`
- 再生時間: 483.600秒
- サンプルレート: 24000 Hz
- チャンネル: 1
- サイズ: 4204510 bytes
- M4A SHA-256: `464b0a3a1cd381f723b524f4731a9ee269d0a3c3a9ec448e9d464127f72d776a`
- ソースMP3 SHA-256: `bc9e406326460ae6bd7219d229abc06cc0492cd0b484a14564018ece8b342a8f`
- Integrated loudness: -17.07 LUFS
- True peak: -1.92 dBTP

## 初期問題と修正

- 先頭ゼロ付き日付、著者名、英字変数、括弧表現、後日の語境界を修正。
- `pronunciations.yaml`を新設し、`tts-input.txt`と`pronunciations.md`を自動生成した。
- 視覚的な括弧・記号は、意味と順序を変えず、耳で追える接続語・句読点へ展開した。
- `script.md`を追加し、`narration.txt`と機械的に一致する状態にした。
- 原文どおりの略称を保つため、`パズル＆リズムゲー`の読みを`パズル・アンド・リズムゲー`へ変更した。
- `割いて`を`さいて`、`各々`を`おのおの`として発音辞書へ追加した。

## レビュー証跡

- 初期全文: `gpt-4o-transcribe`、60秒、2秒重複、8チャンク
- 独立初期全文: `gpt-4o-mini-transcribe`、60秒、2秒重複、8チャンク
- 最終全文: `gpt-4o-transcribe`、60秒、2秒重複、9チャンク
- 最終対象区間: `gpt-4o-mini-transcribe`、重要区間・冒頭・クレジット、3件
- 発音修正後全文: `gpt-4o-transcribe`、60秒、2秒重複、9チャンク
- 発音修正後の対象区間: `gpt-4o-mini-transcribe`、`リズムゲー`・`割いて`・`各々`
- 第10話と第11話の重要技術語は`whisper-1`でも追加確認した。

## 最終確認結果

- 冒頭の日付、タイトル、話数を確認した。
- 初期レビューで問題となった語句と音声向け修正区間を独立モデルで確認した。
- 著者名、ライセンス、終端まで含むクレジットを確認した。
- 独立モデルで`リズムゲー`と`おのおの`を仮名のまま確認した。`割いて`は漢字へ正規化されたが、TTS入力では`さいて`を明示し、語の脱落や別語化がないことを確認した。
- 同音語の漢字表記、英語／カタカナ、数字表記などのASR正規化差は音声欠陥として扱っていない。
- 第10話の「ユビキタス言語」と第11話のコマンド名は、一音ずつまたは英字単位で説明し、前後の意味も音声内に保持した。

## 再現コマンド

```sh
TRANSCRIPTION_CHUNK_SECONDS=60 \
TRANSCRIPTION_OVERLAP_SECONDS=2 \
TRANSCRIPTION_LANGUAGE=ja \
TRANSCRIPTION_PROMPT='日本語の一人語りのPodcastです。聞こえた内容を省略せず文字起こししてください。' \
scripts/transcribe_episode_audio.sh \
  episodes/003-lacking-in-context/audio/episode-003-source.mp3 \
  episodes/003-lacking-in-context/review/pronunciation-fix-final
```
