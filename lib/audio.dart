import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'util.dart';

/// Sonidos generados en código (no hace falta ningún archivo de audio).
class Sfx {
  static const int _sr = 22050;
  static final AudioPlayer _fx = AudioPlayer();
  static final AudioPlayer _bowlPlayer = AudioPlayer();
  static final AudioPlayer _noise = AudioPlayer();
  static Uint8List? _chimeBytes;
  static Uint8List? _bowlBytes;
  static final Map<String, Uint8List> _noiseCache = <String, Uint8List>{};

  static Uint8List _wav(List<double> s) {
    final n = s.length;
    final data = ByteData(44 + n * 2);
    void str(int off, String t) {
      for (var i = 0; i < t.length; i++) {
        data.setUint8(off + i, t.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + n * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, _sr, Endian.little);
    data.setUint32(28, _sr * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, n * 2, Endian.little);
    for (var i = 0; i < n; i++) {
      var v = s[i];
      if (v > 1) v = 1;
      if (v < -1) v = -1;
      data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }

  static List<double> _chimeSamples() {
    final total = (_sr * 1.05).toInt();
    final out = List<double>.filled(total, 0.0);
    const freqs = [660.0, 880.0, 1320.0];
    for (var k = 0; k < freqs.length; k++) {
      final start = (k * 0.17 * _sr).toInt();
      final len = (0.65 * _sr).toInt();
      for (var i = 0; i < len && start + i < total; i++) {
        final t = i / _sr;
        final att = t < 0.02 ? t / 0.02 : 1.0;
        final amp = 0.22 * att * math.exp(-6.5 * t);
        out[start + i] += amp * math.sin(2 * math.pi * freqs[k] * t);
      }
    }
    return out;
  }

  static List<double> _bowlSamples() {
    final total = _sr * 6;
    final out = List<double>.filled(total, 0.0);
    const parts = [
      [196.0, 0.22],
      [541.0, 0.08],
      [1058.0, 0.04],
    ];
    for (final p in parts) {
      for (var i = 0; i < total; i++) {
        final t = i / _sr;
        final att = t < 0.03 ? t / 0.03 : 1.0;
        out[i] += p[1] * att * math.exp(-1.3 * t) * math.sin(2 * math.pi * p[0] * t);
      }
    }
    return out;
  }

  static List<double> _noiseSamples(String type) {
    final rnd = math.Random(7);
    final len = _sr * 6;
    final fade = (_sr * 0.08).toInt();
    final g = List<double>.filled(len + fade, 0.0);
    double b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0, last = 0;
    for (var i = 0; i < len + fade; i++) {
      final w = rnd.nextDouble() * 2 - 1;
      if (type == 'white') {
        g[i] = w * 0.35;
      } else if (type == 'pink') {
        b0 = 0.99886 * b0 + w * 0.0555179;
        b1 = 0.99332 * b1 + w * 0.0750759;
        b2 = 0.969 * b2 + w * 0.153852;
        b3 = 0.8665 * b3 + w * 0.3104856;
        b4 = 0.55 * b4 + w * 0.5329522;
        b5 = -0.7616 * b5 - w * 0.016898;
        g[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) * 0.1;
        b6 = w * 0.115926;
      } else {
        last = (last + 0.02 * w) / 1.02;
        g[i] = last * 3.2;
      }
    }
    final d = List<double>.filled(len, 0.0);
    for (var i = 0; i < len; i++) {
      d[i] = g[i];
    }
    for (var i = 0; i < fade; i++) {
      final a = i / fade;
      d[i] = g[len + i] * (1 - a) + g[i] * a;
    }
    return d;
  }

  static Future<void> chime(bool on) async {
    if (!on) return;
    try {
      _chimeBytes ??= _wav(_chimeSamples());
      await _fx.stop();
      await _fx.play(BytesSource(_chimeBytes!));
    } catch (_) {}
  }

  static Future<void> bowl(bool on) async {
    if (!on) return;
    try {
      _bowlBytes ??= _wav(_bowlSamples());
      await _bowlPlayer.stop();
      await _bowlPlayer.play(BytesSource(_bowlBytes!));
    } catch (_) {}
  }

  /// type: off | white | pink | brown
  static Future<void> setNoise(String type, double vol) async {
    try {
      await _noise.stop();
      if (type == 'off') return;
      final bytes = _noiseCache.putIfAbsent(type, () => _wav(_noiseSamples(type)));
      await _noise.setReleaseMode(ReleaseMode.loop);
      await _noise.setVolume(clampD(vol * 0.7, 0.0, 1.0));
      await _noise.play(BytesSource(bytes));
    } catch (_) {}
  }

  static Future<void> setNoiseVolume(double vol) async {
    try {
      await _noise.setVolume(clampD(vol * 0.7, 0.0, 1.0));
    } catch (_) {}
  }
}
