# Invariant Collections

The repository `invariant_collection` provides the libraries
`invariant_iterable.dart`, `invariant_list.dart`, `invariant_set.dart`,
`invariant_map.dart`, and `invariant_collection.dart` (exporting all the
others). Future versions of this repository may provide similar libraries
for other kinds of collections from 'dart:core'.

`invariant_list.dart` provides an extension type `IList<E>` which is
intended to be used as a replacement for types of the form `List<E>` (where
`List` is the built-in class of that name). `IList<E>` is invariant in its
type parameter, whereas `List<E>` uses dynamically checked covariance. An
easy way to obtain an expression of type `IList<T>` from an expression `e`
of type `List<T>` is to use `e.iList`.

All other kinds of collections in this package are similar. They use the
same naming scheme and provide the same kind of typing and semantic
properties.

## Motivation: Type safety

The purpose of this package is to improve the static type safety of Dart
programs when they are using collections (`List`, `Map` and so on). Without
this package, Dart collection classes (and indeed all Dart classes) are
covariant in their type parameters. For example `List<int>` is a subtype of
`List<num>` because `int` is a subtype of `num`. This is very convenient,
and it is both natural and safe to treat a `List<int>` as if it were a
`List<num>` in many situations.

However, it isn't safe in all situations. In other words, dynamically
checked covariance is not statically type safe: We can have a program with
no compile-time errors which will incur a type error at run time. Example:

```dart
void main() {
  List<num> xs = <int>[1];
  xs.add(1.5); // No compile-time error, yet throws at run time.
}
```

This package provides several extension type declarations which may be used
in order to adapt the static analysis of collection types such that they
are invariant in their type parameters. With that treatment, the above kind
of run-time error does not occur. This is because the step where covariance
is introduced becomes a compile-time error, and we can't have run-time
failures caused by dynamically checked covariance in a program execution
where said covariance hasn't been introduced. Using this approach, the
example above looks as follows:

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
`List.add` and `Map.addAll` and operator `[]=` are unsafe when covariance
is present. Collections that are treated as read-only can be allowed to use
covariance because that is generally safe.

The precise borderline between safe and unsafe relies on the detailed
structure of the types in the member signatures, and on whether or not any
covariant type variables occur in a non-covariant position, but this
document is not the place to unfold all the details.

## Preserving a property, not necessarily checking it at each step

Let's pretend that `x` should be an even number at all times. Here's a
snippet of code where we can think about this claim and consider whether
it's maintained or violated, and where.

```dart
class A {
  int next(int i) => i * 2; // Ensure evenness.
}

// This class could be declared in some other library,
// we may not know that it exists.
class B implements A {
  int next(int i) => 13; // Destroys evenness!
}

void main() {
  var x = 2; // True at first.
  A a = ...; // Some complex expression.
  x += 14; // Preserves evenness.
  x = a.next(x); // OK?
  x -= 14; // Preserves evenness (if we still have it).
  if (!x.isEven) throw StateError("x is not even!");
}
```

Just like a proof by induction, we can check that the initial state
(at the declaration and initialization of `x`) satisfies the
requirement, and then check that every subsequent step preserves the
requirement. An inspection of `A.next(_)` confirms that `x` remains
even, which is also true for `x += 14` and `x -= 14`.

Hence, a (superficial) static analysis seems to confirm that the evenness
property is preserved all the way.

However, if the value of `a` is actually an instance of `B` then
`a.next(x)` will return a value which isn't even, and then we may stay off
track (such that the evenness requirement is violated) for any number of
steps.

Finally, we can directly check at any particular point in time whether the
evenness requirement is satisfied (`isEven`), and otherwise take some
recovery or panic steps in response to that failure, e.g., throwing a state
error.

The point is that we can ensure that a property holds if it holds "at the
beginning", and each step that we may execute is guaranteed to preserve
that property.

If some steps are not guaranteed to preserve the property then we can still
ensure that the property holds by checking the property from scratch after
each unsafe step. Assuming that `isEven` could be a really expensive
computation, we'd very much like to perform these checks only when
necessary; we might even tolerate that the property is violated for some
limited number of steps (so we check after `x -= 14` even though that's a
safe step, because we must check at some point after `x = a.next(x)`).

It is crucial that preservation of a property can be much cheaper than a
from-scratch check at every step. In particular, `x.isEven` is a run-time
computation, but with `x += 14` it can be proven at compile time that it
will preserve the evenness of `x`, and the cost associated with this
knowledge is zero at run time.

The structure of the guarantees provided by invariant collection types like
`IList` is very similar. It's all about proving at compile time that the
invariance property is preserved, for all operations that are checked
statically. Some steps are dynamic (e.g., type casts), and they must be
followed up by a from-scratch check (`isInvariant`).

Here's how it plays out in practice. First consider the initial state.
There's no way we can prevent at compile time that an expression with
static type `List<num>` has run-time type `List<int>`, that's just a
property of the Dart `List` class, and we can't change that. Also, it is
not possible to _detect_ this situation at compile time, due to the
underlying undecidability.

This means that it is always possible to create an `IList<num>` whose
actual type argument is not `num` but some subtype of `num`, even though
the static types imply that no such covariance exists.

```dart
void main() {
  List<num> xs = <int>[1]; // We can't turn this into an error.
  var ys = IList<num>(xs); // Statically OK.
  print(ys.isInvariant); // 'false'!
}
```

It is possible to perform a from-scratch check by means of
`isInvariant`. Another way to establish a safe initial state is to use an
`IList` constructor, e.g., `IList<num>.filled(10, 0.1)`.

Note that the `IList` constructor will throw if assertions are enabled,
because it asserts that the given list `isInvariant`.

Now let's assume that we have established the desired invariance property
initially. Subsequent steps may then be statically known to preserve the
property, or they might be unsafe, and we can deal with that just like
'evenness':

```dart
import 'package:invariant_collection/invariant_list.dart';

class A {
  IList<num> next(IList<num> xs) => xs.take(0).toList().iList;
}

class B implements A {
  IList<num> next(IList<num> xs) => (<int>[] as List<num>).iList;
}

void main() {
  var xs = <num>[1, 2, 3.5].iList; // Invariant at first.
  A a = ...; // Some complex expression.
  xs.add(14); // Same `xs`, preserves invariance.
  xs = a.next(xs); // OK?
  xs.remove(14); // Same `xs`, preserves invariance (if we have it).
  if (!xs.isInvariant) throw StateError("xs is not invariant!");
}
```

Again, if `a` is an instance of `B` then the invariance property is
violated at `xs = a.next(xs)`, and it takes a from-scratch check
(`isInvariant`) to determine whether or not we still have it.

Well, the invariant is actually violated in the body of `B.next`, because
we're using `iList` on an object whose static type is `List<num>`, whereas
the run-time type has the type argument `int`. So we're again checking a
few steps after the problem actually arises, which is enough as long as we
don't forget to perform the check entirely. Of course, `B.next` is a bug,
and it should be fixed.

The step where an `IList<T>` is assigned to a variable of type `IList<T>`
or `IIterable<T>` is safe (it preserves the invariance). This includes the
step where an `IList<num>` is returned from `B.next`, and the value
returned by `a.next(xs)` in `main` is assigned to `xs`. However, this
_preserves_ the invariance, but doesn't check the invariance from scratch,
and this means that we need to verify the invariance after the unsafe step
in the body, which is the cast.

An important special case arises when the invariant is never in doubt: If
the initial state is correct (say, a variable `IList<T> x` satisfies the
invariance requirement), and no changes are made to the identity of the
object (say, it's a `final` variable), then the invariance requirement is
trivially guaranteed to hold at all times. Similarly if a variable is only
assigned from sources that are known to satisfy the requirement. And so on.

The point is that preservation of invariance is ensured for most
computational steps, at a zero cost at run time, but it is necessary to
keep an eye on certain steps that are unsafe. The underlying assumption for
`invariant_collection` is that this is a worthwhile improvement over the
situation where every collection can be covariantly typed in all
situations.

## Migration

Note that `IList<T>` is a subtype of `List<T>` for all `T`. This means that
a given library _L_ can be modified to use `IList<T>` rather than `List<T>`
as return types (especially, for lists that are subject to mutation).
Internal computations (using local variables, private methods) can use
`IList<T>` rather than `List<T>` everywhere (again, especially for lists
that are mutated). In code that interacts with other libraries, an
`IList<T>` can be passed when a `List<S>` is expected whenever `T` is a
subtype of `S`. This could occur, say, because the callee hasn't been
updated yet, or because they don't plan to mutate that list. Next, an
`IList<T>` can of course also be passed to other libraries when an
`IList<T>` is expected, which would be the case when multiple libraries
have switched to use `invariant_collection` (and they are now helping each
other to preserve the invariance property for lists that need it).

If a `List<T>` is available in _L_, and it should be passed as an actual
argument to a method in some other library which is expecting an
`IList<T>`, then we will get a compile-time error (`List<T>` is not
assignable to `IList<T>`). This is a _good_ kind of breakage because it
most likely indicates that this other library intends to mutate the list,
and hence they need to receive the list with a static type which is
invariant. We may then check that the given list is indeed invariant, and
give it the type `IList<T>`, and pass it&mdash;safely.
