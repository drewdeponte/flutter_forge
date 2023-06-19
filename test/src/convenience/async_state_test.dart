import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_forge/flutter_forge.dart';

void main() {
  group('AsyncState', () {
    test('construct an initial AsyncState', () async {
      const state = AsyncState<String>.initial();
      expect(state is AsyncStateInitial, true);
      expect(state.isInitial, true);
      expect(state.isLoading, false);
      expect(state.hasValue, false);
      expect(state.hasError, false);
      expect(state.value, null);
      expect(state.error, null);
      expect(state.stackTrace, null);
    });

    test('construct a loading AsyncState', () async {
      const state = AsyncState<String>.loading();
      expect(state is AsyncStateLoading, true);
      expect(state.isInitial, false);
      expect(state.isLoading, true);
      expect(state.hasValue, false);
      expect(state.hasError, false);
      expect(state.value, null);
      expect(state.error, null);
      expect(state.stackTrace, null);
    });

    test('construct a data AsyncState', () async {
      const state = AsyncState<String>.data("loaded string");
      expect(state is AsyncStateData, true);
      expect(state.isInitial, false);
      expect(state.isLoading, false);
      expect(state.hasValue, true);
      expect(state.hasError, false);
      expect(state.value, "loaded string");
      expect(state.error, null);
      expect(state.stackTrace, null);
    });

    test('construct a error AsyncState', () async {
      try {
        final someError = Error();
        throw someError;
      } catch (e) {
        final state = AsyncState<String>.error(e, (e as Error).stackTrace!);
        expect(state is AsyncStateError, true);
        expect(state.isInitial, false);
        expect(state.isLoading, false);
        expect(state.hasValue, false);
        expect(state.hasError, true);
        expect(state.value, null);
        expect(state.error, e);
        expect(state.stackTrace, e.stackTrace!);
      }
    });

    group('#when', () {
      group('when is an initial AsyncState', () {
        test('it executes the initial function', () {
          const state = AsyncState<String>.initial();
          bool initialCalled = false;
          bool loadingCalled = false;
          bool dataCalled = false;
          bool errorCalled = false;
          state.when(initial: () {
            initialCalled = true;
          }, loading: () {
            loadingCalled = true;
          }, data: (_) {
            dataCalled = true;
          }, error: (_, __) {
            errorCalled = true;
          });

          expect(initialCalled, true);
          expect(loadingCalled, false);
          expect(dataCalled, false);
          expect(errorCalled, false);
        });
      });

      group('when is a loading AsyncState', () {
        test('it executes the loading function', () {
          const state = AsyncState<String>.loading();
          bool initialCalled = false;
          bool loadingCalled = false;
          bool dataCalled = false;
          bool errorCalled = false;
          state.when(initial: () {
            initialCalled = true;
          }, loading: () {
            loadingCalled = true;
          }, data: (_) {
            dataCalled = true;
          }, error: (_, __) {
            errorCalled = true;
          });

          expect(initialCalled, false);
          expect(loadingCalled, true);
          expect(dataCalled, false);
          expect(errorCalled, false);
        });
      });

      group('when is a data AsyncState', () {
        test('it executes the data function', () {
          const state = AsyncState<String>.data("some string");
          bool initialCalled = false;
          bool loadingCalled = false;
          bool dataCalled = false;
          String dataCalledWith = "";
          bool errorCalled = false;
          state.when(initial: () {
            initialCalled = true;
          }, loading: () {
            loadingCalled = true;
          }, data: (val) {
            dataCalled = true;
            dataCalledWith = val;
          }, error: (_, __) {
            errorCalled = true;
          });

          expect(initialCalled, false);
          expect(loadingCalled, false);
          expect(dataCalled, true);
          expect(dataCalledWith, "some string");
          expect(errorCalled, false);
        });
      });

      group('when is a error AsyncState', () {
        test('it executes the error function', () {
          try {
            final someError = Error();
            throw someError;
          } catch (e) {
            final state = AsyncState<String>.error(e, (e as Error).stackTrace!);
            bool initialCalled = false;
            bool loadingCalled = false;
            bool dataCalled = false;
            bool errorCalled = false;
            Object? errorCalledWithError;
            StackTrace? errorCalledWithStackTrace;

            state.when(initial: () {
              initialCalled = true;
            }, loading: () {
              loadingCalled = true;
            }, data: (_) {
              dataCalled = true;
            }, error: (e, st) {
              errorCalled = true;
              errorCalledWithError = e;
              errorCalledWithStackTrace = st;
            });

            expect(initialCalled, false);
            expect(loadingCalled, false);
            expect(dataCalled, false);
            expect(errorCalled, true);
            expect(errorCalledWithError!, e);
            expect(errorCalledWithStackTrace!, e.stackTrace!);
          }
        });
      });
    });
  });
}
