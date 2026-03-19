import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/feed_post_model.dart';
import '../services/feed_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FeedService _feedService = FeedService();
  final TextEditingController _composerController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<FeedPost> _posts = [];
  bool _loading = true;
  bool _posting = false;
  XFile? _selectedMedia;
  String _selectedMediaType = 'none'; // none | image | video

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

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

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    setState(() {
      _selectedMedia = file;
      _selectedMediaType = 'image';
    });
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _selectedMedia = file;
      _selectedMediaType = 'video';
    });
  }

  Future<void> _createPost() async {
    if (_posting) return;
    final text = _composerController.text.trim();
    if (text.isEmpty && _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something or add media')),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      String? mediaUrl;
      if (_selectedMedia != null) {
        mediaUrl = await _feedService.uploadMedia(_selectedMedia!);
      }

      await _feedService.createPost(
        content: text,
        mediaUrl: mediaUrl,
        mediaType: _selectedMedia == null ? 'none' : _selectedMediaType,
      );

      _composerController.clear();
      setState(() {
        _selectedMedia = null;
        _selectedMediaType = 'none';
      });
      await _loadFeed();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: const Color(0xFF0C0C79),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFeed,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildComposer(),
              const SizedBox(height: 10),
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
                  child: const Text('No posts yet. Be the first to post!'),
                )
              else
                ..._posts.map(_buildPostCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _composerController,
              maxLines: null,
              minLines: 2,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
              ),
            ),
            if (_selectedMedia != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMediaType == 'image' ? Icons.image : Icons.videocam,
                      color: const Color(0xFF0C0C79),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedMedia!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedMedia = null;
                          _selectedMediaType = 'none';
                        });
                      },
                    ),
                  ],
                ),
              ),
            const Divider(height: 18),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Photo'),
                ),
                TextButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Video'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _posting ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C0C79),
                    foregroundColor: Colors.white,
                  ),
                  child: _posting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    final first = post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.2,
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
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline, size: 50),
                          SizedBox(height: 8),
                          Text('Tap to open video'),
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
