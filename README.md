# Invariant Collections

The repository `invariant_collection` provides the library
`invariant_list.dart`. Future versions of this repository will provide
similar libraries for other kinds of collections from 'dart:core'.

`invariant_list.dart` provides an extension type `IList<E>` which is
intended to be used as a replacement for types of the form `List<E>`
(where `List` is the built-in class of that name). An easy way to obtain an
expression of type `IList<T>` from an expression `e` of type `List<T>` for
some `T` is to use `e.iList`.

`IList<E>` differs from `List<E>` in that the former is invariant in its
type parameter, whereas the latter uses dynamically checked covariance.

It is well-known that dynamically checked covariance relies on run-time
type checks to ensure soundness of the heap in situations where the
available type information does not suffice to establish that guarantee at
compile-time. The standard example goes as follows:

```dart
void main() {
  List<num> xs = <int>[1];
  xs.add(1.5); // No compile-time error, yet throws at run time.
}
```

The corresponding example using the type `IList` differs by having a
compile-time error (which means that there will not be any run-time errors
because the unsafe kind of subtyping is prevented at compile tim):

```dart
void main() {
  IList<num> xs = <int>[1].iList; // Compile-time error.
  ... // It doesn't matter what we would have done.
}
```

