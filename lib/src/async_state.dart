import 'package:equatable/equatable.dart';

abstract class AsyncState<T extends Equatable> extends Equatable {
  const AsyncState._();

  const factory AsyncState.initial() = AsyncStateInitial<T>;
  const factory AsyncState.loading() = AsyncStateLoading<T>;
  const factory AsyncState.data(T value) = AsyncStateData<T>;
  const factory AsyncState.error(Object error, StackTrace stackTrace) =
      AsyncStateError<T>;

  bool get isInitial;
  bool get isLoading;
  bool get hasValue;
  T? get value;
  bool get hasError;
  Object? get error;
  StackTrace? get stackTrace;

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
  }) {
    if (this.isInitial) {
      return initial();
    } else if (this.isLoading) {
      return loading();
    } else if (this.hasError) {
      return error(this.error!, this.stackTrace!);
    } else {
      return data(this.value!);
    }
  }
}

class AsyncStateInitial<T extends Equatable> extends AsyncState<T> {
  const AsyncStateInitial() : super._();

  bool get isInitial {
    return true;
  }

  bool get isLoading {
    return false;
  }

  bool get hasValue {
    return false;
  }

  T? get value {
    return null;
  }

  bool get hasError {
    return false;
  }

  Object? get error {
    return null;
  }

  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError];
}

class AsyncStateLoading<T extends Equatable> extends AsyncState<T> {
  const AsyncStateLoading() : super._();

  bool get isInitial {
    return false;
  }

  bool get isLoading {
    return true;
  }

  bool get hasValue {
    return false;
  }

  T? get value {
    return null;
  }

  bool get hasError {
    return false;
  }

  Object? get error {
    return null;
  }

  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError];
}

class AsyncStateData<T extends Equatable> extends AsyncState<T> {
  const AsyncStateData(this._value) : super._();
  final T _value;

  bool get isInitial {
    return false;
  }

  bool get isLoading {
    return false;
  }

  bool get hasValue {
    return true;
  }

  T? get value {
    return this._value;
  }

  bool get hasError {
    return false;
  }

  Object? get error {
    return null;
  }

  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError, _value];
}

class AsyncStateError<T extends Equatable> extends AsyncState<T> {
  final Object _error;
  final StackTrace _stackTrace;
  const AsyncStateError(this._error, this._stackTrace) : super._();

  bool get isInitial {
    return false;
  }

  bool get isLoading {
    return false;
  }

  bool get hasValue {
    return false;
  }

  T? get value {
    return null;
  }

  bool get hasError {
    return true;
  }

  Object? get error {
    return this._error;
  }

  StackTrace? get stackTrace {
    return this._stackTrace;
  }

  @override
  List<Object> get props =>
      [isInitial, isLoading, hasValue, hasError, _error, _stackTrace];
}
