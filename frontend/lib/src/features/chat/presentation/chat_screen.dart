import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import 'chat_controller.dart';
import '../domain/chat_message.dart';
import '../domain/chat_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  // double? _firstUnreadOffset;

  // @override
  // void initState() {
  //   super.initState();
  //   _scrollController.addListener(_onScroll);
  // }

  // @override
  // void dispose() {
  //   _scrollController.removeListener(_onScroll);
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void _onScroll() {
  //   if (_scrollController.hasClients) {
  //     if (_scrollController.position.pixels >=
  //         _scrollController.position.maxScrollExtent - 50) {
  //       setState(() {
  //         _firstUnreadOffset = null;
  //       });
  //     }
  //   }
  // }

  // void _scrollToBottom() {
  //   if (_scrollController.hasClients) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  // void _scrollToOffset(double offset) {
  //   if (_scrollController.hasClients) {
  //     _scrollController.animateTo(
  //       offset,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final messages = chatState.messages;
    final theme = Theme.of(context);

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        // Scroll to bottom when a new message arrives (user or AI)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "AI CONSULTANT",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          _ChatInputSection(),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    if (message.text.trim().isEmpty && !isUser) return const SizedBox.shrink();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.dovere : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(color: AppColors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends ConsumerState<_ChatInputSection> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatControllerProvider.notifier).addUserMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final isWaitingConfirmation = chatState.isWaitingConfirmation;
    final controller = ref.watch(chatControllerProvider.notifier);
    final isListening = controller.isListening;

    if (isWaitingConfirmation) {
      return _buildConfirmationBar();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: isListening
                    ? "Sto ascoltando..."
                    : "Chiedi qualcosa...",
                border: InputBorder.none,
                hintStyle: const TextStyle(color: AppColors.grey),
              ),
              style: const TextStyle(color: AppColors.white),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none_rounded,
              color: isListening ? AppColors.passione : AppColors.white,
              size: 28,
            ),
            onPressed: () async {
              await ref.read(chatControllerProvider.notifier).toggleListening();
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.dovere),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationBar() {
    final chatState = ref.watch(chatControllerProvider);
    final args = chatState.pendingToolArgs;
    final toolName = chatState.pendingToolName;
    final theme = Theme.of(context);

    if (args == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    bool isDelete = toolName == "delete_action";
    String title = isDelete ? "VUOI CANCELLARE?" : "CONFERMA IL TUO IMPEGNO";
    String description = "";

    if (isDelete) {
      description = args['description_query'] ?? 'Attività';
    } else {
      description = args['description'] ?? 'Nuova attività';
    }

    final duration = args['duration_minutes'];
    final dimensionId = args['dimension_id'] ?? 'dovere';
    final List<dynamic>? subTasks = args['sub_tasks'] is List
        ? args['sub_tasks']
        : null;

    IconData icon;
    Color color;

    if (isDelete) {
      icon = Icons.delete_forever_rounded;
      color = Colors.redAccent;
    } else {
      switch (dimensionId.toString().toLowerCase()) {
        case 'passione':
          icon = FontAwesomeIcons.guitar;
          color = AppColors.passione;
          break;
        case 'energia':
          icon = FontAwesomeIcons.bolt;
          color = AppColors.energia;
          break;
        case 'relazioni':
          icon = FontAwesomeIcons.peopleGroup;
          color = AppColors.relazioni;
          break;
        case 'anima':
          icon = FontAwesomeIcons.heart;
          color = AppColors.anima;
          break;
        case 'dovere':
        default:
          icon = FontAwesomeIcons.briefcase;
          color = AppColors.dovere;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: isDelete ? Colors.redAccent : AppColors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description.toString().toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isDelete)
                        Row(
                          children: [
                            if (duration != null) ...[
                              const Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$duration min",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dimensionId.toString().toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      if (subTasks != null && subTasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...subTasks.map(
                          (st) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 14,
                                  color: color.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    st['title']?.toString() ?? "",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (isDelete)
                        Text(
                          "Questa azione verrà rimossa definitivamente.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => ref
                      .read(chatControllerProvider.notifier)
                      .confirmAction(false),
                  child: Text(
                    isDelete ? "Annulla" : "Modifica",
                    style: const TextStyle(color: AppColors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => ref
                      .read(chatControllerProvider.notifier)
                      .confirmAction(true),
                  child: Text(
                    isDelete ? "Elimina Ora" : "Conferma",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
