// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provide an extension type [IIterable] as a replacement for the
/// built-in class [Iterable] as a type, with better type safety.
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
extension type _IIterable<E, Invariance extends _Inv<E>>._(Iterable<E> _it)
    implements Iterable<E> {
  const _IIterable() : this._(const Iterable());

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
      _IIterable._(Iterable.castFrom<S, T>(source));

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
