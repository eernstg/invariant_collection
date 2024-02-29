// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provide extension types as replacements for the built-in collection
/// classes as types, with better type safety.
library;

import 'package:meta/meta.dart';

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
  @redeclare
  IIterable<R> cast<R>() => IIterable._(_it.cast<R>());

  /// Return an [IIterable] obtained by forwarding to [Iterable.followedBy].
  @redeclare
  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  /// Return an [IIterable] obtained by forwarding to [Iterable.map].
  @redeclare
  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  /// Return an [IIterable] obtained by forwarding to [Iterable.where].
  @redeclare
  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  /// Return an [IIterable] obtained by forwarding to [Iterable.whereType].
  @redeclare
  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());

  /// Return an [IIterable] obtained by forwarding to [Iterable.expand].
  @redeclare
  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  /// Return an [IList] obtained by forwarding to [Iterable.toList].
  @redeclare
  IList<E> toList({bool growable = true}) => _it.toList().iList;

  /// Return an [ISet] created by forwarding to [Iterable.toSet].
  @redeclare
  ISet<E> toSet() => _ISet._(_it.toSet());

  /// Return an [IIterable] obtained by forwarding to [Iterable.take].
  @redeclare
  IIterable<E> take(int count) => IIterable._(_it.take(count));

  /// Return an [IIterable] obtained by forwarding to [Iterable.takeWhile].
  @redeclare
  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  /// Return an [IIterable] obtained by forwarding to [Iterable.skip].
  @redeclare
  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  /// Return an [IIterable] obtained by forwarding to [Iterable.skipWhile].
  @redeclare
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
  String get _covarianceString => 'expected Iterable<$T>, got $runtimeType';

  /// Return the receiver with type [IIterable].
  IIterable<T> get iIterable {
    assert(isInvariant, "Covariance detected: $_covarianceString");
    return IIterable<T>._(this);
  }

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
  _IList(this._it) : assert(
      _it.isInvariant, "Covariance detected: ${_it._covarianceString}");

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
  @redeclare
  IList<R> cast<R>() => IList._(_it.cast<R>());

  /// Forward to [Iterable.reversed] and return the corresponding [IIterable].
  @redeclare
  IIterable<E> get reversed => IIterable<E>._(_it.reversed);

  /// Forward to [List.+] and return the corresponding [IList].
  @redeclare
  IList<E> operator +(List<E> other) => IList._(_it + other);

  /// Forward to [List.sublist] and return the corresponding [IList].
  @redeclare
  IList<E> sublist(int start, [int? end]) => IList._(_it.sublist(start, end));

  /// Forward to [Iterable.getRange] and return the corresponding [IIterable].
  @redeclare
  IIterable<E> getRange(int start, int end) =>
      IIterable<E>._(_it.getRange(start, end));

  /// Forward to [Map.asMap] and return the corresponding [IMap].
  @redeclare
  IMap<int, E> asMap() => _IMap._(_it.asMap());

  // Forwarding methods, just needed in order to disambiguate.

  @redeclare
  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  @redeclare
  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  @redeclare
  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  @redeclare
  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  @redeclare
  IIterable<E> skipWhile(bool test(E value)) =>
      IIterable._(_it.skipWhile(test));

  @redeclare
  IIterable<E> take(int count) => IIterable._(_it.take(count));

  @redeclare
  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  @redeclare
  IList<E> toList({bool growable = true}) => _it.toList().iList;

  @redeclare
  ISet<E> toSet() => _ISet._(_it.toSet());

  @redeclare
  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  @redeclare
  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());
}

/// Extension methods used with regular [List] objects
/// in order to concisely obtain an expression of type [IList],
/// and in order to validate the invariance.
extension IListExtension<T> on List<T> {
  String get _covarianceString => 'expected List<$T>, got $runtimeType';

  /// Return the receiver with type [IList].
  IList<T> get iList {
    assert(isInvariant, "Covariance detected: $_covarianceString");
    return IList<T>._(this);
  }

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
  /// Create an empty [ISet].
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
  @redeclare
  ISet<R> cast<R>() => ISet._(_it.cast<R>());

  /// Removes [value] from the set by forwarding to [Set.remove].
  ///
  /// This forwarder is useful because it has parameter type `E` whereas
  /// [Set.remove] has parameter type `Object?`. The latter makes sense
  /// because [Set] is covariant in its type parameter, but [ISet] is
  /// invariant, and this implies that `remove(o)` on an object where
  /// `o is! E` will always return false (so it isn't useful to allow it).
  @redeclare
  bool remove(E value) => _it.remove(value);

  /// If an object equal to [e] is in the set, return it.
  ///
  /// This forwarder is useful because it has parameter type `E` whereas
  /// [Set.lookup] has parameter type `Object?`. The latter makes sense
  /// because [Set] is covariant in its type parameter, but [ISet] is
  /// invariant, and this implies that `lookup(o)` on an object where
  /// `o is! E` will always return null (so it isn't useful to allow it).
  @redeclare
  E? lookup(E e) => _it.lookup(e);

  /// Return an [ISet] by forwarding to [Set.intersection].
  @redeclare
  ISet<E> intersection(Set<Object?> other) => ISet._(_it.intersection(other));

  /// Return an [ISet] by forwarding to [Set.union].
  @redeclare
  ISet<E> union(Set<E> other) => ISet._(_it.union(other));

  /// Return an [ISet] by forwarding to [Set.difference].
  @redeclare
  ISet<E> difference(Set<Object?> other) => ISet._(_it.difference(other));

  /// Return an [ISet] by forwarding to [Set.toSet].
  @redeclare
  ISet<E> toSet() => ISet._(_it.toSet());

  // Forwarding methods, just needed in order to disambiguate.

  @redeclare
  IIterable<T> expand<T>(Iterable<T> toElements(E element)) =>
      IIterable._(_it.expand<T>(toElements));

  @redeclare
  IIterable<E> followedBy(Iterable<E> other) =>
      IIterable._(_it.followedBy(other));

  @redeclare
  IIterable<T> map<T>(T toElement(E e)) => IIterable._(_it.map<T>(toElement));

  @redeclare
  IIterable<E> skip(int count) => IIterable._(_it.skip(count));

  @redeclare
  IIterable<E> skipWhile(bool test(E value)) =>
      IIterable._(_it.skipWhile(test));

  @redeclare
  IIterable<E> take(int count) => IIterable._(_it.take(count));

  @redeclare
  IIterable<E> takeWhile(bool test(E value)) =>
      IIterable._(_it.takeWhile(test));

  @redeclare
  IList<E> toList({bool growable = true}) => _it.toList().iList;

  @redeclare
  IIterable<E> where(bool test(E element)) => IIterable._(_it.where(test));

  @redeclare
  IIterable<T> whereType<T>() => IIterable._(_it.whereType<T>());
}

/// Extension methods used with regular [Set] objects
/// in order to concisely obtain an expression of type [ISet],
/// and in order to validate the invariance.
extension ISetExtension<T> on Set<T> {
  String get _covarianceString => 'expected Set<$T>, got $runtimeType';

  /// Return the receiver with type [ISet].
  ISet<T> get iSet {
    assert(isInvariant, "Covariance detected: $_covarianceString");
    return ISet<T>._(this);
  }

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

/// A replacement for the built-in class [Map] that offers improved
/// type safety because it is invariant in its type parameters.
typedef IMap<K, V> = _IMap<K, V, _Inv<(K, V)>>;

extension type const _IMap<K, V, Invariance extends _Inv<(K, V)>>._(
    Map<K, V> _it) implements Map<K, V> {
  /// Create an empty [IMap].
  _IMap() : this._(<K, V>{});

  /// Create an [IMap] by forwarding to [Map.from].
  _IMap.from(Map other) : this._(Map<K, V>.from(other));

  /// Create an [IMap] by forwarding to [Map.of].
  _IMap.of(Map<K, V> other) : this._(Map<K, V>.of(other));

  /// Create an [IMap] by forwarding to [Map.unmodifiable].
  _IMap.unmodifiable(Map other) : this._(Map<K, V>.unmodifiable(other));

  /// Create an [IMap] by forwarding to [Map.identity].
  _IMap.identity() : this._(Map<K, V>.identity());

  /// Create an [IMap] by forwarding to [Map.fromIterable].
  ///
  /// The constructor [Map.fromIterable] has weak typing (e.g., the `key`
  /// function must accept any object whatsoever). This static method has a
  /// similar behavior and typing, but introduces one more type argument
  /// [T], in order to enable a more precise typing. If an invocation of
  /// [Map.fromIterable] is replaced by an invocation of `IMap.fromIterable`
  /// then the type arguments must be adjusted (except if they are inferred)
  /// and the body of function literals passed to [key] and [value] will
  /// have more precise typing because the argument has type [T] rather than
  /// `dynamic`.
  static IMap<K, V> fromIterable<K, V, T>(Iterable<T> iterable,
      {K Function(T)? key, V Function(T)? value}) {
    K Function(dynamic)? theKey = key == null ? null : (t) => key(t as T);
    V Function(dynamic)? theValue = value == null ? null : (t) => value(t as T);
    return _IMap._(Map.fromIterable(iterable, key: theKey, value: theValue));
  }

  /// Create an [IMap] by forwarding to [Map.fromIterables].
  _IMap.fromIterables(Iterable<K> keys, Iterable<V> values)
      : this._(Map<K, V>.fromIterables(keys, values));

  /// Obtains an [IMap] by forwarding to [Map.castFrom].
  static IMap<K2, V2> castFrom<K, V, K2, V2>(Map<K, V> source) =>
      _IMap._(Map.castFrom<K, V, K2, V2>(source));

  /// Create an [IMap] by forwarding to [Map.fromEntries].
  _IMap.fromEntries(Iterable<MapEntry<K, V>> entries)
      : this._(Map<K, V>.fromEntries(entries));

  /// Creates an [IMap] by forwarding to [Map.cast].
  @redeclare
  IMap<RK, RV> cast<RK, RV>() => _IMap._(_it.cast<RK, RV>());

  /// Forward to [Map.entries] and return the corresponding [IIterable].
  @redeclare
  IIterable<MapEntry<K, V>> get entries => _IIterable._(_it.entries);

  /// Forward to [Map.map] and return the corresponding [IMap].
  @redeclare
  IMap<K2, V2> map<K2, V2>(MapEntry<K2, V2> convert(K key, V value)) =>
      _IMap._(_it.map(convert));

  /// Forward to [Map.keys] and return the corresponding [IIterable].
  ///
  /// An assertion is made that `_it.keys` returns a result which is typed
  /// invariantly (there is no guarantee for that).
  @redeclare
  IIterable<K> get keys {
    var result = _it.keys;
    assert(result.isInvariant, "Covariance detected: ${result._covarianceString}");
    return IIterable<K>._(result);
  }

  /// Forward to [Map.values] and return the corresponding [IIterable].
  ///
  /// An assertion is made that `_it.values` returns a result which is typed
  /// invariantly (there is no guarantee for that).
  @redeclare
  IIterable<V> get values {
    var result = IIterable<V>._(_it.values);
    assert(result.isInvariant, "Covariance detected: ${result._covarianceString}");
    return result;
  }

  // TODO: Not needed, I think:
  // bool containsValue(Object? value);
  // bool containsKey(Object? key);
  // V? operator [](Object? key);
  // void operator []=(K key, V value);
  // void addEntries(Iterable<MapEntry<K, V>> newEntries);
  // V update(K key, V update(V value), {V ifAbsent()?});
  // void updateAll(V update(K key, V value));
  // void removeWhere(bool test(K key, V value));
  // V putIfAbsent(K key, V ifAbsent());
  // void addAll(Map<K, V> other);
  // V? remove(Object? key);
  // void clear();
  // void forEach(void action(K key, V value));
  // int get length;
  // bool get isEmpty;
  // bool get isNotEmpty;
}

/// Extension methods used with regular [Iterable] objects in
/// order to concisely obtain an expression of type [IIterable],
/// and in order to validate the invariance.
extension IMapExtension<K, V> on Map<K, V> {
  String get _covarianceString => 'expected Map<$K, $V>, got $runtimeType';

  /// Return the receiver with type [IMap].
  IMap<K, V> get iMap {
    assert(isInvariant, "Covariance detected: $_covarianceString");
    return IMap<K, V>._(this);
  }

  /// Return true if and only if this [Map] has a run-time type that
  /// implements `Map<K, V>`.  Another way to say the same thing (slightly
  /// less precisely) is that the type arguments of this [Map] are exactly
  /// `K` and `V`, not a proper subtype thereof.
  bool get isInvariant {
    // We rely on `entries` to return an `Iterable<MapEntry<K0, V0>>`
    // where `K0` and `V0` are the actual values of `K` respectively `V`.
    var list = entries.take(0).toList();
    try {
      list.addAll(<MapEntry<K, V>>[]);
    } catch (_) {
      return false;
    }
    return true;
  }
}
