# 第1話「気持ちの持たされよう」制作メモ

## 状態

- [x] 題材決定
- [x] 音声向け原稿の初稿作成
- [x] エピソード情報の初稿作成
- [x] 発音確認リストの作成
- [ ] 原文との照合
- [x] 原稿レビュー
- [x] AI音声の生成
- [ ] 声質比較用サンプルの生成
- [x] 試聴と修正
- [x] MP3書き出し
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

## 音声エンジンの初期検証

外部APIの認証情報がない状態でも検証できるよう、macOSの日本語合成音声を比較用ベースラインとして使用する。

比較対象:

- Kyoko: 標準的な日本語女性音声
- Reed（日本語）: 日本語男性音声

生成コマンド:

```sh
scripts/generate_macos_tts.sh \
  episodes/001-state-of-mind/voice-sample.txt \
  episodes/001-state-of-mind/audio/voice-sample-kyoko.aiff \
  Kyoko \
  180
```

声質を確定した後、同じ方法または外部AI音声APIを使って本編を生成する。

### 現在の制約

実行環境では`/usr/bin/say`が音声コンテナのみを作り、音声データを出力しなかったため、ローカル音声による比較は未完了。外部AI音声APIの認証情報も現在は未設定である。

次は、利用する外部AI音声サービスを決めて認証情報を設定するか、音声生成が可能なローカルTTS環境を明示的に導入して実行する。

### 外部AI音声の試作設定

初回試作ではOpenAI Audio APIを使用し、品質重視の`tts-1-hd`と`coral`音声を初期値とする。

```sh
python3 scripts/extract_narration.py \
  episodes/001-state-of-mind/script.md \
  episodes/001-state-of-mind/narration.txt

scripts/generate_openai_tts.sh \
  episodes/001-state-of-mind/narration.txt \
  episodes/001-state-of-mind/audio/episode-001-coral.mp3
```

API呼び出しには`OPENAI_API_KEY`が必要。キーはリポジトリへ保存しない。

## 生成結果

- ファイル: `audio/episode-001-coral.mp3`
- 音声: OpenAI `tts-1-hd` / `coral`
- 再生時間: 約4分44秒
- 形式: MP3、24 kHz、モノラル、160 kbps
- SHA-256: `34ffcbfe5320bb11c3760affc044dca1db15a6a326299e09e90a5e887db6db57`

音声ファイルの生成、形式検証、試聴まで完了。読み間違い、不自然な間、話速について、公開を妨げる違和感は確認されなかった。

### 試聴結果

- 判定: 承認
- 修正: 不要
- 確認項目: 読み間違い、不自然な間、話速、全体的な聞きやすさ
- 次工程: カバー画像、Podcast RSS、音声ファイルの公開先を準備する
