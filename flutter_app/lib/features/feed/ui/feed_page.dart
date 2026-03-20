import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../models/feed_post_model.dart';
import '../services/feed_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FeedService _feedService = FeedService();
  final ImagePicker _picker = ImagePicker();
  List<FeedPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() => super.dispose();

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    try {
      final posts = await _feedService.getFeedPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load feed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreatePostSheet() async {
    final textController = TextEditingController();
    XFile? selectedMedia;
    String selectedMediaType = 'none';
    bool posting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final l10n = AppLocalizations.of(context)!;
            Future<void> pickImage() async {
              final file = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (file == null) return;
              setSheetState(() {
                selectedMedia = file;
                selectedMediaType = 'image';
              });
            }

            Future<void> pickVideo() async {
              final file = await _picker.pickVideo(source: ImageSource.gallery);
              if (file == null) return;
              setSheetState(() {
                selectedMedia = file;
                selectedMediaType = 'video';
              });
            }

            Future<void> submitPost() async {
              if (posting) return;
              final text = textController.text.trim();
              bool sheetClosed = false;
              if (text.isEmpty && selectedMedia == null) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(content: Text('Write something or add media')),
                );
                return;
              }

              setSheetState(() => posting = true);
              try {
                String? mediaUrl;
                if (selectedMedia != null) {
                  mediaUrl = await _feedService.uploadMedia(selectedMedia!);
                }

                await _feedService.createPost(
                  content: text,
                  mediaUrl: mediaUrl,
                  mediaType: selectedMedia == null ? 'none' : selectedMediaType,
                );

                if (!mounted) return;
                sheetClosed = true;
                Navigator.pop(sheetContext);
                await _loadFeed();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(content: Text('Failed to create post: $e')),
                );
              } finally {
                if (mounted && !sheetClosed) {
                  setSheetState(() => posting = false);
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.createPost,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: l10n.whatsOnYourMind,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (selectedMedia != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedMediaType == 'image'
                                ? Icons.image_outlined
                                : Icons.videocam_outlined,
                            color: const Color(0xFF0C0C79),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedMedia!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setSheetState(() {
                                selectedMedia = null;
                                selectedMediaType = 'none';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l10n.photo),
                      ),
                      TextButton.icon(
                        onPressed: pickVideo,
                        icon: const Icon(Icons.videocam_outlined),
                        label: Text(l10n.video),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: posting ? null : submitPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C0C79),
                          foregroundColor: Colors.white,
                        ),
                        child: posting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.post),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    textController.dispose();
  }

  Future<void> _toggleLike(FeedPost post) async {
    try {
      await _feedService.toggleLike(post.id);
      await _loadFeed();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post: $e')),
      );
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feed),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFeed,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_posts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Text('${l10n.noPostsYet} ${l10n.beFirstToPost}'),
                )
              else
                ..._posts.map(_buildPostCard),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.small(
          onPressed: _openCreatePostSheet,
          backgroundColor: const Color(0xFF0C0C79),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    final l10n = AppLocalizations.of(context)!;
    final first = post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0C0C79),
                  backgroundImage:
                      post.userAvatarUrl != null ? NetworkImage(post.userAvatarUrl!) : null,
                  child: post.userAvatarUrl == null
                      ? Text(first, style: const TextStyle(color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(post.content),
            ],
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              if (post.mediaType == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
                )
              else
                InkWell(
                  onTap: () async {
                    final uri = Uri.tryParse(post.mediaUrl!);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_outline, size: 50),
                          const SizedBox(height: 8),
                          Text(l10n.tapToOpenVideo),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _toggleLike(post),
                  icon: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByMe ? Colors.red : null,
                  ),
                  label: Text('${post.likesCount}'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text('${post.commentsCount}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
