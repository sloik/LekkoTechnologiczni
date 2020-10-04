import 'dart:core';

extension IterableExtension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T mapper(int index, E element)) => toList()
      .asMap()
      .map((index, element) => MapEntry(index, mapper(index, element)))
      .values;
}