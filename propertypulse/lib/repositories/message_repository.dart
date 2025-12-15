import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get conversation
  Future<String> getOrCreateConversation(
    String propertyId,
    String buyerId,
    String sellerId,
  ) async {
    try {
      // Check if conversation exists
      final existing = await _firestore
          .collection('conversations')
          .where('propertyId', isEqualTo: propertyId)
          .where('buyerId', isEqualTo: buyerId)
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create new conversation
      final conversationId = _firestore.collection('conversations').doc().id;
      final conversation = ConversationModel(
        id: conversationId,
        propertyId: propertyId,
        buyerId: buyerId,
        sellerId: sellerId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toMap());

      return conversationId;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update conversation
      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'unreadCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get conversations for a user
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('buyerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get seller conversations
  Stream<List<ConversationModel>> getSellerConversations(String sellerId) {
    return _firestore
        .collection('conversations')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      final messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }
}

