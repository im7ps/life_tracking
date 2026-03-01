import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/chat_message.dart';
import '../domain/chat_state.dart';
import '../data/speech_to_text_provider.dart';
import '../data/permission_provider.dart';
import '../data/chat_repository.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../action/presentation/action_providers.dart';
import 'package:uuid/uuid.dart';

part 'chat_controller.g.dart';

@riverpod
class ChatController extends _$ChatController {
  SpeechToText get _speech => ref.read(speechToTextProvider);
  
  @override
  ChatState build() {
    // Generate a fresh session ID for every controller build (new chat session)
    return ChatState(sessionId: const Uuid().v4());
  }

  bool _isListening = false;
  bool get isListening => _isListening;

  static const _confirmTag = "||INTERRUPT||";

  Future<bool> toggleListening() async {
    final hasPermission = await ref.read(permissionServiceProvider).requestMicrophonePermission();
    if (!hasPermission) return false;

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      state = state; 
      return false;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          state = state; 
        }
      },
      onError: (errorNotification) {
        _isListening = false;
        state = state;
      },
    );

    if (available) {
      _isListening = true;
      state = state;
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            addUserMessage(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10), // Più tempo per pensare/parlare
        listenMode: ListenMode.dictation,
      );
    }
    return available;
  }

  void addUserMessage(String text) {
    if (text.isEmpty) return;
    
    final message = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, message],
    );
    
    _startAIStreaming(text);
  }

  Future<void> _startAIStreaming(String userText) async {
    final repository = ref.read(chatRepositoryProvider);
    
    final responseId = const Uuid().v4();
    final initialResponse = ChatMessage(
      id: responseId,
      text: "",
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, initialResponse],
    );

    StringBuffer fullText = StringBuffer();
    
    try {
      await for (final chunk in repository.streamChat(userText, state.sessionId)) {
        fullText.write(chunk);

        String displayText = fullText.toString();
        bool waiting = false;
        Map<String, dynamic>? toolArgs;
        String? toolName;

        if (displayText.contains(_confirmTag)) {
          waiting = true;
          final parts = displayText.split(_confirmTag);
          if (parts.length > 1) {
            final confirmContent = parts[1];
            final confirmParts = confirmContent.split("||");
            // Format: tool_name||json_args
            if (confirmParts.length >= 2) {
              toolName = confirmParts[0];
              try {
                toolArgs = jsonDecode(confirmParts[1]) as Map<String, dynamic>;
              } catch (e) {
                print("Error decoding tool args: $e");
              }
            }
          }
          displayText = parts[0].trim();
        }

        state = state.copyWith(
          isWaitingConfirmation: waiting,
          pendingToolName: toolName,
          pendingToolArgs: toolArgs,
          messages: [
            for (final msg in state.messages)
              if (msg.id == responseId)
                msg.copyWith(text: displayText)
              else
                msg
          ],
        );
      }
      
      ref.read(taskListProvider.notifier).syncWithBackend();
      ref.invalidate(portfolioProvider);
      
    } catch (e) {
      state = state.copyWith(
        messages: [
          for (final msg in state.messages)
            if (msg.id == responseId)
              msg.copyWith(text: "Errore nella comunicazione con l'AI: $e")
            else
              msg
        ],
      );
    }
  }

  Future<void> confirmAction(bool confirmed) async {
    state = state.copyWith(
      isWaitingConfirmation: false,
      pendingToolName: null,
      pendingToolArgs: null,
    );

    final repository = ref.read(chatRepositoryProvider);
    final responseId = const Uuid().v4();

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: responseId,
          text: "",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );

    final fullText = StringBuffer();

    try {
      await for (final chunk in repository.confirmTool(confirmed, state.sessionId)) {
        fullText.write(chunk);
        
        String displayText = fullText.toString();
        bool waiting = false;
        Map<String, dynamic>? toolArgs;
        String? toolName;

        if (displayText.contains(_confirmTag)) {
          waiting = true;
          final parts = displayText.split(_confirmTag);
          if (parts.length > 1) {
            final confirmContent = parts[1];
            final confirmParts = confirmContent.split("||");
            if (confirmParts.length >= 2) {
              toolName = confirmParts[0];
              try {
                toolArgs = jsonDecode(confirmParts[1]) as Map<String, dynamic>;
              } catch (e) {
                print("Error decoding tool args in resume: $e");
              }
            }
          }
          displayText = parts[0].trim();
        }

        state = state.copyWith(
          isWaitingConfirmation: waiting,
          pendingToolName: toolName,
          pendingToolArgs: toolArgs,
          messages: [
            for (final msg in state.messages)
              if (msg.id == responseId)
                msg.copyWith(text: displayText)
              else
                msg
          ],
        );
      }
      
      ref.read(taskListProvider.notifier).syncWithBackend();
      ref.invalidate(portfolioProvider);
      
    } catch (e) {
      state = state.copyWith(
        messages: [
          for (final msg in state.messages)
            if (msg.id == responseId)
              msg.copyWith(text: "Errore nella comunicazione con l'AI: $e")
            else
              msg
        ],
      );
    }
  }
}
