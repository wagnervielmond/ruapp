// DENTRO DE: lib/src/services/admob_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService with ChangeNotifier {
  // --- Banner Ad ---
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  // 🚨 SUBSTITUA PELO SEU ID DE BANNER
  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8845063634524167/5869135621'
      : 'ca-app-pub-8845063634524167/3429824489';

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;

  // --- App Open Ad ---
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdReady = false;
  // 🚨 SUBSTITUA PELO SEU ID DE ANÚNCIO DE ABERTURA
  final String _appOpenAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8845063634524167/6432210580'
      : 'ca-app-pub-8845063634524167/5237730179';

  // --- Métodos do Banner ---
  void loadBannerAd() {
    if (_isBannerAdReady) return;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // --- Métodos do Anúncio de Abertura ---
  void loadAppOpenAd() {
    if (_isAppOpenAdReady) return;

    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  void showAppOpenAd() {
    if (!_isAppOpenAdReady || _appOpenAd == null) {
      print("App Open Ad not ready yet.");
      loadAppOpenAd(); // Tenta carregar o próximo
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('$ad showed.'),
      onAdDismissedFullScreenContent: (ad) {
        print('$ad dismissed.');
        ad.dispose();
        _appOpenAd = null;
        _isAppOpenAdReady = false;
        loadAppOpenAd(); // Carrega o próximo anúncio para a próxima abertura
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad failed to show: $error');
        ad.dispose();
      },
    );

    _appOpenAd!.show();
  }

  // --- Limpeza Geral ---
  void disposeAds() {
    _bannerAd?.dispose();
    _appOpenAd?.dispose();
  }

  // ADICIONE ESTE MÉTODO:
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _isBannerAdReady = false;
    // Notificamos para que a UI que ainda existe saiba que o banner se foi.
    // notifyListeners();
  }
}