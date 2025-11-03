import 'package:bloc_test/bloc_test.dart';
import 'package:custom_pagination/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_models.dart';

void main() {
  group('SmartPaginationCubit', () {
    late Future<List<TestItem>> Function(PaginationRequest) dataProviderFn;

    setUp(() {
      dataProviderFn = (request) async {
        // Simulate API call
        await Future.delayed(Duration(milliseconds: 10));
        final startIndex = (request.page - 1) * (request.pageSize ?? 20);
        return TestItemFactory.createList(request.pageSize ?? 20, startIndex: startIndex);
      };
    });

    test('initial state is SmartPaginationInitial', () {
      final cubit = SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(dataProviderFn),
      );

      expect(cubit.state, isA<SmartPaginationInitial<TestItem>>());
      expect(cubit.didFetch, isFalse);

      cubit.dispose();
    });

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'emits SmartPaginationLoaded when data is fetched successfully',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) => cubit.fetchPaginatedList(),
      expect: () => [
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'items length', 20)
            .having((s) => s.hasReachedEnd, 'hasReachedEnd', false)
            .having((s) => s.meta.page, 'page', 1),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'loads multiple pages',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) async {
        cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        cubit.fetchPaginatedList();
      },
      expect: () => [
        // First page
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'first page items', 10)
            .having((s) => s.meta.page, 'first page number', 1),
        // Second page
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'second page items', 20)
            .having((s) => s.meta.page, 'second page number', 2),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'emits error when data provider throws',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(
          (request) async {
            throw Exception('Network error');
          },
        ),
      ),
      act: (cubit) => cubit.fetchPaginatedList(),
      expect: () => [
        isA<SmartPaginationError<TestItem>>()
            .having((s) => s.error.toString(), 'error message', contains('Network error')),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'refreshPaginatedList clears existing data and starts over',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) async {
        cubit.fetchPaginatedList(); // Load first page
        await Future.delayed(Duration(milliseconds: 50));
        cubit.refreshPaginatedList(); // Refresh
      },
      expect: () => [
        // First fetch
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'first fetch', 10),
        // Refresh (resets to page 1)
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'after refresh', 10)
            .having((s) => s.meta.page, 'page after refresh', 1),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'filterPaginatedList filters items',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) async {
        cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        cubit.filterPaginatedList((item) => item.value < 10);
      },
      expect: () => [
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'before filter', 20),
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'after filter', 10),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'insertEmit adds item at specified index',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 5),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) async {
        cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        cubit.insertEmit(TestItem(id: '999', name: 'Inserted', value: 999), index: 2);
      },
      expect: () => [
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'before insert', 5),
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'after insert', 6)
            .having((s) => s.items[2].id, 'inserted item', '999'),
      ],
    );

    blocTest<SmartPaginationCubit<TestItem>, SmartPaginationState<TestItem>>(
      'addOrUpdateEmit updates existing item',
      build: () => SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 5),
        provider: PaginationProvider.future(dataProviderFn),
      ),
      act: (cubit) async {
        cubit.fetchPaginatedList();
        await Future.delayed(Duration(milliseconds: 50));
        final existingItem = (cubit.state as SmartPaginationLoaded<TestItem>).items[0];
        final updatedItem = TestItem(
          id: existingItem.id,
          name: 'Updated',
          value: existingItem.value,
        );
        cubit.addOrUpdateEmit(updatedItem);
      },
      expect: () => [
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'before update', 5),
        isA<SmartPaginationLoaded<TestItem>>()
            .having((s) => s.items.length, 'after update', 5)
            .having((s) => s.items[0].name, 'updated name', 'Updated'),
      ],
    );

    test('listBuilder transforms items', () async {
      final cubit = SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        provider: PaginationProvider.future(dataProviderFn),
        listBuilder: (items) {
          // Reverse the list
          return items.reversed.toList();
        },
      );

      cubit.fetchPaginatedList();
      await Future.delayed(Duration(milliseconds: 50));

      final state = cubit.state as SmartPaginationLoaded<TestItem>;
      expect(state.items.first.value, equals(9)); // Last item should be first
      expect(state.items.last.value, equals(0)); // First item should be last

      cubit.dispose();
    });

    test('maxPagesInMemory limits cached pages', () async {
      final cubit = SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 5),
        provider: PaginationProvider.future(dataProviderFn),
        maxPagesInMemory: 2,
      );

      // Load 3 pages
      cubit.fetchPaginatedList(); // Page 1
      await Future.delayed(Duration(milliseconds: 50));
      cubit.fetchPaginatedList(); // Page 2
      await Future.delayed(Duration(milliseconds: 50));
      cubit.fetchPaginatedList(); // Page 3 (should evict page 1)
      await Future.delayed(Duration(milliseconds: 50));

      final state = cubit.state as SmartPaginationLoaded<TestItem>;
      // Should have items from page 2 and 3 only (10 items)
      expect(state.items.length, equals(10));

      cubit.dispose();
    });

    test('cancelOngoingRequest cancels current fetch', () async {
      int fetchCount = 0;
      final cubit = SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 10),
        provider: PaginationProvider.future(
          (request) async {
            fetchCount++;
            await Future.delayed(Duration(milliseconds: 100));
            return TestItemFactory.createList(10);
          },
        ),
      );

      cubit.fetchPaginatedList();
      await Future.delayed(Duration(milliseconds: 10));
      cubit.cancelOngoingRequest(); // Cancel the fetch
      await Future.delayed(Duration(milliseconds: 150));

      // State should still be initial because fetch was cancelled
      expect(cubit.state, isA<SmartPaginationInitial<TestItem>>());
      expect(fetchCount, equals(1)); // Fetch was started

      cubit.dispose();
    });

    test('hasReachedEnd is true when no more items', () async {
      final cubit = SmartPaginationCubit<TestItem>(
        request: PaginationRequest(page: 1, pageSize: 20),
        provider: PaginationProvider.future(
          (request) async {
            // Return less than pageSize to indicate end
            return TestItemFactory.createList(5);
          },
        ),
      );

      cubit.fetchPaginatedList();
      await Future.delayed(Duration(milliseconds: 50));

      final state = cubit.state as SmartPaginationLoaded<TestItem>;
      expect(state.hasReachedEnd, isTrue);

      cubit.dispose();
    });
  });
}
