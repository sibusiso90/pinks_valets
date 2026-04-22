import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/pinks_logo.dart';
import '../../../shared/widgets/tab_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messages = <_Msg>[
    const _Msg(
      mine: false,
      text: "Hi Thandi! How can we help today?",
      time: '10:12',
    ),
  ];
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    Haptics.light();
    setState(() {
      _messages.add(_Msg(mine: true, text: t, time: _stampNow()));
      _input.clear();
    });
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          mine: false,
          text: 'Got it — our team will get back to you shortly.',
          time: _stampNow(),
        ));
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: AppMotion.medium,
        curve: AppMotion.standard,
      );
    });
  }

  String _stampNow() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          _ChatHeader(
            onCall: () {
              Haptics.selection();
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                20,
                AppSpacing.screenH,
                16,
              ),
              itemCount: _messages.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppText.sans(
                            10,
                            color: AppColors.ink3,
                            weight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return _MsgBubble(msg: _messages[i - 1]);
              },
            ),
          ),
          _ChatInput(
            controller: _input,
            onSend: _send,
          ),
        ],
      ),
      bottom: AppBottomNav(
        active: 'chat',
        onTap: (id) {
          switch (id) {
            case 'home':
              context.go('/home');
            case 'bookings':
              context.go('/my-bookings');
            case 'chat':
              break;
            case 'profile':
              context.go('/profile');
          }
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onCall});
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.hair, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
              boxShadow: AppShadow.sm,
            ),
            alignment: Alignment.center,
            child: PinksLogo(
              height: 18,
              color: AppColors.bg,
              showTagline: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pink's Support",
                  style: AppText.sans(15, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active now',
                      style: AppText.sans(11, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surfaceAlt,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onCall,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hair, width: 1)),
        boxShadow: AppShadow.bar,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.add_rounded, color: AppColors.ink, size: 22),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: AppColors.ink,
                cursorWidth: 1.6,
                style: AppText.sans(
                  15,
                  color: AppColors.ink,
                  letterSpacing: -0.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: AppText.sans(
                    15,
                    color: AppColors.ink3,
                    letterSpacing: -0.2,
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.ink,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onSend,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: AppColors.bg,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  const _Msg({
    required this.mine,
    required this.text,
    required this.time,
  });
  final bool mine;
  final String text;
  final String time;
}

class _MsgBubble extends StatelessWidget {
  const _MsgBubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final mine = msg.mine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.76,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: mine ? AppColors.ink : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(mine ? 18 : 4),
                bottomRight: Radius.circular(mine ? 4 : 18),
              ),
              border: mine
                  ? null
                  : Border.all(color: AppColors.hair, width: 1),
              boxShadow: mine ? null : AppShadow.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: AppText.sans(
                    14,
                    color: mine ? AppColors.bg : AppColors.ink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: AppText.sans(
                    10,
                    color: mine
                        ? AppColors.bg.withValues(alpha: 0.5)
                        : AppColors.ink3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
