import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../utils/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Coleções
  final String _chatsCollection = 'chats';
  final String _messagesCollection = 'messages';
  final String _usersCollection = 'users';

  // Stream de mensagens de um chat específico
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream de chats do usuário
  Stream<QuerySnapshot> getChats() {
    return _firestore
        .collection(_chatsCollection)
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // Buscar usuários para iniciar chat
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final usersSnapshot = await _firestore
          .collection(_usersCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return usersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'photoUrl': doc['photoUrl'],
                'userType': doc['userType'],
              })
          .where((user) => user['id'] != currentUserId)
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // Verificar se já existe um chat com o usuário
  Future<String?> getExistingChatId(String otherUserId) async {
    try {
      final chatsSnapshot = await _firestore
          .collection(_chatsCollection)
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in chatsSnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao verificar chat existente: $e');
    }
  }

  // Enviar mensagem
  Future<void> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    final messageData = {
      'senderId': currentUserId,
      'message': message,
      'timestamp': timestamp,
    };

    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .add(messageData);

    // Atualiza o último timestamp da conversa
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'lastMessage': message,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
    });
  }

  // Criar novo chat
  Future<String> createChat(String otherUserId) async {
    final chatId = _firestore.collection(_chatsCollection).doc().id;
    await _firestore.collection(_chatsCollection).doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': '',
    });
    return chatId;
  }

  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String chatId) async {
    final batch = _firestore.batch();
    final messages = await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Deletar chat
  Future<void> deleteChat(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Verificar se o usuário é participante do chat
    final chat = await _firestore.collection(_chatsCollection).doc(chatId).get();
    if (!chat.exists) throw Exception('Chat não encontrado');

    final participants = List<String>.from(chat['participants']);
    if (!participants.contains(userId)) {
      throw Exception('Usuário não autorizado a deletar este chat');
    }

    // Deletar todas as mensagens
    final messages = await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // Deletar o chat
    batch.delete(_firestore.collection(_chatsCollection).doc(chatId));

    await batch.commit();
  }
}

class Chat {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
} 