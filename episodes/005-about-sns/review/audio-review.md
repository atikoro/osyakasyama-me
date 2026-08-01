# 第5話 AI音声レビュー

## 判定

- **承認・公開**
- `changes_required: false`
- `gpt-4o-mini-tts`の`marin`音声へ切り替えた。
- 修正後音声の全文レビューと独立モデルによる照合で、公開を妨げる欠落や意味の変更は確認されなかった。

## 確定音声

- モデル／音声: `gpt-4o-mini-tts` / `marin`
- 配信用M4A: `audio/episode-005.m4a`
- 再生時間: 532.200秒
- サンプルレート: 24000 Hz
- チャンネル: 1
- サイズ: 4574136 bytes
- M4A SHA-256: `8534a460a5301a60cd9d6b36be4e0c508fe7e180c35b3275b6cb76df303e18bc`
- ソースMP3 SHA-256: `a18026719f334f762cd3cd8918de240e0f22afd299a0481b21b4715aa44f372f`
- Integrated loudness: -16.30 LUFS
- True peak: -2.36 dBTP

## marin版での修正

- 初回生成ではタイトル末尾の「社会」、`Misskey`、「でかくなる」が不明瞭だったため、`pronunciations.yaml`へ読みを追加した。
- 長いTTS入力で終端が欠落したため、生成チャンクを600字へ短縮した。
- 最後の「それでは、また次回。」は独立した短い入力で生成し、末尾へ連結した。
- 正式音声、配信用M4A、メタデータをmarin版へ更新した。

## レビュー証跡

- 発音修正前全文: `gpt-4o-transcribe`と`gpt-4o-mini-transcribe`、60秒、2秒重複、各9チャンク
- 修正候補短区間: 上記2モデルでタイトル、`Misskey`、「でかくなる」を確認
- 最終全文: `gpt-4o-transcribe`、60秒、2秒重複、9チャンク
- 最終独立全文: `gpt-4o-mini-transcribe`、60秒、2秒重複、9チャンク
- 最終独立全文で冒頭タイトル、本文順序、クレジット、終端「それでは、また次回。」を確認
- 漢字・カナ・英字表記や固有語にASRモデル間の表記差はあるが、両モデルで一致する内容欠落はない。

## 再現コマンド

```sh
TTS_INSTRUCTIONS='落ち着いた日本語のポッドキャスト朗読として、自然で明瞭に、入力された全文を一語も省略せず読んでください。' \
TTS_CHUNK_CHARS=600 \
scripts/generate_openai_tts_long.sh \
  episodes/005-about-sns/narration.txt \
  episodes/005-about-sns/audio/episode-005-source.mp3 \
  gpt-4o-mini-tts \
  marin
```

サイトとRSSの生成・配信はGitHub Actionsへ任せる。
