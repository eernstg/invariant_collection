// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:invariant_collection/invariant_list.dart';

void main() {
  var xs = [1, 2, 3].iList;
  // IList<num> ys = xs; // Compile-time error.
  var zs = xs.sublist(1, 2); // OK, has type `IList<int>`.
  print(zs.last); // All `List` members are available.
}
