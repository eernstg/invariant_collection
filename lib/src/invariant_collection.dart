// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provide extension types as replacements for the built-in collection
/// classes as types, with better type safety.
library;

// See https://github.com/dart-lang/sdk/issues/54543:
// ignore_for_file: unused_element

// Use the same style as 'iterable.dart'.
// ignore_for_file: use_function_type_syntax_for_parameters

typedef _Inv<X> = X Function(X);

/// A replacement for the built-in class [Iterable] that offers improved
/// type safety because it is invariant in its type parameter.
typedef IIterable<E> = _IIterable<E, _Inv<E>>;

/// The underlying type that allows [IIterable] to be invariant.
extension type const _IIterable<E, Invariance extends _Inv<E>>._(
    Iterable<E> _it) implements Iterable<E> {
  /// Create an [IIterable] by forwarding to [Iterable.generate].
  _IIterable.generate(int count, [E generator(int index)?])
      : this._(Iterable.generate(count, generator));

  /// Create an [IIterable] by forwarding to [Iterable.empty].
  ///
  /// Note that the representation object has type argument `Never`, which
  /// is necessary because `Iterable<E>.empty()` is not constant.
  const _IIterable.empty() : this._(const Iterable<Never>.empty());

  /// Create an [IIterable] by forwarding to [Iterable.castFrom].
  static IIterable<T> castFrom<S, T>(Iterable<S> source) =>
      IIterable._(Iterable.castFrom<S, T>(source));

  /// Return an [IIterable] obtained by forwarding to [Iterable.cast].
  IIterable<R> cast<R>() => IIterable._(_it.cast<R>());

  /// Return an [IIterable] obtained by forwarding to [Iterable.followedBy].
  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  /// Return an [IIterable] obtained by forwarding to [Iterable.map].
  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  /// Return an [IIterable] obtained by forwarding to [Iterable.where].
  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  /// Return an [IIterable] obtained by forwarding to [Iterable.whereType].
  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());

  /// Return an [IIterable] obtained by forwarding to [Iterable.expand].
  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  /// Return an [IList] obtained by forwarding to [Iterable.toList].
  IList<E> toList({bool growable = true}) => _it.toList().iList;

  /// Return an [ISet] created by forwarding to [Iterable.toSet].
  // TODO: ISet<E> toSet() => _it.toSet().iSet;

  /// Return an [IIterable] obtained by forwarding to [Iterable.take].
  IIterable<E> take(int count) => IIterable._(_it.take(count));

  /// Return an [IIterable] obtained by forwarding to [Iterable.takeWhile].
  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  /// Return an [IIterable] obtained by forwarding to [Iterable.skip].
  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  /// Return an [IIterable] obtained by forwarding to [Iterable.skipWhile].
  IIterable<E> skipWhile(bool test(E value)) =>
      IIterable._(_it.skipWhile(test));

  /// Forward to [Iterable.iterableToShortString].
  static String iterableToShortString(Iterable iterable,
          [String leftDelimiter = '(', String rightDelimiter = ')']) =>
      Iterable.iterableToShortString(iterable, leftDelimiter, rightDelimiter);

  /// Forward to [Iterable.toFullString].
  static String iterableToFullString(Iterable iterable,
          [String leftDelimiter = '(', String rightDelimiter = ')']) =>
      Iterable.iterableToFullString(iterable, leftDelimiter, rightDelimiter);
}

/// Extension methods used with regular [Iterable] objects in
/// order to concisely obtain an expression of type [IIterable],
/// and in order to validate the invariance.
extension IIterableExtension<T> on Iterable<T> {
  /// Return the receiver with type [IIterable].
  IIterable<T> get iIterable => IIterable._(this);

  /// Return true if and only if this [Iterable] has a run-time type that
  /// implements `Iterable<T>`.  Another way to say the same thing (slightly
  /// less precisely) is that the type argument of this [Iterable] is exactly
  /// `T`, not a proper subtype of `T`.
  bool get isInvariant {
    var list = take(0).toList();
    try {
      list.addAll(<T>[]);
    } catch (_) {
      return false;
    }
    return true;
  }
}

/// A replacement for the built-in class [List] that offers improved
/// type safety because it is invariant in its type parameter.
typedef IList<E> = _IList<E, _Inv<E>>;

/// The underlying type that allows [IList] to be invariant.
extension type _IList<E, Invariance extends _Inv<E>>._(List<E> _it)
    implements List<E>, _IIterable<E, Invariance> {
  /// Create an [IList] from an existing [List], and assert invariance.
  _IList(this._it) : assert(_it.isInvariant, "Covariance detected!");

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

  /// Forward to [Iterable.reversed].
  IIterable<E> get reversed => _it.reversed.iIterable;

  /// Forward to [List.+] and return the corresponding [IList].
  IList<E> operator +(List<E> other) => IList._(_it + other);

  /// Forward to [List.sublist] and return the corresponding [IList].
  IList<E> sublist(int start, [int? end]) => IList._(_it.sublist(start, end));

  /// Forward to [Iterable.getRange].
  IIterable<E> getRange(int start, int end) =>
      _it.getRange(start, end).iIterable;

  /// TODO(eernst): Enable this when `IMap` is created.
  // IMap<int, E> asMap() => _it.asMap().iMap;

  // Forwarding methods, just needed in order to disambiguate.

  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  IIterable<E> skipWhile(bool test(E value)) =>
      IIterable._(_it.skipWhile(test));

  IIterable<E> take(int count) => IIterable._(_it.take(count));

  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  IList<E> toList({bool growable = true}) => _it.toList().iList;

  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());
}

/// Extension methods used with regular [List] objects
/// in order to concisely obtain an expression of type [IList],
/// and in order to validate the invariance.
extension IListExtension<T> on List<T> {
  /// Return the receiver with type [IList].
  IList<T> get iList => IList._(this);

  /// Return true if and only if this [List] has a run-time type that
  /// implements `List<T>`.  Another way to say the same thing (slightly
  /// less precisely) is that the type argument of this [List] is exactly
  /// `T`, not a proper subtype of `T`.
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

/// A replacement for the built-in class [Set] that offers improved
/// type safety because it is invariant in its type parameter.
typedef ISet<E> = _ISet<E, _Inv<E>>;

/// The underlying type that allows [ISet] to be invariant.
extension type const _ISet<E, Invariance extends _Inv<E>>._(Set<E> _it)
    implements Set<E>, _IIterable<E, Invariance> {
  /// Create an [ISet] by forwarding to [Set].
  _ISet() : this._(<E>{});

  /// Create an [ISet] by forwarding to [Set.identity].
  _ISet.identity() : this._(Set<E>.identity());

  /// Create an [ISet] by forwarding to [Set.from].
  _ISet.from(Iterable elements) : this._(Set.from(elements));

  /// Create an [ISet] by forwarding to [Set.of].
  _ISet.of(Iterable<E> elements) : this._(Set.of(elements));

  /// Create an [ISet] by forwarding to [Set.unmodifiable].
  _ISet.unmodifiable(IIterable<E> elements)
      : this._(Set<E>.unmodifiable(elements));

  /// Return an [ISet] obtained by forwarding to [Set.castFrom].
  static ISet<T> castFrom<S, T>(Set<S> source,
          {Set<R> Function<R>()? newSet}) =>
      ISet._(Set.castFrom<S, T>(source, newSet: newSet));

  /// Return an [ISet] obtained by forwarding to [Set.cast].
  ISet<R> cast<R>() => ISet._(_it.cast<R>());

  /// Removes [value] from the set by forwarding to [Set.remove].
  ///
  /// This forwarder is useful because it has parameter type `E` whereas
  /// [Set.remove] has parameter type `Object?`. The latter makes sense
  /// because [Set] is covariant in its type parameter, but [ISet] is
  /// invariant, and this implies that `remove(o)` on an object where
  /// `o is! E` will always return false (so it isn't useful to allow it).
  bool remove(E value) => _it.remove(value);

  /// If an object equal to [e] is in the set, return it.
  ///
  /// This forwarder is useful because it has parameter type `E` whereas
  /// [Set.lookup] has parameter type `Object?`. The latter makes sense
  /// because [Set] is covariant in its type parameter, but [ISet] is
  /// invariant, and this implies that `lookup(o)` on an object where
  /// `o is! E` will always return null (so it isn't useful to allow it).
  E? lookup(E e) => _it.lookup(e);

  /// Return an [ISet] by forwarding to [Set.intersection].
  ISet<E> intersection(Set<Object?> other) => ISet._(_it.intersection(other));

  /// Return an [ISet] by forwarding to [Set.union].
  ISet<E> union(Set<E> other) => ISet._(_it.union(other));

  /// Return an [ISet] by forwarding to [Set.difference].
  ISet<E> difference(Set<Object?> other) => ISet._(_it.difference(other));

  /// Return an [ISet] by forwarding to [Set.toSet].
  ISet<E> toSet() => ISet._(_it.toSet());

  // Forwarding methods, just needed in order to disambiguate.

  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  IIterable<E> skipWhile(bool test(E value)) =>
      IIterable._(_it.skipWhile(test));

  IIterable<E> take(int count) => IIterable._(_it.take(count));

  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  IList<E> toList({bool growable = true}) => _it.toList().iList;

  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());
}

/// Extension methods used with regular [Set] objects
/// in order to concisely obtain an expression of type [ISet],
/// and in order to validate the invariance.
extension ISetExtension<T> on Set<T> {
  /// Return the receiver with type [ISet].
  ISet<T> get iSet => ISet._(this);

  /// Return true if and only if this [List] has a run-time type that
  /// implements `List<T>`.  Another way to say the same thing (slightly
  /// less precisely) is that the type argument of this [List] is exactly
  /// `T`, not a proper subtype of `T`.
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
