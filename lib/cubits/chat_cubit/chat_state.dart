part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState
{
  final List<MessageModel> messages;
  ChatLoadedState(this.messages);
}

class ChatErrorState extends ChatState
{
  final String error;
  ChatErrorState({required this.error});
}

class ChatSendingState extends ChatState {}

class ChatSentState extends ChatState {}
