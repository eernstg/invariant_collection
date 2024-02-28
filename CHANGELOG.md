## 1.0.9

- Improve README.md.

## 1.0.8

- Reorganize libraries in order to enable `implements` of private types.
  This is needed in order to make `IList<T>` assignable to `IIterable<T>`,
  and similarly for other collection types.
- Add library `invariant_set.dart`, providing the extension type `ISet`.

## 1.0.7

- Add library `invariant_iterable.dart`, providing the extension type
  `IIterable`. Add members of `IList` where this type is used.

## 1.0.6

- Add library `invariant_collection.dart`, exporting `invariant_list.dart`.
  This library will export all the other libraries in this package.

## 1.0.5

- Update README.md text about the assertion.

## 1.0.4

- Extended and improved README.md.
- Added `IList` constructor that asserts `isInvariant`, to enable a safe way
  (when assertions are enabled) to obtain an `IList` from a given `List`.

## 1.0.3

- Extended README.md further.

## 1.0.2

- Extended README.md substantially.

## 1.0.1

- Add DartDoc comments.

## 1.0.0

- Initial version.
