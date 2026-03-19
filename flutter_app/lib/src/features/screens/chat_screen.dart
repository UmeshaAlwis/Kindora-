import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kindora/src/features/messaging/providers/messaging.provider.dart' show messagesProvider;
import '../../core/theme/app_theme.dart';
import '../../features/messaging/models/message_model.dart';
// ignore: unused_import
import '../../features/messaging/providers/messages_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  late AnimationController _sendButtonController;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _inputController.addListener(() {
      final newHasText = _inputController.text.trim().isNotEmpty;
      if (newHasText != _hasText) {
        setState(() => _hasText = newHasText);
        if (newHasText) {
          _sendButtonController.forward();
        } else {
          _sendButtonController.reverse();
        }
      }
    });

    //Scroll to bottom after frame

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await ref
        .read(messagesProvider(widget.conversation.id).notifier)
        .sendMessage(widget.conversation.id, text);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom(animated: true));
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversation.id));

    return Scaffold(
      backgroundColor: KindoraColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (widget.conversation.campaignTitle != null)
            _buildCampaignBanner(),
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyChat()
                : _buildMessagesList(messages),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: KindoraColors.surface,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 40,
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: KindoraColors.primaryLight,
                child: Text(
                  widget.conversation.participantName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),

              if (widget.conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: KindoraColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.participantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: KindoraColors.textPrimary,
                  ),
                ),

                Text(
                  widget.conversation.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.conversation.isOnline
                        ? KindoraColors.online
                        : KindoraColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined,
              color: KindoraColors.primary, size: 22),
          onPressed: () {},
          tooltip: 'Call',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: KindoraColors.textSecondary, size: 22),
          onPressed: () => _showOptions(),
          tooltip: 'More',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: KindoraColors.border),
      ),
    );
  }

  Widget _buildCampaignBanner() {
    return Container(
      color: KindoraColors.primarySurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded,
              color: KindoraColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.conversation.campaignTitle!,
              style: const TextStyle(
                color: KindoraColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            child: const Text('View',
                style: TextStyle(
                    fontSize: 12,
                    color: KindoraColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final prev = index > 0 ? messages[index - 1] : null;
        final next =
            index < messages.length - 1 ? messages[index + 1] : null;

        final showDateDivider = prev == null ||
            !_isSameDay(prev.timestamp, msg.timestamp);
        final isFirst = prev == null ||
            prev.senderId != msg.senderId ||
            !_isSameDay(prev.timestamp, msg.timestamp);
        final isLast = next == null ||
            next.senderId != msg.senderId ||
            !_isSameDay(next.timestamp, msg.timestamp);

         return Column(
          children: [
            if (showDateDivider) _buildDateDivider(msg.timestamp),
            _MessageBubble(
              message: msg,
              isFirst: isFirst,
              isLast: isLast,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime dt) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(dt, now)) {
      label = 'Today';
    } else if (_isSameDay(
        dt, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMMM d, y').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: KindoraColors.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: KindoraColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
              child: Divider(color: KindoraColors.border, height: 1)),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: KindoraColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand_rounded,
                size: 36, color: KindoraColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Say hello to ${widget.conversation.participantName}!',
            style: const TextStyle(
              color: KindoraColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your messages are private and secure.',
            style: TextStyle(
                color: KindoraColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: KindoraColors.surface,
        border: Border(top: BorderSide(color: KindoraColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          _buildIconBtn(
            icon: Icons.attach_file_rounded,
            onTap: () {},
            tooltip: 'Attach file',
          ),
          const SizedBox(width: 6),
          // Text field
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    color: KindoraColors.textPrimary, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(
                      color: KindoraColors.textHint, fontSize: 14),
                  filled: true,
                  fillColor: KindoraColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Send / Emoji toggle
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _hasText
                ? _buildSendButton()
                : _buildIconBtn(
                    key: const ValueKey('emoji'),
                    icon: Icons.emoji_emotions_outlined,
                    onTap: () {},
                    tooltip: 'Emoji',
                  ),
          ),
        ],
      ),
    );  
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _sendMessage,
      child: Container(
        key: const ValueKey('send'),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: KindoraColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KindoraColors.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildIconBtn({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: KindoraColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: KindoraColors.textSecondary, size: 20),
        ),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: KindoraColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _OptionTile(
                icon: Icons.info_outline_rounded,
                label: 'Charity Info',
                onTap: () => Navigator.pop(context)),
            _OptionTile(
                icon: Icons.campaign_outlined,
                label: 'View Campaign',
                onTap: () => Navigator.pop(context)),
            _OptionTile(
                icon: Icons.block_rounded,
                label: 'Block',
                onTap: () => Navigator.pop(context),
                isDestructive: true),
            _OptionTile(
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () => Navigator.pop(context),
                isDestructive: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

   bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

//---------------------------------------------------------------------------
//Message Bubble
//---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isFirst;
  final bool isLast;
 
  const _MessageBubble({
    required this.message,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;
 
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe || !isFirst ? 18 : 4),
      topRight: Radius.circular(!isMe || !isFirst ? 18 : 4),
      bottomLeft: Radius.circular(isMe || !isLast ? 18 : 4),
      bottomRight: Radius.circular(!isMe || !isLast ? 18 : 4),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 6 : 2,
        bottom: isLast ? 2 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && isLast)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: KindoraColors.primaryLight,
                child: Text(
                  'H',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            )
          else if (!isMe)
            const SizedBox(width: 30),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? KindoraColors.bubbleMe
                        : KindoraColors.bubbleThem,
                    borderRadius: bubbleRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                   child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe
                          ? KindoraColors.bubbleMeText
                          : KindoraColors.bubbleThemText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                   ),
                  ),
              ),
               if (isLast) ...[
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: const TextStyle(
                        color: KindoraColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 3),
                      _buildStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: KindoraColors.textHint,
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded,
            size: 13, color: KindoraColors.textHint);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded,
            size: 13, color: KindoraColors.textHint);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 13, color: KindoraColors.primaryLight);
    }
  }
}

// ---------------------------------------------------------------------------
// Option Tile (bottom sheet)
// ---------------------------------------------------------------------------
 
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
 
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
 
  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? Colors.red.shade600 : KindoraColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color, fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }
}

