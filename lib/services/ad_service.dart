// lib/services/ad_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kReleaseMode, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final instance = AdService._();

  // ════════════════════════════════════════════════════════════
  //  INTERRUPTOR DE PRUEBAS
  //  true  → IDs de prueba de Google, tu móvil como dispositivo de
  //          prueba, formulario de consentimiento simulando UE en
  //          cada arranque, intersticial en cada entrada nueva y
  //          logs [ADS] en consola.
  //  false → PRODUCCIÓN: tus IDs reales, sin logs, intersticial
  //          cada 3 entradas nuevas.
  //  ⚠️ ANTES DE GENERAR EL .aab PARA PLAY STORE: ponlo en false.
  // ════════════════════════════════════════════════════════════
  static const bool _testMode = false;

  // IDs de tu móvil (solo se usan si _testMode es true).
  // Cambian según la firma de la app, por eso hay uno por build.
  static const _testDeviceIds = [
    '8D42BC2F16E392CB5480FFF09BA8A77A', // build release
    '3E375B2FDF449D36C65CAC23596FDB52', // build debug
  ];

  // IDs de prueba de Google
  static const _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialTest = 'ca-app-pub-3940256099942544/1033173712';

  // IDs reales de Houra
  static const _bannerReal = 'ca-app-pub-7975170995058026/9779565863';
  static const _interstitialReal = 'ca-app-pub-7975170995058026/7153402521';

  static String get bannerId =>
      (kReleaseMode && !_testMode) ? _bannerReal : _bannerTest;
  static String get interstitialId =>
      (kReleaseMode && !_testMode) ? _interstitialReal : _interstitialTest;

  // Cada cuántas entradas nuevas sale el intersticial
  static const _everyN = _testMode ? 1 : 3;

  int _created = 0;
  bool ready = false;
  bool _loading = false;
  int _retries = 0;
  InterstitialAd? _ad;

  void _log(String msg) {
    if (_testMode) debugPrint('[ADS] $msg');
  }

  Future<void> init() async {
    if (_testMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: _testDeviceIds),
      );
    }

    await _requestConsent();

    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
      ready = true;
      _load();
    } else {
      _log('canRequestAds = false (sin consentimiento)');
    }
  }

  Future<void> _requestConsent() async {
    // En test borramos el consentimiento guardado para que el formulario
    // se evalúe de nuevo en cada arranque.
    if (_testMode) {
      await ConsentInformation.instance.reset();
    }

    final params = _testMode
        ? ConsentRequestParameters(
            consentDebugSettings: ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: _testDeviceIds,
            ),
          )
        : ConsentRequestParameters();

    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (_testMode) {
          final status = await ConsentInformation.instance.getConsentStatus();
          final available =
              await ConsentInformation.instance.isConsentFormAvailable();
          _log('consent status=$status formAvailable=$available');
        }
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            _log('form error: ${formError.errorCode} ${formError.message}');
          }
          if (!completer.isCompleted) completer.complete();
        });
      },
      (error) {
        _log('consent update error: ${error.errorCode} ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  void _load() {
    if (_loading) return;
    _loading = true;
    _log('cargando intersticial: $interstitialId');
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _log('intersticial cargado');
          _loading = false;
          _retries = 0;
          _ad = ad;
        },
        onAdFailedToLoad: (e) {
          _log('intersticial falló: ${e.code} ${e.message}');
          _loading = false;
          _ad = null;
          if (_retries < 3) {
            _retries++;
            Future.delayed(Duration(seconds: 5 * _retries), _load);
          }
        },
      ),
    );
  }

  /// Llamar tras guardar una entrada nueva (no al editar).
  void onEntryCreated() {
    if (!ready) return;
    _created++;
    if (_ad == null) _load(); // reintenta si aún no hay anuncio listo
    if (_created % _everyN != 0) return;

    final ad = _ad;
    if (ad == null) {
      _log('no hay intersticial listo todavía');
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _ad = null;
        _load();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _ad = null;
        _load();
      },
    );
    ad.show();
    _ad = null;
  }
}