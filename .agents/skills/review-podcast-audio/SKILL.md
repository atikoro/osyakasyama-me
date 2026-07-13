---
name: review-podcast-audio
description: Fix, regenerate, transcribe, and quality-review Podcast episode audio in this repository. Use when an episode MP3/M4A has pronunciation errors, dropped words, merged phrases, unclear parenthetical wording, or needs pre-publication/follow-up AI audio review against narration.txt and tts-input.txt.
---

# Review Podcast Audio

Apply a closed-loop workflow: establish a transcript baseline, fix the source text or pronunciation dictionary, regenerate audio, re-review with independent models, and approve only with fresh evidence.

## Guardrails

- Read `podcast/EDITORIAL_POLICY.md` and the target episode's `README.md` before editing.
- Preserve the source article's claim and ordering. Make only audio-readability changes.
- Treat `narration.txt` and `pronunciations.yaml` as source files.
- Keep `script.md` aligned with narration wording.
- Never hand-edit generated `tts-input.txt` or `pronunciations.md`; regenerate them.
- Do not generate `podcast/feed.xml`, `podcast/index.html`, or `_site/`. GitHub Actions owns site generation.
- Do not publish, push, or replace an externally hosted file without explicit authority.
- Do not approve from a single ASR result. ASR can normalize an actual mispronunciation or invent one.

## 1. Resolve and inspect the episode

Accept an episode number, slug, directory, or audio path. Resolve the episode directory under `episodes/` and inspect:

- `metadata.yaml`
- `script.md` when present
- `narration.txt`
- `pronunciations.yaml`
- `tts-input.txt`
- `audio/episode-NNN-source.mp3`
- `audio/episode-NNN.m4a`
- any existing `review/` artifacts

Record the current Git status, audio duration, size, codec, and SHA-256 before modification. Preserve unrelated user changes.

Require `OPENAI_API_KEY`, `curl`, `ffmpeg`, `ffprobe`, `python3`, and `ruby` before API work.

## 2. Establish a baseline review

Prefer the source MP3; use the M4A if no source MP3 exists.

Run 60-second transcription chunks with a 2-second overlap. The shorter chunk size avoids long-output truncation encountered with episode-length or 120-second requests.

```sh
TRANSCRIPTION_CHUNK_SECONDS=60 \
TRANSCRIPTION_OVERLAP_SECONDS=2 \
TRANSCRIPTION_LANGUAGE=ja \
TRANSCRIPTION_PROMPT='日本語の一人語りのPodcastです。聞こえた内容を省略せず文字起こししてください。' \
scripts/transcribe_episode_audio.sh INPUT_AUDIO REVIEW_DIR
```

Store the pre-fix run under `EPISODE_DIR/review/initial/` when no baseline exists.

Compare the transcript against `tts-input.txt` semantically. Flag:

- missing or added words
- words repeatedly transcribed as a different sound
- merged adjacent terms
- numbers read ambiguously
- parentheses, slashes, or visual punctuation that disappear in speech
- credits, titles, author names, licenses, and episode numbers

Ignore punctuation-only, kanji/kana, Arabic/Kanji numeral, and harmless orthographic normalization differences.

## 3. Confirm candidates

Cut short clips around every candidate with `ffmpeg`. Re-transcribe each clip with at least one independent model such as `gpt-4o-mini-transcribe` or `whisper-1`.

Use these evidence rules:

- Two models agree on a material mismatch: treat it as a likely audio defect.
- Models disagree: mark it for human confirmation or apply a harmless preventive clarification.
- Wording is intrinsically unclear when heard without punctuation: fix it even if ASR reconstructs the intended text.
- Direct audio-model review may supplement ASR but does not replace a second transcription pass.

Do not bias the confirmation prompt with the expected answer unless comparing explicit alternatives after a neutral pass.

## 4. Fix the correct source

Choose the smallest durable correction:

- Pronunciation only: add or update an entry in `pronunciations.yaml`.
- Meaning, word order, parentheses, or pauses: edit both `narration.txt` and `script.md`.
- Merged terms: replace parentheses/slashes with spoken connective words and commas.
- Ambiguous digits: add a pronunciation entry such as `0点` -> `ゼロ点`.
- Names or repeated characters: insert explicit comma-separated spoken forms.

Every pronunciation `surface` must exist in `narration.txt`.

Regenerate derived text:

```sh
scripts/prepare_tts_input.rb \
  EPISODE_DIR/narration.txt \
  EPISODE_DIR/pronunciations.yaml \
  EPISODE_DIR/tts-input.txt \
  EPISODE_DIR/pronunciations.md
```

Verify every intended spoken form appears in `tts-input.txt`. Run `ruby scripts/test_prepare_tts_input.rb`.

## 5. Regenerate audio

Generate the source MP3, then optimize the delivery M4A:

```sh
scripts/generate_openai_tts_long.sh \
  EPISODE_DIR/narration.txt \
  EPISODE_DIR/audio/episode-NNN-source.mp3

scripts/optimize_podcast_audio.sh \
  EPISODE_DIR/audio/episode-NNN-source.mp3 \
  EPISODE_DIR/audio/episode-NNN.m4a
```

Measure both outputs with `ffprobe` and SHA-256. Confirm 24 kHz mono output and non-empty files.

## 6. Re-review until clean

Write the final full transcription to `EPISODE_DIR/review/final/` using 60-second chunks.

Then cut and independently re-transcribe:

- every originally failing interval
- every interval changed during a follow-up iteration
- credits and pronunciation-sensitive terms

Scan the entire final transcript for regressions introduced by nondeterministic TTS. If a new material defect appears, return to step 4 and regenerate again.

Approve only when:

- all original issues are resolved
- no new material issue remains
- a second model confirms the changed intervals
- transcript order and meaning match the source
- audio format and metadata checks pass

## 7. Update episode records

Preserve the episode's existing publication status. Refresh audio measurements without generating site files:

```sh
python3 scripts/update_episode_audio_metadata.py \
  EPISODE_DIR \
  --status EXISTING_STATUS \
  --metadata-only
```

Set `audio.review.status` to `approved` and `changes_required` to `false` only after the final gate passes. Otherwise keep `changes_required` and document blockers.

Write `EPISODE_DIR/review/audio-review.md` with:

- final verdict
- reviewed audio duration and hashes
- initial defects and exact corrections
- models and chunking used
- interval-by-interval results
- remaining risks or human-confirmation items
- reproduction command

Update the episode `README.md` with current audio duration, size, loudness, True Peak, hash, and final review verdict.

## 8. Validate without site generation

Run the smallest complete local verification set:

```sh
ruby scripts/test_prepare_tts_input.rb
python3 scripts/extract_narration.py EPISODE_DIR/script.md /tmp/narration-check.txt
cmp EPISODE_DIR/narration.txt /tmp/narration-check.txt
sh -n scripts/transcribe_episode_audio.sh
git diff --check
```

Also validate:

- `metadata.yaml` parses and retains the existing status
- review JSON files parse and contain non-empty `text`
- M4A size and SHA match `metadata.yaml`
- final review contains the expected number of chunks
- `podcast/feed.xml`, `podcast/index.html`, and `_site/` were not intentionally regenerated

Report changed source files, regenerated audio properties, review evidence, test results, and any publication step intentionally left to GitHub Actions.
