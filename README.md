# Invariant Collections

The repository `invariant_collection` provides the library
`invariant_list.dart`. Future versions of this repository will provide
similar libraries for other kinds of collections from 'dart:core'.

The purpose of this package is to improve the static type safety of Dart
programs when they are using collections (`List`, `Map` and so on). Without
this package, Dart collection classes (and indeed all classes) are
covariant in their type parameters. For example `List<int>` is a subtype of
`List<num>` because `int` is a subtype of `num`. This is very convenient,
and it is both natural and safe to treat a `List<int>` as if it were a
`List<num>` in many situations.

However, it isn't safe in all situations. In other words, dynamically
checked covariance is not statically type safe: We can have a program with
no compile-time errors which will incur a type error at run time:

```dart
void main() {
  List<num> xs = <int>[1];
  xs.add(1.5); // No compile-time error, yet throws at run time.
}
```

This package provides several extension type declarations which may be used
in order to adapt the static analysis of collection types such that they
are invariant in their type parameters. With that treatment, the above kind
of run-time error does not occur. This is because the step where the
covariance is introduced becomes a compile-time error, and we can't have
run-time failures caused by dynamically checked covariance in a program
execution where said covariance hasn't been introduced. Using this
approach, the example above looks as follows:

```dart
import 'package:invariant_collection/invariant_list.dart';

void main() {
  IList<num> xs = <int>[1].iList; // Compile-time error.
  xs.add(1.5); // Irrelevant, `xs` is already an error.
}
```

The other side of the coin is that invariance is less flexible, which means
that it is a non-trivial trade-off: Do you want to continue to use this
collection in the covariant way which is convenient and natural, but which
may give rise to run-time type errors? Or are you ready to take the more
strict invariant route?

In general, collections should be typed invariantly when they are being
mutated (in particular, when new elements are added), because methods like
`List.add` and `Map.[]=` are unsafe when covariance is present. Collections
that are treated as read-only can be allowed to use covariance because
that is generally safe.

(The precise borderline between safe and unsafe relies on the detailed
structure of the types in the member signatures, and on whether or not any
covariant type variables occur in a non-covariant position, but this
document is not the place to unfold all the details.)

Concretely, `invariant_list.dart` provides an extension type `IList<E>`
which is intended to be used as a replacement for types of the form
`List<E>` (where `List` is the built-in class of that name). `IList<E>`
differs from `List<E>` in that the former is invariant in its type
parameter, whereas the latter uses dynamically checked covariance. An easy
way to obtain an expression of type `IList<T>` from an expression `e` of
type `List<T>` for some `T` is to use `e.iList`.
