import 'package:custom_pagination/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginationMeta', () {
    test('should create with default values', () {
      final meta = PaginationMeta();

      expect(meta.page, isNull);
      expect(meta.pageSize, isNull);
      expect(meta.nextCursor, isNull);
      expect(meta.previousCursor, isNull);
      expect(meta.hasNext, isFalse);
      expect(meta.hasPrevious, isFalse);
      expect(meta.totalCount, isNull);
      expect(meta.fetchedAt, isA<DateTime>());
    });

    test('should create with provided values', () {
      final fetchedAt = DateTime(2025, 1, 1);
      final meta = PaginationMeta(
        page: 2,
        pageSize: 20,
        nextCursor: 'next_token',
        previousCursor: 'prev_token',
        hasNext: true,
        hasPrevious: true,
        totalCount: 100,
        fetchedAt: fetchedAt,
      );

      expect(meta.page, equals(2));
      expect(meta.pageSize, equals(20));
      expect(meta.nextCursor, equals('next_token'));
      expect(meta.previousCursor, equals('prev_token'));
      expect(meta.hasNext, isTrue);
      expect(meta.hasPrevious, isTrue);
      expect(meta.totalCount, equals(100));
      expect(meta.fetchedAt, equals(fetchedAt));
    });

    test('should copy with new values', () {
      final meta = PaginationMeta(page: 1, pageSize: 20);

      final copied = meta.copyWith(
        page: 2,
        hasNext: true,
      );

      expect(copied.page, equals(2));
      expect(copied.pageSize, equals(20)); // unchanged
      expect(copied.hasNext, isTrue);
    });

    test('should serialize to JSON', () {
      final fetchedAt = DateTime(2025, 1, 1);
      final meta = PaginationMeta(
        page: 2,
        pageSize: 20,
        nextCursor: 'next_token',
        hasNext: true,
        hasPrevious: true,
        totalCount: 100,
        fetchedAt: fetchedAt,
      );

      final json = meta.toJson();

      expect(json['page'], equals(2));
      expect(json['pageSize'], equals(20));
      expect(json['nextCursor'], equals('next_token'));
      expect(json['hasNext'], isTrue);
      expect(json['hasPrevious'], isTrue);
      expect(json['totalCount'], equals(100));
      expect(json['fetchedAt'], equals(fetchedAt.toIso8601String()));
    });

    test('should serialize to JSON without null values', () {
      final meta = PaginationMeta(page: 1);

      final json = meta.toJson();

      expect(json.containsKey('page'), isTrue);
      expect(json.containsKey('nextCursor'), isFalse);
      expect(json.containsKey('previousCursor'), isFalse);
      expect(json.containsKey('totalCount'), isFalse);
    });

    test('should deserialize from JSON', () {
      final json = {
        'page': 2,
        'pageSize': 20,
        'nextCursor': 'next_token',
        'previousCursor': 'prev_token',
        'hasNext': true,
        'hasPrevious': true,
        'totalCount': 100,
        'fetchedAt': '2025-01-01T00:00:00.000',
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.page, equals(2));
      expect(meta.pageSize, equals(20));
      expect(meta.nextCursor, equals('next_token'));
      expect(meta.previousCursor, equals('prev_token'));
      expect(meta.hasNext, isTrue);
      expect(meta.hasPrevious, isTrue);
      expect(meta.totalCount, equals(100));
    });

    test('should handle alternative JSON field names', () {
      final json = {
        'page': 1,
        'limit': 20, // alternative to pageSize
        'next': 'next_token', // alternative to nextCursor
        'previous': 'prev_token', // alternative to previousCursor
        'has_next': true, // alternative to hasNext
        'has_previous': true, // alternative to hasPrevious
        'total_count': 100, // alternative to totalCount
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.pageSize, equals(20));
      expect(meta.nextCursor, equals('next_token'));
      expect(meta.previousCursor, equals('prev_token'));
      expect(meta.hasNext, isTrue);
      expect(meta.hasPrevious, isTrue);
      expect(meta.totalCount, equals(100));
    });

    test('should infer hasNext from nextCursor presence', () {
      final json = {
        'nextCursor': 'next_token',
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.hasNext, isTrue);
    });

    test('should infer hasPrevious from previousCursor presence', () {
      final json = {
        'previousCursor': 'prev_token',
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.hasPrevious, isTrue);
    });
  });
}
