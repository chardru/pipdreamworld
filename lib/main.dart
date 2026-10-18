import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'state/dream_state.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';
import 'widgets/pip_top_bar.dart';
import 'scenes/welcome_scene.dart';
import 'scenes/meet_pip_scene.dart';
import 'scenes/lullaby_lab_scene.dart';
import 'scenes/nightlight_scene.dart';
import 'scenes/delivery_routes_scene.dart';
import 'scenes/origin_story_scene.dart';
import 'scenes/secret_room_scene.dart';
import 'scenes/goodnight_scene.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload flutter_animate defaults
  Animate.restartOnHotReload = true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => DreamState(),
      child: const PipDreamApp(),
    ),
  );
}

class PipDreamApp extends StatefulWidget {
  const PipDreamApp({super.key});

  @override
  State<PipDreamApp> createState() => _PipDreamAppState();
}

class _PipDreamAppState extends State<PipDreamApp> {
  final AudioService _audioService = AudioService();

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DreamState>();
    final isNight = state.isNightMode;

    return MaterialApp(
      title: "Pip's Dream World — Midnight Nursery",
      debugShowCheckedModeBanner: false,
      theme: isNight ? AppTheme.nightTheme : AppTheme.dayTheme,
      home: PipDreamHome(audioService: _audioService),
    );
  }
}

class PipDreamHome extends StatefulWidget {
  final AudioService audioService;
  const PipDreamHome({super.key, required this.audioService});

  @override
  State<PipDreamHome> createState() => _PipDreamHomeState();
}

class _PipDreamHomeState extends State<PipDreamHome> {
  // Current scene index:
  // 0 = Welcome
  // 1 = Meet Pip
  // 2 = Lullaby Lab
  // 3 = Nightlight Collection
  // 4 = Delivery Routes
  // 5 = Origin Story
  // 6 = Secret Room (shown inline when all stars collected)
  // 7 = Goodnight
  int _scene = 0;

  void _goTo(int scene) {
    setState(() => _scene = scene);
    // Scroll back to top when changing scenes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrimaryScrollController.of(context).animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DreamState>();
    final isNight = state.isNightMode;

    // Secret room overlay
    if (state.showSecretRoom) {
      return Scaffold(
        body: SecretDreamRoomScene(
          onContinue: () {
            state.closeSecretRoom();
            // After secret room, go to goodnight (or origin story if not there yet)
            if (_scene < 7) _goTo(7);
          },
        ),
      );
    }

    return Scaffold(
      appBar: PipTopBar(
        isNight: isNight,
        soundEnabled: state.soundEnabled,
        starsFound: state.starsCount,
        onToggleTheme: () => state.toggleNightMode(),
        onToggleSound: () {
          state.toggleSound();
          widget.audioService.toggleMute();
        },
      ),
      body: Stack(
        children: [
          // Main scene
          _buildScene(state),

          // Secret room unlock banner
          if (state.secretRoomUnlocked && !state.showSecretRoom && _scene < 7)
            Positioned(
              bottom: 20,
              right: 20,
              child: _SecretRoomBanner(onOpen: () => state.openSecretRoom()),
            ),
        ],
      ),
    );
  }

  Widget _buildScene(DreamState state) {
    switch (_scene) {
      case 0:
        return WelcomeScene(onEnter: () => _goTo(1));
      case 1:
        return MeetPipScene(onNext: () => _goTo(2));
      case 2:
        return LullabyLabScene(
          onNext: () => _goTo(3),
          audioService: widget.audioService,
        );
      case 3:
        return NightlightCollectionScene(
          onNext: () => _goTo(4),
          audioService: widget.audioService,
        );
      case 4:
        return DeliveryRoutesScene(
          onNext: () => _goTo(5),
          audioService: widget.audioService,
        );
      case 5:
        return OriginStoryScene(onNext: () => _goTo(7));
      case 7:
        return GoodnightScene(
          onReplay: () => _goTo(0),
        );
      default:
        return WelcomeScene(onEnter: () => _goTo(1));
    }
  }
}

/// Banner that appears when all stars are found, inviting user to open Secret Room.
class _SecretRoomBanner extends StatefulWidget {
  final VoidCallback onOpen;
  const _SecretRoomBanner({required this.onOpen});

  @override
  State<_SecretRoomBanner> createState() => _SecretRoomBannerState();
}

class _SecretRoomBannerState extends State<_SecretRoomBanner> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1F4A), Color(0xFF1A1228)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PipColors.goldenGlow.withOpacity(_hovered ? 0.9 : 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: PipColors.goldenGlow.withOpacity(_hovered ? 0.5 : 0.25),
                blurRadius: _hovered ? 30 : 15,
                spreadRadius: _hovered ? 5 : 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_open_rounded,
                color: PipColors.goldenGlow,
                size: 22,
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1500.ms, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                "Secret Dream Room!",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: PipColors.goldenGlow,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut);
  }
}
