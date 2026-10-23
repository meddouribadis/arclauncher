/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flauncher/providers/unsplash_slideshow.dart'
    show pruneCache, newestCachedImage, slideshowMaxCachedFiles;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RedditWallpaper {
  final String id;
  final String title;
  final String author;
  final String subreddit;
  final String imageUrl;
  final String permalink;
  final int? width;
  final int? height;

  const RedditWallpaper({
    required this.id,
    required this.title,
    required this.author,
    required this.subreddit,
    required this.imageUrl,
    required this.permalink,
    this.width,
    this.height,
  });

  String get credit => "r/$subreddit • u/$author";

  static RedditWallpaper? fromJson(Map<String, dynamic> data) {
    if (data['over_18'] == true) return null;
    if (data['stickied'] == true) return null;
    if (data['is_video'] == true) return null;
    if (data['is_self'] == true) return null;

    final id = data['id'] as String?;
    final title = data['title'] as String? ?? '';
    final author = data['author'] as String? ?? '';
    final subreddit = data['subreddit'] as String? ?? '';
    final permalink = data['permalink'] as String? ?? '';
    if (id == null || id.isEmpty) return null;

    int? width;
    int? height;
    String? previewUrl;

    if (data['preview'] is Map && data['preview']['images'] is List) {
      final images = data['preview']['images'] as List;
      if (images.isNotEmpty && images.first is Map && images.first['source'] is Map) {
        final source = images.first['source'] as Map;
        width = source['width'] as int?;
        height = source['height'] as int?;
        previewUrl = (source['url'] as String?)?.replaceAll('&amp;', '&');
      }
    }

    // Prefer landscape images for TV screens
    if (width != null && height != null && width < height) {
      return null;
    }

    String? imageUrl;
    final directUrl = (data['url_overridden_by_dest'] ?? data['url']) as String?;
    if (directUrl != null && _isDirectImageUrl(directUrl)) {
      imageUrl = directUrl;
    } else if (previewUrl != null && previewUrl.isNotEmpty) {
      imageUrl = previewUrl;
    } else if (data['is_gallery'] == true && data['media_metadata'] is Map) {
      final meta = data['media_metadata'] as Map<String, dynamic>;
      for (final entry in meta.values) {
        if (entry is Map && entry['s'] is Map) {
          final s = entry['s'] as Map;
          final gWidth = s['x'] as int?;
          final gHeight = s['y'] as int?;
          final gUrl = (s['u'] as String?)?.replaceAll('&amp;', '&');
          if (gUrl != null && (gWidth == null || gHeight == null || gWidth >= gHeight)) {
            imageUrl = gUrl;
            width = gWidth;
            height = gHeight;
            break;
          }
        }
      }
    }

    if (imageUrl == null || imageUrl.isEmpty) return null;

    return RedditWallpaper(
      id: id,
      title: title.trim(),
      author: author.trim(),
      subreddit: subreddit.trim(),
      imageUrl: imageUrl,
      permalink: permalink.startsWith('http') ? permalink : 'https://reddit.com$permalink',
      width: width,
      height: height,
    );
  }

  static bool _isDirectImageUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp')) {
      return true;
    }
    final uri = Uri.tryParse(url);
    if (uri != null &&
        (uri.host == 'i.redd.it' ||
            uri.host == 'i.imgur.com' ||
            uri.host == 'preview.redd.it' ||
            uri.host.endsWith('.test'))) {
      return true;
    }
    return false;
  }
}

class RedditSubredditSource {
  final String name;
  final String displayName;
  final String description;
  final IconData icon;

  const RedditSubredditSource({
    required this.name,
    required this.displayName,
    required this.description,
    required this.icon,
  });
}

const List<RedditSubredditSource> popularSubreddits = [
  RedditSubredditSource(
    name: 'wallpapers',
    displayName: 'r/wallpapers',
    description: 'High quality wallpapers for desktops and TVs',
    icon: Icons.wallpaper,
  ),
  RedditSubredditSource(
    name: 'wallpaper',
    displayName: 'r/wallpaper',
    description: 'General wallpaper community',
    icon: Icons.image_outlined,
  ),
  RedditSubredditSource(
    name: 'EarthPorn',
    displayName: 'r/EarthPorn',
    description: 'Natural scenery and landscape photography',
    icon: Icons.landscape_outlined,
  ),
  RedditSubredditSource(
    name: 'spaceporn',
    displayName: 'r/spaceporn',
    description: 'Astrophotography, nebulas, galaxies and planets',
    icon: Icons.auto_awesome,
  ),
  RedditSubredditSource(
    name: 'CityPorn',
    displayName: 'r/CityPorn',
    description: 'Cityscapes, skylines and urban architecture',
    icon: Icons.apartment_outlined,
  ),
  RedditSubredditSource(
    name: 'MinimalWallpaper',
    displayName: 'r/MinimalWallpaper',
    description: 'Clean and minimalist wallpapers',
    icon: Icons.crop_square_outlined,
  ),
  RedditSubredditSource(
    name: 'ImaginaryLandscapes',
    displayName: 'r/ImaginaryLandscapes',
    description: 'Artwork depicting scenic fantasy worlds',
    icon: Icons.brush_outlined,
  ),
  RedditSubredditSource(
    name: 'Art',
    displayName: 'r/Art',
    description: 'Drawings, paintings, and digital artwork',
    icon: Icons.palette_outlined,
  ),
];

const List<String> defaultRedditSubreddits = ['wallpapers', 'wallpaper', 'EarthPorn', 'spaceporn'];

enum RedditSort {
  hot('hot', 'Hot'),
  topDay('top_day', 'Top (Today)'),
  topWeek('top_week', 'Top (This Week)'),
  topMonth('top_month', 'Top (This Month)'),
  topAll('top_all', 'Top (All Time)'),
  newPosts('new', 'New');

  final String key;
  final String label;

  const RedditSort(this.key, this.label);

  static RedditSort fromKey(String? key) {
    return RedditSort.values.firstWhere((s) => s.key == key, orElse: () => RedditSort.hot);
  }

  String get endpointPath {
    switch (this) {
      case RedditSort.hot:
        return 'hot';
      case RedditSort.topDay:
        return 'top?t=day';
      case RedditSort.topWeek:
        return 'top?t=week';
      case RedditSort.topMonth:
        return 'top?t=month';
      case RedditSort.topAll:
        return 'top?t=all';
      case RedditSort.newPosts:
        return 'new';
    }
  }

  String get rssEndpointPath {
    switch (this) {
      case RedditSort.hot:
        return 'hot.rss';
      case RedditSort.topDay:
        return 'top.rss?t=day';
      case RedditSort.topWeek:
        return 'top.rss?t=week';
      case RedditSort.topMonth:
        return 'top.rss?t=month';
      case RedditSort.topAll:
        return 'top.rss?t=all';
      case RedditSort.newPosts:
        return 'new.rss';
    }
  }
}

class RedditSlideshow {
  final Directory cacheDir;
  final http.Client _client;
  String? _accessToken;
  DateTime? _tokenExpiration;
  DateTime? _rateLimitedUntil;
  final Map<String, ({DateTime fetchedAt, List<RedditWallpaper> posts})> _postCache = {};

  /// How long a fetched post list is reused before asking Reddit again.
  static const Duration postCacheTtl = Duration(minutes: 20);

  /// Pause applied after a 429 that doesn't say when to retry.
  static const Duration defaultRateLimitBackoff = Duration(seconds: 60);

  static const String userAgent = 'android:com.omeda.arc:v1.0.0 (by /u/ArcLauncherApp)';
  static const String rssUserAgent = 'Feedly/1.0 (+http://www.feedly.com/fetcher.html; like FeedFetcher-Google)';
  static const String browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  final Map<String, List<RedditWallpaper>> _pool = {};

  RedditSlideshow(this.cacheDir, {http.Client? client}) : _client = client ?? http.Client();

  /// Clears the in-memory pool of fetched wallpaper candidates.
  void clearPool() => _pool.clear();

  /// Obtains an application-only access token if a client ID is provided.
  Future<String?> getAccessToken(String clientId, {String? clientSecret}) async {
    if (clientId.trim().isEmpty) return null;
    final now = DateTime.now();
    if (_accessToken != null && _tokenExpiration != null && now.isBefore(_tokenExpiration!)) {
      return _accessToken;
    }

    try {
      final authHeader = 'Basic ${base64Encode(utf8.encode('$clientId:${clientSecret ?? ''}'))}';
      final isScript = clientSecret != null && clientSecret.trim().isNotEmpty;
      final body = isScript
          ? {'grant_type': 'client_credentials'}
          : {'grant_type': 'https://oauth.reddit.com/grants/installed_client', 'device_id': 'DO_NOT_TRACK_THIS_DEVICE'};

      final response = await _client.post(
        Uri.parse('https://www.reddit.com/api/v1/access_token'),
        headers: {'Authorization': authHeader, 'User-Agent': userAgent},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        final expiresIn = (data['expires_in'] as int?) ?? 3600;
        if (token != null) {
          _accessToken = token;
          _tokenExpiration = now.add(Duration(seconds: max(60, expiresIn - 60)));
          return _accessToken;
        }
      } else {
        debugPrint('Reddit token request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Reddit access token error: $e');
    }
    return null;
  }

  /// Parses Reddit Atom / RSS XML feed.
  static List<RedditWallpaper> parseRss(String xmlString, String subreddit) {
    final entryRegex = RegExp(r'<entry>(.*?)</entry>', dotAll: true);
    final titleRegex = RegExp(r'<title>(.*?)</title>');
    final idRegex = RegExp(r'<id>(?:t3_)?(.*?)</id>');
    final authorRegex = RegExp(r'<author>\s*<name>(?:/u/)?(.*?)</name>');
    final linkRegex = RegExp(r'href=[\"\x27](https?://[^\s\"<>]+)[\"\x27]>\[link\]', caseSensitive: false);
    final fallbackImgRegex = RegExp(
      r'https://(?:i\.redd\.it|preview\.redd\.it|i\.imgur\.com)/[a-zA-Z0-9._-]+\.(?:jpg|jpeg|png|webp)',
    );

    final List<RedditWallpaper> wallpapers = [];

    for (final match in entryRegex.allMatches(xmlString)) {
      final block = match.group(1);
      if (block == null) continue;

      final idMatch = idRegex.firstMatch(block);
      final id = idMatch?.group(1);
      if (id == null || id.isEmpty) continue;

      final rawTitle = titleRegex.firstMatch(block)?.group(1) ?? '';
      final title = _unescapeXml(rawTitle).trim();

      final authorMatch = authorRegex.firstMatch(block);
      final author = (authorMatch?.group(1) ?? '').trim();

      final decoded = _unescapeXml(block);
      String? imageUrl = linkRegex.firstMatch(decoded)?.group(1);
      if (imageUrl != null && !RedditWallpaper._isDirectImageUrl(imageUrl)) {
        imageUrl = null;
      }
      imageUrl ??= fallbackImgRegex.firstMatch(decoded)?.group(0);

      if (imageUrl == null || imageUrl.isEmpty) continue;

      wallpapers.add(
        RedditWallpaper(
          id: id,
          title: title,
          author: author,
          subreddit: subreddit,
          imageUrl: imageUrl,
          permalink: 'https://reddit.com/r/$subreddit/comments/$id',
        ),
      );
    }

    return wallpapers;
  }

  static String _unescapeXml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');
  }

  /// Records a Reddit 429 so no further requests are sent until the limit resets.
  /// Returns true if [response] was a rate-limit response.
  bool _noteRateLimit(http.Response response) {
    if (response.statusCode != 429) return false;
    final seconds =
        int.tryParse(response.headers['retry-after'] ?? '') ??
        double.tryParse(response.headers['x-ratelimit-reset'] ?? '')?.ceil() ??
        defaultRateLimitBackoff.inSeconds;
    _rateLimitedUntil = DateTime.now().add(Duration(seconds: max(1, seconds)));
    debugPrint('Reddit rate limited, pausing requests for ${max(1, seconds)}s');
    return true;
  }

  /// Fetches a list of wallpaper posts from a subreddit.
  ///
  /// Results are cached for [postCacheTtl] and nothing is sent while Reddit is
  /// rate limiting us, to avoid hammering the API.
  Future<List<RedditWallpaper>> fetchWallpapers({
    required String subreddit,
    RedditSort sort = RedditSort.hot,
    String? clientId,
    String? clientSecret,
    int limit = 25,
  }) async {
    final cleanSubreddit = subreddit.replaceAll(RegExp(r'^r/'), '').trim();
    if (cleanSubreddit.isEmpty) return [];

    final cacheKey = '${cleanSubreddit.toLowerCase()}|${sort.key}';
    final cached = _postCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < postCacheTtl) {
      return cached.posts;
    }

    final blockedUntil = _rateLimitedUntil;
    if (blockedUntil != null && DateTime.now().isBefore(blockedUntil)) {
      debugPrint('Reddit: rate limited until $blockedUntil, skipping request');
      return [];
    }

    final posts = await _fetchFromNetwork(
      cleanSubreddit,
      sort: sort,
      clientId: clientId,
      clientSecret: clientSecret,
      limit: limit,
    );
    if (posts.isNotEmpty) _postCache[cacheKey] = (fetchedAt: DateTime.now(), posts: posts);
    return posts;
  }

  Future<List<RedditWallpaper>> _fetchFromNetwork(
    String cleanSubreddit, {
    required RedditSort sort,
    String? clientId,
    String? clientSecret,
    required int limit,
  }) async {
    final token = clientId != null && clientId.trim().isNotEmpty
        ? await getAccessToken(clientId.trim(), clientSecret: clientSecret)
        : null;

    // 1. If OAuth token is available, use official OAuth API
    if (token != null) {
      final sortParam = sort.endpointPath;
      final separator = sortParam.contains('?') ? '&' : '?';
      final uri = Uri.parse('https://oauth.reddit.com/r/$cleanSubreddit/$sortParam${separator}limit=$limit');
      final headers = {'Authorization': 'Bearer $token', 'User-Agent': userAgent};

      try {
        final response = await _client.get(uri, headers: headers);
        if (_noteRateLimit(response)) return [];
        if (response.statusCode == 200) {
          final wallpapers = _parseJsonListing(response.body);
          if (wallpapers.isNotEmpty) return wallpapers;
        } else {
          debugPrint('Reddit OAuth request failed: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Reddit OAuth fetch error: $e');
      }
    }

    // 2. Unauthenticated: Try RSS feed first with rssUserAgent (avoiding edge rate-limit 429)
    try {
      final rssParam = sort.rssEndpointPath;
      final separator = rssParam.contains('?') ? '&' : '?';
      final rssUri = Uri.parse('https://www.reddit.com/r/$cleanSubreddit/$rssParam${separator}limit=$limit');
      var rssResponse = await _client.get(
        rssUri,
        headers: {'User-Agent': rssUserAgent, 'Accept': 'application/atom+xml,application/xml,text/xml'},
      );

      if (_noteRateLimit(rssResponse)) return [];
      if (rssResponse.statusCode != 200) {
        debugPrint('Reddit RSS status with rssUserAgent: ${rssResponse.statusCode}, falling back to browserUserAgent');
        rssResponse = await _client.get(
          rssUri,
          headers: {'User-Agent': browserUserAgent, 'Accept': 'application/atom+xml,application/xml,text/xml'},
        );
      }

      if (_noteRateLimit(rssResponse)) return [];
      if (rssResponse.statusCode == 200 && rssResponse.body.contains('<feed')) {
        final wallpapers = parseRss(rssResponse.body, cleanSubreddit);
        if (wallpapers.isNotEmpty) return wallpapers;
      } else {
        debugPrint('Reddit RSS status: ${rssResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Reddit RSS error: $e');
    }

    // 3. Fallback: Try .json endpoint with browser user agent
    try {
      final sortParam = sort.endpointPath;
      final separator = sortParam.contains('?') ? '&' : '?';
      final jsonUri = Uri.parse('https://www.reddit.com/r/$cleanSubreddit/$sortParam.json${separator}limit=$limit');
      final jsonResponse = await _client.get(
        jsonUri,
        headers: {'User-Agent': browserUserAgent, 'Accept': 'application/json'},
      );

      if (_noteRateLimit(jsonResponse)) return [];
      if (jsonResponse.statusCode == 200) {
        final wallpapers = _parseJsonListing(jsonResponse.body);
        if (wallpapers.isNotEmpty) return wallpapers;
      } else {
        debugPrint('Reddit JSON request failed: ${jsonResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Reddit JSON fetch error: $e');
    }

    return [];
  }

  List<RedditWallpaper> _parseJsonListing(String jsonString) {
    try {
      final body = jsonDecode(jsonString);
      if (body is! Map<String, dynamic>) return [];
      final data = body['data'];
      if (data is! Map<String, dynamic>) return [];
      final children = data['children'];
      if (children is! List) return [];

      final List<RedditWallpaper> wallpapers = [];
      for (final child in children) {
        if (child is Map<String, dynamic> && child['data'] is Map<String, dynamic>) {
          final post = RedditWallpaper.fromJson(child['data'] as Map<String, dynamic>);
          if (post != null) {
            wallpapers.add(post);
          }
        }
      }
      return wallpapers;
    } catch (e) {
      debugPrint('Reddit JSON parse error: $e');
      return [];
    }
  }

  /// Downloads a random landscape wallpaper from the selected subreddits and caches it.
  Future<(File, RedditWallpaper)?> next({
    required List<String> subreddits,
    RedditSort sort = RedditSort.hot,
    String? clientId,
    String? clientSecret,
    Random? random,
  }) async {
    final rnd = random ?? Random();
    final validSubs = subreddits.isNotEmpty ? subreddits : defaultRedditSubreddits;
    final selectedSub = validSubs[rnd.nextInt(validSubs.length)];

    final posts = await fetchWallpapers(
      subreddit: selectedSub,
      sort: sort,
      clientId: clientId,
      clientSecret: clientSecret,
    );

    if (posts.isEmpty) {
      debugPrint('Reddit: No wallpapers found for r/$selectedSub');
      return null;
    }

    // Shuffle and pick a post
    final candidatePosts = List<RedditWallpaper>.from(posts)..shuffle(rnd);

    for (final post in candidatePosts) {
      try {
        final imageResponse = await _client.get(Uri.parse(post.imageUrl), headers: {'User-Agent': browserUserAgent});
        if (imageResponse.statusCode != 200 || imageResponse.bodyBytes.isEmpty) {
          debugPrint('Reddit: Failed to download ${post.imageUrl} (${imageResponse.statusCode})');
          continue;
        }

        await cacheDir.create(recursive: true);
        final tmp = File('${cacheDir.path}/${post.id}.part');
        await tmp.writeAsBytes(imageResponse.bodyBytes, flush: true);
        final file = await tmp.rename('${cacheDir.path}/${post.id}.jpg');
        await pruneCache(cacheDir, keep: slideshowMaxCachedFiles);

        return (file, post);
      } catch (e) {
        debugPrint('Reddit download error: $e');
      }
    }

    return null;
  }
}
