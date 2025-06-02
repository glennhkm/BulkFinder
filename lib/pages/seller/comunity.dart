import 'package:flutter/material.dart';
import 'package:bulk_finder/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bulk_finder/services/store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bulk_finder/providers/auth_providers.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Tips Belanja',
    'Wadah Bekas',
    'Diskusi Harga',
    'Review Toko',
    'Event',
    'Lainnya'
  ];

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await CommunityService().getPosts();
      print('Fetched posts: $posts');
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter posts by selected category
    final filteredPosts = _selectedCategory == 'Semua'
        ? _posts
        : _posts.where((post) => post['category'] == _selectedCategory).toList();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Title and Create Post Button (Bulk Buddy left, Buat Post right, stacked vertically)
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.brand_01, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bulk Buddy',
                            style: GoogleFonts.poppins(
                              color: AppTheme.brand_01,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreatePostDialog(context),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Buat Post',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brand_01,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari topik atau kata kunci...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            category,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: AppTheme.brand_01,
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Posts List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPosts.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada postingan komunitas',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];
                          return _buildPostCard(post);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    // Format waktu
    String timeAgo = '';
    if (post['created_at'] != null) {
      final created = DateTime.tryParse(post['created_at']);
      if (created != null) {
        final diff = DateTime.now().difference(created);
        if (diff.inMinutes < 1) {
          timeAgo = 'Baru saja';
        } else if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes} menit yang lalu';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours} jam yang lalu';
        } else {
          timeAgo = '${diff.inDays} hari yang lalu';
        }
      }
    }
    // Tag handling
    List<String> tags = [];
    if (post['tags'] is List) {
      tags = List<String>.from(post['tags']);
    } else if (post['tags'] is String) {
      tags = [post['tags']];
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.forum, color: AppTheme.brand_01),
                const SizedBox(width: 8),
                Text(
                  post['category'] ?? '-',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.brand_01,
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post['content'] ?? '',
              style: GoogleFonts.poppins(fontSize: 15),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tags.map((tag) => _buildTagChip(tag)).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                // Like button with count
                FutureBuilder<bool>(
                  future: userId != null ? CommunityService().isPostLiked(userId, post['id']) : Future.value(false),
                  builder: (context, snapshotLike) {
                    final isLiked = snapshotLike.data ?? false;
                    return FutureBuilder<int>(
                      future: CommunityService().getPostLikesCount(post['id']),
                      builder: (context, snapshotCount) {
                        final likeCount = snapshotCount.data ?? 0;
                        return Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                color: isLiked ? AppTheme.brand_01 : Colors.grey,
                              ),
                              onPressed: userId == null
                                  ? null
                                  : () async {
                                      if (isLiked) {
                                        await CommunityService().unlikePost(userId, post['id']);
                                      } else {
                                        await CommunityService().likePost(userId, post['id']);
                                      }
                                      setState(() {});
                                    },
                            ),
                            Text('$likeCount'),
                          ],
                        );
                      },
                    );
                  },
                ),
                // Comment button with count
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: CommunityService().getComments(post['id']),
                  builder: (context, snapshotComments) {
                    final commentCount = snapshotComments.data?.length ?? 0;
                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline),
                          onPressed: () => _showCommentsDialog(post['id']),
                        ),
                        Text('$commentCount'),
                      ],
                    );
                  },
                ),
                // Save button
                FutureBuilder<bool>(
                  future: userId != null ? CommunityService().isPostSaved(userId, post['id']) : Future.value(false),
                  builder: (context, snapshotSaved) {
                    final isSaved = snapshotSaved.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? AppTheme.brand_01 : Colors.grey,
                      ),
                      onPressed: userId == null
                          ? null
                          : () async {
                              if (isSaved) {
                                await CommunityService().unsavePost(userId, post['id']);
                              } else {
                                await CommunityService().savePost(userId, post['id']);
                              }
                              setState(() {});
                            },
                    );
                  },
                ),
                // Report button
                IconButton(
                  icon: Icon(Icons.flag_outlined, color: Colors.red[300]),
                  onPressed: () => _showReportDialog(post['id']),
                  tooltip: 'Laporkan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.brand_01.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppTheme.brand_01,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '#$tag',
        style: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? count,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionChip({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();
    String selectedCategory = 'Lainnya';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.post_add, color: AppTheme.brand_01),
              const SizedBox(width: 8),
              const Text('Buat Post Baru'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .where((category) => category != 'Semua')
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Konten',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Apa yang ingin kamu bagikan?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tag (pisahkan dengan koma)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: wadah, kaca, bumbu',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  // Ambil userId dari auth (atau provider)
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  final tags = tagsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  try {
                    await CommunityService().addPost(
                      userId: userId!,
                      category: selectedCategory,
                      content: contentController.text,
                      tags: tags,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post berhasil dibuat'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _fetchPosts(); // Refresh list
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membuat post: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brand_01,
              ),
              child: const Text('Posting', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsDialog(String postId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    List<Map<String, dynamic>> comments = await CommunityService().getComments(postId);
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController commentController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: AppTheme.brand_01),
                const SizedBox(width: 8),
                Text('Komentar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: comments.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada komentar. Jadilah yang pertama! 😊',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: comments.length,
                            separatorBuilder: (context, idx) => Divider(height: 16),
                            itemBuilder: (context, idx) {
                              final c = comments[idx];
                              final created = DateTime.tryParse(c['created_at'] ?? '') ?? DateTime.now();
                              String timeAgo = '';
                              final diff = DateTime.now().difference(created);
                              if (diff.inMinutes < 1) {
                                timeAgo = 'Baru saja';
                              } else if (diff.inMinutes < 60) {
                                timeAgo = '${diff.inMinutes} menit yang lalu';
                              } else if (diff.inHours < 24) {
                                timeAgo = '${diff.inHours} jam yang lalu';
                              } else {
                                timeAgo = '${diff.inDays} hari yang lalu';
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.brand_01.withOpacity(0.2),
                                    child: Text(
                                      (c['user_id'] ?? '?').toString().substring(0, 1).toUpperCase(),
                                      style: GoogleFonts.poppins(color: AppTheme.brand_01, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Pengguna', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                            const SizedBox(width: 8),
                                            Text(timeAgo, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(c['comment_text'] ?? '', style: GoogleFonts.poppins(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tulis komentar...'
                                ,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (userId != null && commentController.text.trim().isNotEmpty) {
                            await CommunityService().addComment(userId, postId, commentController.text.trim());
                            commentController.clear();
                            comments = await CommunityService().getComments(postId);
                            setStateDialog(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brand_01,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(String postId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Laporkan Postingan'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(hintText: 'Alasan laporan'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null && reasonController.text.isNotEmpty) {
                await CommunityService().reportPost(userId, postId, reasonController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post berhasil dilaporkan')),
                );
              }
            },
            child: Text('Laporkan'),
          ),
        ],
      ),
    );
  }

  void _savePost(String postId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await CommunityService().savePost(userId, postId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post berhasil disimpan')),
      );
    }
  }
}