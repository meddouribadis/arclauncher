import 'dart:io';
import 'dart:math';

import 'package:arclauncher/providers/unsplash_slideshow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('slideshow_test'));
  tearDown(() async => dir.delete(recursive: true));

  Future<File> image(String name, int ageMinutes) async {
    final f = await File("${dir.path}/$name").writeAsBytes([1, 2, 3]);
    await f.setLastModified(DateTime.now().subtract(Duration(minutes: ageMinutes)));
    return f;
  }

  test("pruneCache keeps only the newest images and drops temp files", () async {
    await image("old.jpg", 30);
    await image("mid.jpg", 20);
    await image("new.jpg", 10);
    await image("crashed.part", 5);

    await pruneCache(dir, keep: slideshowMaxCachedFiles);

    final names = dir.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {"mid.jpg", "new.jpg"});
  });

  test("newestCachedImage returns the latest jpg, or null when empty", () async {
    expect(newestCachedImage(dir), isNull);
    await image("a.jpg", 20);
    await image("b.jpg", 5);
    await image("c.part", 1);
    expect(newestCachedImage(dir)!.path.endsWith("b.jpg"), isTrue);
  });

  test("UnsplashPhoto parses the API response and requests a 1080p jpeg", () {
    final photo = UnsplashPhoto.fromJson({
      'id': 'abc',
      'urls': {'raw': 'https://images.unsplash.com/photo-1?ixid=x'},
      'user': {'name': 'Jane Doe'},
      'links': {'download_location': 'https://api.unsplash.com/photos/abc/download'},
    });
    expect(photo.author, "Jane Doe");
    expect(photo.imageUrl, "https://images.unsplash.com/photo-1?ixid=x&w=1920&h=1080&fit=crop&fm=jpg&q=80");
    expect(photo.downloadLocation, endsWith("/abc/download"));
  });

  test("next returns null without an access key (nothing written)", () async {
    expect(await UnsplashSlideshow(dir).next({'topics': 't1'}, ""), isNull);
    expect(dir.listSync(), isEmpty);
  });

  test("next downloads the photo, pings download_location and caps the cache", () async {
    final requested = <String>[];
    final client = MockClient((req) async {
      requested.add(req.url.toString());
      if (req.url.path == "/photos/random") {
        expect(req.headers['Authorization'], "Client-ID k");
        expect(req.url.queryParameters['topics'], "t1");
        return http.Response(
            '{"id":"p1","urls":{"raw":"https://img.test/p1?a=1"},"user":{"name":"Ann"},'
            '"links":{"download_location":"https://api.unsplash.com/photos/p1/download"}}',
            200);
      }
      if (req.url.host == "img.test") return http.Response.bytes([9, 9, 9], 200);
      return http.Response("{}", 200);
    });
    await image("older1.jpg", 30);
    await image("older2.jpg", 20);

    final result = await UnsplashSlideshow(dir, client: client).next({'topics': 't1'}, "k");
    await Future<void>.delayed(Duration.zero); // let the fire-and-forget download ping run

    final (file, author) = result!;
    expect(author, "Ann");
    expect(await file.readAsBytes(), [9, 9, 9]);
    expect(dir.listSync().map((e) => e.uri.pathSegments.last).toSet(), {"p1.jpg", "older2.jpg"});
    expect(requested, contains("https://api.unsplash.com/photos/p1/download"));
  });

  test("pickSlideshowFilter only picks selected categories, falls back to defaults", () {
    final random = Random(1);
    final picked = {for (var i = 0; i < 50; i++) pickSlideshowFilter(['nature', 'milkyway'], ['wallpapers'], random)['topics'] ?? 'c'};
    expect(picked, {'6sMVjTLSkeQ', 'c'}); // nature topic + milky way collection, nothing else

    expect(pickSlideshowFilter([], ['wallpapers'], random), {'topics': 'bo8jQKTaE0Y'});
    expect(pickSlideshowFilter(['removed-key'], ['milkyway'], random), {'collections': '2286207'});
  });

  test("next filters by collection without sending a query", () async {
    Uri? random;
    final client = MockClient((req) async {
      random ??= req.url;
      return http.Response("{}", 500);
    });
    await UnsplashSlideshow(dir, client: client).next({'collections': '2286207'}, "k");
    expect(random!.queryParameters['collections'], '2286207');
    expect(random!.queryParameters.containsKey('query'), isFalse);
  });

  test("next keeps the current wallpaper when the API fails", () async {
    final client = MockClient((_) async => http.Response("rate limited", 403));
    expect(await UnsplashSlideshow(dir, client: client).next({'topics': 't1'}, "k"), isNull);
    expect(dir.listSync(), isEmpty);
  });
}
