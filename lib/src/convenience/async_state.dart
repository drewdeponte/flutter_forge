import 'package:equatable/equatable.dart';

abstract class AsyncState<T extends Object> extends Equatable {
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
    if (isInitial) {
      return initial();
    } else if (isLoading) {
      return loading();
    } else if (hasError) {
      return error(error, stackTrace!);
    } else {
      return data(value!);
    }
  }
}

class AsyncStateInitial<T extends Object> extends AsyncState<T> {
  const AsyncStateInitial() : super._();

  @override
  bool get isInitial {
    return true;
  }

  @override
  bool get isLoading {
    return false;
  }

  @override
  bool get hasValue {
    return false;
  }

  @override
  T? get value {
    return null;
  }

  @override
  bool get hasError {
    return false;
  }

  @override
  Object? get error {
    return null;
  }

  @override
  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError];
}

class AsyncStateLoading<T extends Object> extends AsyncState<T> {
  const AsyncStateLoading() : super._();

  @override
  bool get isInitial {
    return false;
  }

  @override
  bool get isLoading {
    return true;
  }

  @override
  bool get hasValue {
    return false;
  }

  @override
  T? get value {
    return null;
  }

  @override
  bool get hasError {
    return false;
  }

  @override
  Object? get error {
    return null;
  }

  @override
  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError];
}

class AsyncStateData<T extends Object> extends AsyncState<T> {
  const AsyncStateData(this._value) : super._();
  final T _value;

  @override
  bool get isInitial {
    return false;
  }

  @override
  bool get isLoading {
    return false;
  }

  @override
  bool get hasValue {
    return true;
  }

  @override
  T? get value {
    return _value;
  }

  @override
  bool get hasError {
    return false;
  }

  @override
  Object? get error {
    return null;
  }

  @override
  StackTrace? get stackTrace {
    return null;
  }

  @override
  List<Object> get props => [isInitial, isLoading, hasValue, hasError, _value];
}

class AsyncStateError<T extends Object> extends AsyncState<T> {
  final Object _error;
  final StackTrace _stackTrace;
  const AsyncStateError(this._error, this._stackTrace) : super._();

  @override
  bool get isInitial {
    return false;
  }

  @override
  bool get isLoading {
    return false;
  }

  @override
  bool get hasValue {
    return false;
  }

  @override
  T? get value {
    return null;
  }

  @override
  bool get hasError {
    return true;
  }

  @override
  Object? get error {
    return _error;
  }

  @override
  StackTrace? get stackTrace {
    return _stackTrace;
  }

  @override
  List<Object> get props =>
      [isInitial, isLoading, hasValue, hasError, _error, _stackTrace];
}
