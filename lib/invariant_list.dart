// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// See https://github.com/dart-lang/sdk/issues/54543:
// ignore_for_file: unused_element

typedef _Inv<X> = X Function(X);
typedef IList<E> = _IList<E, _Inv<E>>;

extension type _IList<E, Invariance extends _Inv<E>>._(List<E> _it)
    implements List<E> {
  /// Create an [IList] by forwarding to [List.filled].
  _IList.filled(int length, E fill, {bool growable = false})
      : this._(List.filled(length, fill, growable: growable));

  /// Create an [IList] by forwarding to [List.empty].
  _IList.empty({bool growable = false})
      : this._(List.empty(growable: growable));

  /// Create an [IList] by forwarding to [List.from].
  _IList.from(Iterable elements, {bool growable = true})
      : this._(List.from(elements, growable: growable));

  /// Create an [IList] by forwarding to [List.of].
  _IList.of(Iterable<E> elements, {bool growable = true})
      : this._(List.of(elements, growable: growable));

  /// Create an [IList] by forwarding to [List.generate].
  _IList.generate(int length, E generator(int index), {bool growable = true})
      : this._(List.generate(length, generator, growable: growable));

  /// Create an [IList] by forwarding to [List.unmodifiable].
  _IList.unmodifiable(Iterable elements) : this._(List.unmodifiable(elements));

  /// Forward to [List.castFrom] and return the corresponding [IList].
  static IList<T> castFrom<S, T>(List<S> source) =>
      IList<T>._(List.castFrom(source));

  /// Forward to [List.copyRange].
  static void copyRange<T>(List<T> target, int at, List<T> source,
          [int? start, int? end]) =>
      List.copyRange(target, at, source, start, end);

  /// Forward to [List.writeIterable].
  static void writeIterable<T>(List<T> target, int at, Iterable<T> source) =>
      List.writeIterable(target, at, source);

  /// Forward to [List.cast] and return the corresponding [IList].
  IList<R> cast<R>() => IList._(_it.cast<R>());

  /// TODO(eernst): Implement this when `IIterable` is created.
  // IIterable<E> get reversed => _it.reversed.iIterable;

  /// Forward to [List.+] and return the corresponding [IList].
  IList<E> operator +(List<E> other) => IList._(_it + other);

  /// Forward to [List.sublist] and return the corresponding [IList].
  IList<E> sublist(int start, [int? end]) => IList._(_it.sublist(start, end));

  /// TODO(eernst): Enable this when `IIterable` is created.
  // IIterable<E> getRange(int start, int end) =>
  //     _it.getRange(start, end).iIterable;

  /// TODO(eernst): Enable this when `IMap` is created.
  // IMap<int, E> asMap() => _it.asMap().iMap;
}

extension IListExtension<T> on List<T> {
  IList<T> get iList => IList._(this);

  bool get isInvariant {
    // We need a fresh list in order to succeed even when `this`
    // is unmodifiable.
    var freshList = take(0).toList();
    try {
      freshList.addAll(<T>[]);
    } catch (_) {
      return false;
    }
    return true;
  }
}
