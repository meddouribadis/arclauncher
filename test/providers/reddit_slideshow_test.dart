import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flauncher/providers/reddit_slideshow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('reddit_slideshow_test'));
  tearDown(() async => dir.delete(recursive: true));

  group("RedditWallpaper.fromJson", () {
    test("parses valid direct image post", () {
      final post = RedditWallpaper.fromJson({
        'id': 'abc123',
        'title': 'Mountain Sunrise [3840x2160]',
        'author': 'earth_lover',
        'subreddit': 'EarthPorn',
        'url': 'https://i.redd.it/mountain.jpg',
        'permalink': '/r/EarthPorn/comments/abc123/mountain_sunrise/',
        'over_18': false,
        'stickied': false,
        'is_video': false,
      });

      expect(post, isNotNull);
      expect(post!.id, 'abc123');
      expect(post.title, 'Mountain Sunrise [3840x2160]');
      expect(post.author, 'earth_lover');
      expect(post.subreddit, 'EarthPorn');
      expect(post.imageUrl, 'https://i.redd.it/mountain.jpg');
      expect(post.credit, 'r/EarthPorn • u/earth_lover');
    });

    test("parses preview images and unescapes &amp;", () {
      final post = RedditWallpaper.fromJson({
        'id': 'prev1',
        'title': 'Nebula',
        'author': 'stargazer',
        'subreddit': 'spaceporn',
        'url': 'https://reddit.com/r/spaceporn/comments/prev1',
        'permalink': '/r/spaceporn/comments/prev1',
        'over_18': false,
        'stickied': false,
        'is_video': false,
        'preview': {
          'images': [
            {
              'source': {
                'url': 'https://preview.redd.it/nebula.jpg?auto=webp&amp;s=12345',
                'width': 1920,
                'height': 1080,
              },
            },
          ],
        },
      });

      expect(post, isNotNull);
      expect(post!.imageUrl, 'https://preview.redd.it/nebula.jpg?auto=webp&s=12345');
      expect(post.width, 1920);
      expect(post.height, 1080);
    });

    test("parses reddit gallery posts", () {
      final post = RedditWallpaper.fromJson({
        'id': 'gal1',
        'title': 'City Skyline',
        'author': 'architect',
        'subreddit': 'CityPorn',
        'permalink': '/r/CityPorn/comments/gal1',
        'is_gallery': true,
        'media_metadata': {
          'item1': {
            's': {'u': 'https://preview.redd.it/city.jpg?auto=webp&amp;s=abc', 'x': 2560, 'y': 1440},
          },
        },
        'over_18': false,
        'stickied': false,
        'is_video': false,
      });

      expect(post, isNotNull);
      expect(post!.imageUrl, 'https://preview.redd.it/city.jpg?auto=webp&s=abc');
      expect(post.width, 2560);
      expect(post.height, 1440);
    });

    test("rejects NSFW posts", () {
      final post = RedditWallpaper.fromJson({
        'id': 'nsfw1',
        'title': 'Explicit content',
        'author': 'user',
        'subreddit': 'wallpapers',
        'url': 'https://i.redd.it/img.jpg',
        'over_18': true,
      });
      expect(post, isNull);
    });

    test("rejects stickied posts", () {
      final post = RedditWallpaper.fromJson({
        'id': 'sticky1',
        'title': 'Weekly rules',
        'author': 'mod',
        'subreddit': 'wallpapers',
        'url': 'https://i.redd.it/img.jpg',
        'over_18': false,
        'stickied': true,
      });
      expect(post, isNull);
    });

    test("rejects video posts", () {
      final post = RedditWallpaper.fromJson({
        'id': 'vid1',
        'title': 'Animated wallpaper',
        'author': 'user',
        'subreddit': 'wallpapers',
        'url': 'https://v.redd.it/video.mp4',
        'over_18': false,
        'is_video': true,
      });
      expect(post, isNull);
    });

    test("rejects portrait images (width < height)", () {
      final post = RedditWallpaper.fromJson({
        'id': 'vert1',
        'title': 'Phone wallpaper',
        'author': 'user',
        'subreddit': 'wallpaper',
        'url': 'https://i.redd.it/phone.jpg',
        'over_18': false,
        'is_video': false,
        'preview': {
          'images': [
            {
              'source': {'url': 'https://preview.redd.it/phone.jpg', 'width': 1080, 'height': 2400},
            },
          ],
        },
      });
      expect(post, isNull);
    });
  });

  group("parseRss", () {
    test("extracts wallpapers from Atom XML feed", () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <author><name>/u/Glad_Instruction_216</name></author>
    <content type="html">&lt;span&gt;&lt;a href=&quot;https://i.redd.it/patagonia.jpeg&quot;&gt;[link]&lt;/a&gt;&lt;/span&gt;</content>
    <id>t3_1xc0jnq</id>
    <title>Patagonian Mountain Peaks [3840x2160]</title>
  </entry>
</feed>''';

      final wallpapers = RedditSlideshow.parseRss(xml, 'wallpapers');
      expect(wallpapers.length, 1);
      expect(wallpapers.first.id, '1xc0jnq');
      expect(wallpapers.first.author, 'Glad_Instruction_216');
      expect(wallpapers.first.title, 'Patagonian Mountain Peaks [3840x2160]');
      expect(wallpapers.first.imageUrl, 'https://i.redd.it/patagonia.jpeg');
      expect(wallpapers.first.subreddit, 'wallpapers');
    });
  });

  group("RedditSlideshow API & download", () {
    test("obtains OAuth access token when clientId is provided", () async {
      final client = MockClient((req) async {
        if (req.url.path == '/api/v1/access_token') {
          expect(req.headers['Authorization'], startsWith('Basic '));
          return http.Response(jsonEncode({'access_token': 'test_token_123', 'expires_in': 3600}), 200);
        }
        return http.Response('{}', 404);
      });

      final slideshow = RedditSlideshow(dir, client: client);
      final token = await slideshow.getAccessToken('my_client_id');
      expect(token, 'test_token_123');
    });

    test("fetchWallpapers queries RSS feed when no token", () async {
      final client = MockClient((req) async {
        if (req.url.path.endsWith('.rss')) {
          return http.Response('''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <author><name>/u/nature_fan</name></author>
    <content type="html">&lt;span&gt;&lt;a href=&quot;https://i.redd.it/forest.jpg&quot;&gt;[link]&lt;/a&gt;&lt;/span&gt;</content>
    <id>t3_p1</id>
    <title>Forest path</title>
  </entry>
</feed>''', 200);
        }
        return http.Response('{}', 404);
      });

      final slideshow = RedditSlideshow(dir, client: client);
      final posts = await slideshow.fetchWallpapers(subreddit: 'wallpapers');
      expect(posts.length, 1);
      expect(posts.first.id, 'p1');
      expect(posts.first.imageUrl, 'https://i.redd.it/forest.jpg');
    });

    test("next downloads image and returns cached file and metadata", () async {
      final client = MockClient((req) async {
        if (req.url.path.endsWith('.rss')) {
          return http.Response('''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <author><name>/u/sunset_photog</name></author>
    <content type="html">&lt;span&gt;&lt;a href=&quot;https://img.test/lake.jpg&quot;&gt;[link]&lt;/a&gt;&lt;/span&gt;</content>
    <id>t3_p2</id>
    <title>Lake sunset</title>
  </entry>
</feed>''', 200);
        }
        if (req.url.host == 'img.test') {
          return http.Response.bytes([0xAA, 0xBB, 0xCC], 200);
        }
        return http.Response('{}', 404);
      });

      final slideshow = RedditSlideshow(dir, client: client);
      final result = await slideshow.next(subreddits: ['EarthPorn'], sort: RedditSort.hot, random: Random(42));

      expect(result, isNotNull);
      final (file, wallpaper) = result!;
      expect(wallpaper.id, 'p2');
      expect(wallpaper.title, 'Lake sunset');
      expect(await file.readAsBytes(), [0xAA, 0xBB, 0xCC]);
      expect(file.path.endsWith('p2.jpg'), isTrue);
    });

    test("next returns null when API fails", () async {
      final client = MockClient((_) async => http.Response('Server error', 500));
      final slideshow = RedditSlideshow(dir, client: client);
      final result = await slideshow.next(subreddits: ['wallpapers']);
      expect(result, isNull);
    });

    test("stops after a 429 and pauses requests until the limit resets", () async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response('Too Many Requests', 429, headers: {'x-ratelimit-reset': '30'});
      });
      final slideshow = RedditSlideshow(dir, client: client);

      expect(await slideshow.fetchWallpapers(subreddit: 'wallpapers'), isEmpty);
      expect(requests, 1, reason: 'must not fall back to .json after a 429');

      expect(await slideshow.fetchWallpapers(subreddit: 'wallpaper'), isEmpty);
      expect(requests, 1, reason: 'must not send requests while rate limited');
    });

    test("reuses cached posts for the same subreddit and sort", () async {
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return http.Response('''<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <author><name>/u/nature_fan</name></author>
    <content type="html">&lt;span&gt;&lt;a href=&quot;https://i.redd.it/forest.jpg&quot;&gt;[link]&lt;/a&gt;&lt;/span&gt;</content>
    <id>t3_p1</id>
    <title>Forest path</title>
  </entry>
</feed>''', 200);
      });
      final slideshow = RedditSlideshow(dir, client: client);

      await slideshow.fetchWallpapers(subreddit: 'wallpapers');
      final again = await slideshow.fetchWallpapers(subreddit: 'r/Wallpapers');
      expect(again.length, 1);
      expect(requests, 1);

      await slideshow.fetchWallpapers(subreddit: 'wallpapers', sort: RedditSort.newPosts);
      expect(requests, 2);
    });
  });
}
