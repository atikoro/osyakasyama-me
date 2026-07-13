# AIによるPodcast音声レビュー

## 結論

LLM側でMP3やM4Aを文字起こしし、正本の`tts-input.txt`と照合してレビューすることは可能。ただし、文字起こし結果だけで発音ミスを確定すると誤検出が起こるため、次の段階に分ける。

1. 音声を文字起こしする
2. 正本との差から候補区間を抽出する
3. 候補区間だけを別モデルまたは音声入力モデルへ渡して再確認する
4. 公開可否は人の試聴を最終ゲートにする

OpenAIのTranscription APIはMP3、MP4、M4A、WAVなどを受け付け、`gpt-4o-transcribe`を利用できる。`gpt-audio`系モデルは音声を直接入力できるため、短い候補区間の聞こえ方や語の脱落確認にも使える。

- [Speech-to-text API reference](https://platform.openai.com/docs/api-reference/audio/createTranscription)
- [GPT-4o Transcribe](https://developers.openai.com/api/docs/models/gpt-4o-transcribe)
- [GPT Audio](https://developers.openai.com/api/docs/models/gpt-audio)

## このリポジトリでの実行方法

Codexから一連の修正・再生成・再レビューを実行する場合は、プロジェクトスキルを使う。

```text
$review-podcast-audio を使って第2話の音声をレビューし、必要なら修正・再生成してください。
```

スキルは`.agents/skills/review-podcast-audio/`にあり、PodcastのRSS、HTML、`_site/`は生成しない。これらはGitHub Actionsへ任せる。

文字起こしだけを手動実行する場合は次のコマンドを使う。

```sh
source .envrc

scripts/transcribe_episode_audio.sh \
  episodes/001-state-of-mind/audio/episode-001-source.mp3 \
  episodes/001-state-of-mind/review
```

デフォルトでは120秒ごとに分割し、境界を2秒重複させる。長尺音声を一括送信するとモデルの出力上限で文字起こしが途中終了する場合があるため、分割を標準とする。

設定は環境変数で変更できる。

```sh
TRANSCRIPTION_LANGUAGE=ja \
TRANSCRIPTION_CHUNK_SECONDS=120 \
TRANSCRIPTION_OVERLAP_SECONDS=2 \
TRANSCRIPTION_PROMPT='日本語のPodcastです。聞こえた内容を省略せず文字起こししてください。' \
scripts/transcribe_episode_audio.sh INPUT_AUDIO OUTPUT_DIR
```

## レビュー上の注意

- ASRは慣用句や漢字を文脈で正規化するため、実際の誤発音を正しい語に直すことがある。
- 逆に、正しく発音されていてもASRだけが誤認識することがある。
- 句読点、漢字・仮名、数字表記の差は、そのまま音声不良と判定しない。
- 重要な指摘は複数モデルで再現するか、音声入力モデルで候補区間を直接確認する。
- API利用時は音声が外部サービスへ送信される。公開前の機密音声にはデータ取り扱い方針を別途確認する。

第1話への適用結果は`episodes/001-state-of-mind/review/audio-review.md`を参照する。
