import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ---------------------------------------------------------------- speech

/// Speech-to-text for the composer's microphone button.
///
/// Uses the platform recogniser (Android SpeechRecognizer, iOS Speech
/// framework, Chrome's Web Speech API). On Android and in Chrome audio may be
/// processed by Google's speech service; see docs/ASSUMPTIONS.md.
abstract interface class SpeechInputService {
  /// Starts listening. [onText] receives the running transcript, [onDone]
  /// fires when recognition ends. Returns false if speech isn't available
  /// or permission was refused.
  Future<bool> start({
    required ValueChanged<String> onText,
    required VoidCallback onDone,
    required ValueChanged<String> onError,
  });

  Future<void> stop();
}

class DeviceSpeechInputService implements SpeechInputService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;
  VoidCallback? _onDone;
  ValueChanged<String>? _onError;

  @override
  Future<bool> start({
    required ValueChanged<String> onText,
    required VoidCallback onDone,
    required ValueChanged<String> onError,
  }) async {
    _onDone = onDone;
    _onError = onError;
    try {
      if (!_ready) {
        _ready = await _stt.initialize(
          onStatus: (status) {
            if (status == SpeechToText.doneStatus ||
                status == SpeechToText.notListeningStatus) {
              _onDone?.call();
            }
          },
          onError: (SpeechRecognitionError e) => _onError?.call(e.errorMsg),
        );
      }
      if (!_ready) return false;
      await _stt.listen(
        onResult: (SpeechRecognitionResult r) => onText(r.recognizedWords),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }
}

// ----------------------------------------------------------- attachments

enum AttachmentKind { image, document }

class PickedAttachment {
  const PickedAttachment({
    required this.name,
    required this.sizeBytes,
    required this.kind,
    this.bytes,
  });

  final String name;
  final int sizeBytes;
  final AttachmentKind kind;

  /// Image bytes for the in-chat thumbnail (null for documents).
  final Uint8List? bytes;
}

/// Lets the user choose a photo or document to share with Atlas.
abstract interface class AttachmentPicker {
  /// Returns null if the user cancels.
  Future<PickedAttachment?> pick(AttachmentKind kind);
}

class DeviceAttachmentPicker implements AttachmentPicker {
  static const maxBytes = 10 * 1024 * 1024; // 10 MB

  @override
  Future<PickedAttachment?> pick(AttachmentKind kind) async {
    final file = await FilePicker.pickFile(
      type: kind == AttachmentKind.image ? FileType.image : FileType.custom,
      allowedExtensions: kind == AttachmentKind.image
          ? null
          : const [
              'pdf',
              'doc',
              'docx',
              'xls',
              'xlsx',
              'csv',
              'txt',
              'png',
              'jpg',
              'jpeg',
            ],
    );
    if (file == null) return null;
    final size = await file.xFile.length();
    if (size > maxBytes) {
      throw const AttachmentTooLargeException();
    }
    final bytes = kind == AttachmentKind.image
        ? await file.xFile.readAsBytes()
        : null;
    return PickedAttachment(
      name: file.name,
      sizeBytes: size,
      kind: kind,
      bytes: bytes,
    );
  }
}

class AttachmentTooLargeException implements Exception {
  const AttachmentTooLargeException();
}

// ----------------------------------------------------------------- sounds

enum ChatSound { sent, received, success }

/// Short original UI sounds (assets/sounds). They follow the phone's silent
/// switch on iOS and mix with other audio instead of interrupting it.
abstract interface class ChatSoundPlayer {
  bool get enabled;
  set enabled(bool value);
  void play(ChatSound sound);
}

class DeviceChatSoundPlayer implements ChatSoundPlayer {
  /// Set by the test harness: no platform audio in widget tests.
  static bool debugMuted = false;

  @override
  bool enabled = true;

  final Map<ChatSound, AudioPlayer> _players = {};
  bool _contextSet = false;

  @override
  void play(ChatSound sound) {
    if (!enabled || debugMuted) return;
    unawaited(_play(sound));
  }

  Future<void> _play(ChatSound sound) async {
    try {
      if (!_contextSet) {
        _contextSet = true;
        await AudioPlayer.global.setAudioContext(
          AudioContextConfig(
            focus: AudioContextConfigFocus.mixWithOthers,
            respectSilence: true,
          ).build(),
        );
      }
      final player = _players[sound] ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await player.play(
        AssetSource('sounds/${sound.name}.wav'),
        volume: 0.6,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Sounds are decorative; never let audio errors affect the chat.
    }
  }
}

class SilentChatSoundPlayer implements ChatSoundPlayer {
  @override
  bool enabled = false;

  @override
  void play(ChatSound sound) {}
}
