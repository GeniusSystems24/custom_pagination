import 'package:bloc_test/bloc_test.dart';
import 'package:custom_pagination/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('DualPaginationCubit', () {
    late Future<List<TestItem>> Function(PaginationRequest) dataProvider;
    late List<MapEntry<String, List<TestItem>>> Function(List<TestItem>) groupKeyGenerator;

    setUp(() {
      dataProvider = (request) async {
        await Future.delayed(Duration(milliseconds: 10));
        final startIndex = (request.page - 1) * (request.pageSize ?? 20);
        return TestItemFactory.createList(request.pageSize ?? 20, startIndex: startIndex);
      };

      groupKeyGenerator = (items) {
        // Group by value range: 0-9, 10-19, 20-29, etc.
        final grouped = <String, List<TestItem>>{};
        for (var item in items) {
          final groupKey = '${(item.value ~/ 10) * 10}-${(item.value ~/ 10) * 10 + 9}';
          grouped.putIfAbsent(groupKey, () => []).add(item);
        }
        return grouped.entries.toList();
      };
    });

    test('initial state is DualPaginationInitial', () {
      final cubit = DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      );

      expect(cubit.state, isA<DualPaginationInitial<TestItem>>());
      expect(cubit.didFetch, isFalse);

      cubit.dispose();
    });

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'emits DualPaginationLoaded with grouped items',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) => cubit.fetchPaginatedList(),
      expect: () => [
        isA<DualPaginationLoaded<String, TestItem>>()
            .having((s) => s.allItems.length, 'all items length', 20)
            .having((s) => s.groups.length, 'groups count', 2) // 0-9, 10-19
            .having((s) => s.hasReachedEnd, 'hasReachedEnd', false),
      ],
    );

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'groups items correctly',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 25),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) => cubit.fetchPaginatedList(),
      verify: (cubit) {
        final state = cubit.state as DualPaginationLoaded<String, TestItem>;
        expect(state.groups.length, equals(3)); // 0-9, 10-19, 20-29
        expect(state.groups[0].key, equals('0-9'));
        expect(state.groups[0].value.length, equals(10));
        expect(state.groups[1].key, equals('10-19'));
        expect(state.groups[1].value.length, equals(10));
        expect(state.groups[2].key, equals('20-29'));
        expect(state.groups[2].value.length, equals(5));
      },
    );

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'loads multiple pages and groups them',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) async {
        await cubit.fetchPaginatedList(); // Page 1: items 0-9
        await Future.delayed(Duration(milliseconds: 50));
        await cubit.fetchPaginatedList(); // Page 2: items 10-19
      },
      expect: () => [
        isA<DualPaginationLoaded<String, TestItem>>()
            .having((s) => s.allItems.length, 'first page items', 10)
            .having((s) => s.groups.length, 'first page groups', 1),
        isA<DualPaginationLoaded<String, TestItem>>()
            .having((s) => s.allItems.length, 'second page items', 20)
            .having((s) => s.groups.length, 'second page groups', 2),
      ],
    );

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'filterPaginatedList filters items and regroups',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 25),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) async {
        await cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        cubit.filterPaginatedList((item) => item.value < 15);
      },
      verify: (cubit) {
        final state = cubit.state as DualPaginationLoaded<String, TestItem>;
        expect(state.allItems.length, equals(15)); // Items 0-14
        expect(state.groups.length, equals(2)); // 0-9, 10-19 (partial)
      },
    );

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'insertEmitState adds items and regroups',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) async {
        await cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        cubit.insertEmitState(
          newItems: [
            TestItem(id: '100', name: 'New Item 1', value: 100),
            TestItem(id: '101', name: 'New Item 2', value: 101),
          ],
        );
      },
      verify: (cubit) {
        final state = cubit.state as DualPaginationLoaded<String, TestItem>;
        expect(state.allItems.length, equals(12));
        // Should have new group for 100-109
        final hasNewGroup = state.groups.any((g) => g.key == '100-109');
        expect(hasNewGroup, isTrue);
      },
    );

    test('sort function sorts items before grouping', () async {
      final cubit = DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
        sort: (items) {
          // Sort in reverse order
          return items..sort((a, b) => b.value.compareTo(a.value));
        },
      );

      await cubit.fetchPaginatedList();
      await Future.delayed(Duration(milliseconds: 50));

      final state = cubit.state as DualPaginationLoaded<String, TestItem>;
      expect(state.allItems.first.value, equals(9)); // Highest should be first
      expect(state.allItems.last.value, equals(0)); // Lowest should be last

      cubit.dispose();
    });

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'emits error when data provider throws',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        dataProvider: (request) async {
          throw Exception('Network error');
        },
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) => cubit.fetchPaginatedList(),
      expect: () => [
        isA<DualPaginationError<TestItem>>()
            .having((s) => s.error.toString(), 'error message', contains('Network error')),
      ],
    );

    blocTest<DualPaginationCubit<String, TestItem>, DualPaginationState<TestItem>>(
      'refreshPaginatedList clears and starts over',
      build: () => DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        dataProvider: dataProvider,
        groupKeyGenerator: groupKeyGenerator,
      ),
      act: (cubit) async {
        await cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        await cubit.refreshPaginatedList();
      },
      expect: () => [
        isA<DualPaginationLoaded<String, TestItem>>()
            .having((s) => s.allItems.length, 'first fetch', 10),
        isA<DualPaginationLoaded<String, TestItem>>()
            .having((s) => s.allItems.length, 'after refresh', 10)
            .having((s) => s.meta.page, 'page after refresh', 1),
      ],
    });

    test('grouping works with complex keys', () async {
      // Group by first letter of name
      final letterGroupGenerator = (List<TestItem> items) {
        final grouped = <String, List<TestItem>>{};
        for (var item in items) {
          final key = item.name[0].toUpperCase();
          grouped.putIfAbsent(key, () => []).add(item);
        }
        return grouped.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
      };

      final cubit = DualPaginationCubit<String, TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        dataProvider: dataProvider,
        groupKeyGenerator: letterGroupGenerator,
      );

      await cubit.fetchPaginatedList();
      await Future.delayed(Duration(milliseconds: 50));

      final state = cubit.state as DualPaginationLoaded<String, TestItem>;
      expect(state.groups.length, equals(1)); // All start with 'I' (Item)
      expect(state.groups[0].key, equals('I'));

      cubit.dispose();
    });
  });
}
