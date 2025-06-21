//
//  Weak.swift
//  ModernConcurrency
//
//  Created by lucas van Dongen on 05/06/2025.
//


class Weak<T: AnyObject> {
  weak var value : T?
  init (value: T) {
    self.value = value
  }
}