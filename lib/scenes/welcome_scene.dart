import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/dream_state.dart';
import '../theme/app_theme.dart';
import '../widgets/dialogue_bubble.dart';
import '../widgets/starfield_background.dart';

class WelcomeScene extends StatefulWidget {
  final VoidCallback onEnter;
  const WelcomeScene({super.key, required this.onEnter});

  @override
  State<WelcomeScene> createState() => _WelcomeSceneState();
}

class _WelcomeSceneState extends State<WelcomeScene>
    with SingleTickerProviderStateMixin {
  bool _dialogueDone = false;
  bool _showButton = false;
  late AnimationController _floatController;

  final List<String> _pipLines = [
    "Oh! Someone's awake! ✨",
    "Welcome to the Midnight Nursery!",
    "I'm Pip — your friendly neighbourhood Dream Engineer.",
    "I build the dreams you fall asleep inside.",
    "Umm... would you like to see what I've been dreaming up?",
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _onDialogueComplete() {
    setState(() {
      _dialogueDone = true;
      _showButton = true;
    });
  }

  void _handleEnter() {
    final state = context.read<DreamState>();
    state.unlockAudio();
    widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    final dreamState = context.watch<DreamState>();
    final isNight = dreamState.isNightMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return StarfieldBackground(
      isNight: isNight,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Moon / Sun decoration
              _MoonDecoration(isNight: isNight),

              const SizedBox(height: 20),

              // Pip on Cloud
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  final offset = _floatController.value * 14 - 7;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: child,
                  );
                },
                child: _PipOnCloud(isNight: isNight, isMobile: isMobile),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                    "✨ Pip's Dream World ✨",
                    style: GoogleFonts.nunito(
                      fontSize: isMobile ? 26 : 38,
                      fontWeight: FontWeight.w800,
                      color: isNight
                          ? PipColors.goldenGlow
                          : PipColors.berryPink,
                      shadows: [
                        Shadow(
                          color: isNight
                              ? PipColors.goldenGlow.withOpacity(0.5)
                              : PipColors.berryPink.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms),

              const SizedBox(height: 8),

              Text(
                "A tiny universe of lullabies, nightlights & delivered dreams",
                style: GoogleFonts.nunito(
                  fontSize: isMobile ? 14 : 16,
                  color: isNight
                      ? PipColors.lavender
                      : PipColors.brown.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              const SizedBox(height: 40),

              // Dialogue
              if (!_dialogueDone)
                DialogueBubble(
                      lines: _pipLines,
                      isNight: isNight,
                      onComplete: _onDialogueComplete,
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),

              // Enter button
              if (_showButton) ...[
                const SizedBox(height: 32),
                _EnterButton(isNight: isNight, onPressed: _handleEnter)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),
              ],

              const SizedBox(height: 80),

              // Floating stars decoration
              _FloatingStarRow(isNight: isNight),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoonDecoration extends StatelessWidget {
  final bool isNight;
  const _MoonDecoration({required this.isNight});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: isNight
          ? Container(
                  key: const ValueKey('moon'),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3CC),
                    boxShadow: [
                      BoxShadow(
                        color: PipColors.goldenGlow.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: PipColors.goldenGlow.withOpacity(0.2),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color: Color(0xFFDDB44A),
                    size: 50,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn()
          : Container(
                  key: const ValueKey('sun'),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(),
    );
  }
}

class _PipOnCloud extends StatelessWidget {
  final bool isNight;
  final bool isMobile;
  const _PipOnCloud({required this.isNight, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final avatarSize = isMobile ? 140.0 : 180.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Cloud beneath pip
        Container(
          width: avatarSize + 60,
          height: 55,
          margin: const EdgeInsets.only(top: 130),
          decoration: BoxDecoration(
            color: isNight
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isNight
                    ? PipColors.lavender.withOpacity(0.3)
                    : PipColors.softPink.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Pip avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isNight
                  ? [PipColors.nightCard, PipColors.nightBg]
                  : [PipColors.softPink, PipColors.cream],
            ),
            border: Border.all(
              color: isNight
                  ? PipColors.goldenGlow.withOpacity(0.5)
                  : PipColors.berryPink.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isNight
                    ? PipColors.goldenGlow.withOpacity(0.25)
                    : PipColors.berryPink.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/pip_avatar_cloud.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _PipPlaceholder(isNight: isNight),
            ),
          ),
        ),
      ],
    );
  }
}

class _PipPlaceholder extends StatelessWidget {
  final bool isNight;
  const _PipPlaceholder({required this.isNight});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isNight ? PipColors.nightCard : PipColors.softPink,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💀', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 4),
            Text(
              'Pip',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isNight ? PipColors.goldenGlow : PipColors.berryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterButton extends StatefulWidget {
  final bool isNight;
  final VoidCallback onPressed;
  const _EnterButton({required this.isNight, required this.onPressed});

  @override
  State<_EnterButton> createState() => _EnterButtonState();
}

class _EnterButtonState extends State<_EnterButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isNight
                    ? [PipColors.goldenGlow, const Color(0xFFFFAA44)]
                    : [PipColors.berryPink, const Color(0xFFD05080)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: widget.isNight
                      ? PipColors.goldenGlow.withOpacity(_hovered ? 0.7 : 0.4)
                      : PipColors.berryPink.withOpacity(_hovered ? 0.7 : 0.4),
                  blurRadius: _hovered ? 28 : 16,
                  spreadRadius: _hovered ? 6 : 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Pip\'s World',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: widget.isNight ? PipColors.nightBg : Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.isNight ? PipColors.nightBg : Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingStarRow extends StatelessWidget {
  final bool isNight;
  const _FloatingStarRow({required this.isNight});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child:
                Icon(
                      i % 2 == 0 ? Icons.star : Icons.star_border,
                      color: isNight
                          ? PipColors.goldenGlow.withOpacity(0.6 - i * 0.08)
                          : PipColors.berryPink.withOpacity(0.5 - i * 0.06),
                      size: 18.0 - i,
                    )
                    .animate(delay: Duration(milliseconds: i * 120))
                    .fadeIn(duration: 600.ms)
                    .moveY(
                      begin: 8,
                      end: -5,
                      duration: 1200.ms,
                      delay: Duration(milliseconds: i * 200),
                      curve: Curves.easeInOut,
                    ),
          ),
      ],
    );
  }
}
