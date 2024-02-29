// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:invariant_collection/invariant_collection.dart';

void main() {
  // Use `IList` rather than `List` to prevent dynamic type errors.
  var list = [1, 2, 3].iList; // Turn `List` into `IList`: Use `.iList`.
  // IList<num> list2 = list; // Compile-time error: Preserves invariance.
  var list3 = list.sublist(1, 2); // OK, has type `IList<int>`.
  print(list3.last); // All `List` members are available. Prints '2'.
  list.add(1); // OK at compile time, and safe at run time.

  // Use `ISet` rather than `Set` to prevent dynamic type errors.
  var set = <num>{6, 7}.iSet; // Turn `Set` into `ISet`.
  set.add(1.5); // OK at compile time and safe at run time.
  set.addAll(list); // OK, parameter type is covariant. Safe.
  print(set); // Prints '{6, 7, 1.5, 1, 2, 3}'.
  var set2 = ISet.of(list); // OK, has type `ISet<int>`.
  // set = set2; // Compile-time error: Preserves invariance.

  // Use `IIterable` rather than `Iterable` to preserve invariance, e.g.,
  // if `toList` is used to obtain a list later on.
  var iterable = set.map((n) => n.floor() + 0.5); // `IIterable<num>`.
  print(iterable); // Prints '6.5, 7.5, 1.5, 1.5, 2.5, 3.5)'.
  var list4 = iterable.toList(); // `IList<num>`.
  list4.add(4.5); // OK at compile time and safe at run time.

  // Use `IMap` rather than `Map` to prevent dynamic type errors.
  var map = <String, num>{'test': 4, 'x': 1, 'foo': 3}.iMap;
  // IMap<String, Object> map2 = map; // Error: Preserves invariance.
  map['arglebargle'] = 11.5; // OK at compile time, and safe at run time.

  // When assertions are enabled, failure to satisfy the invariance
  // requirement is detected by `iIterable`, `iList`, `iSet`, `iMap`.
  try {
    List<num> list = <int>[42];
    var bad = list.iList; // Assertion requires invariance.
  } catch (_) {
    print('Detected bad list.');
  }
  
  try {
    Set<num> set = <int>{42};
    var bad = set.iSet; // Assertion requires invariance.
  } catch (_) {
    print('Detected bad set.');
  }

  try {
    Iterable<num> iterable = <int>[42];
    var bad = iterable.iIterable; // Assertion requires invariance.    
  } catch (_) {
    print('Detected bad iterable.');
  }

  try {
    Map<Object, num> map = <String, num>{'Hello': 42.43};
    var bad = map.iMap; // Assertion requires invariance.
  } catch (_) {
    print('Detected bad map key type.');
  }

 try {
    Map<Object, num> map = <Object, int>{'Hello': 44};
    var bad = map.iMap; // Assertion requires invariance.
  } catch (_) {
    print('Detected bad map value type.');
  }
}
