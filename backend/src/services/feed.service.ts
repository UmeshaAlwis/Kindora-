import { SupabaseClient } from './supabase.service';

type MediaType = 'none' | 'image' | 'video';

export class FeedService {
  static async getFeedPosts(page: number = 1, limit: number = 20, currentUserId?: string) {
    const supabase = new SupabaseClient();
    const offset = (page - 1) * limit;

    const posts = await supabase.select<any>('feed_posts', {
      select: 'id,user_id,content,media_url,media_type,likes_count,comments_count,created_at,updated_at',
      orderBy: { column: 'created_at', ascending: false },
      limit,
      offset,
    });

    const mapped = await Promise.all(
      posts.map(async (post: any) => {
        const users = await supabase.select<any>('users', {
          select: 'id,full_name,email,profile_picture_url',
          filters: { id: post.user_id },
          limit: 1,
        });
        const user = users[0] || {};

        let likedByMe = false;
        if (currentUserId) {
          const likes = await supabase.select<any>('feed_post_likes', {
            select: 'id',
            filters: { post_id: post.id, user_id: currentUserId },
            limit: 1,
          });
          likedByMe = likes.length > 0;
        }

        return {
          id: post.id,
          user_id: post.user_id,
          user_name: user.full_name || user.email || 'User',
          user_avatar_url: user.profile_picture_url || null,
          content: post.content || '',
          media_url: post.media_url || null,
          media_type: (post.media_type || 'none') as MediaType,
          likes_count: Number(post.likes_count || 0),
          comments_count: Number(post.comments_count || 0),
          liked_by_me: likedByMe,
          created_at: post.created_at,
          updated_at: post.updated_at,
        };
      })
    );

    return {
      posts: mapped,
      total: mapped.length,
      page,
      limit,
      pages: Math.ceil(mapped.length / limit),
    };
  }

  static async createFeedPost(
    userId: string,
    data: { content: string; media_url?: string; media_type?: MediaType }
  ) {
    const supabase = new SupabaseClient();

    const created = await supabase.insert<any>('feed_posts', {
      user_id: userId,
      content: data.content?.trim() || '',
      media_url: data.media_url || null,
      media_type: data.media_type || 'none',
      likes_count: 0,
      comments_count: 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });

    return created;
  }

  static async toggleLike(postId: string, userId: string) {
    const supabase = new SupabaseClient();

    const existing = await supabase.select<any>('feed_post_likes', {
      select: 'id',
      filters: { post_id: postId, user_id: userId },
      limit: 1,
    });

    const posts = await supabase.select<any>('feed_posts', {
      select: 'id,likes_count',
      filters: { id: postId },
      limit: 1,
    });

    if (!posts[0]) {
      throw new Error('Post not found');
    }

    const currentLikes = Number(posts[0].likes_count || 0);

    if (existing.length > 0) {
      await supabase.delete('feed_post_likes', { id: existing[0].id });
      await supabase.update<any>(
        'feed_posts',
        {
          likes_count: Math.max(0, currentLikes - 1),
          updated_at: new Date().toISOString(),
        },
        { id: postId }
      );
      return { liked: false, likes_count: Math.max(0, currentLikes - 1) };
    }

    await supabase.insert<any>('feed_post_likes', {
      post_id: postId,
      user_id: userId,
      created_at: new Date().toISOString(),
    });
    await supabase.update<any>(
      'feed_posts',
      {
        likes_count: currentLikes + 1,
        updated_at: new Date().toISOString(),
      },
      { id: postId }
    );

    return { liked: true, likes_count: currentLikes + 1 };
  }
}
