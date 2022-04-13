[![CI](https://github.com/DimaKoroliov/PersistedValue/workflows/CI/badge.svg)](https://github.com/DimaKoroliov/PersistedValue/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/DimaKoroliov/PersistedValue/branch/main/graph/badge.svg?token=TQQSUBYMPU)](https://codecov.io/gh/DimaKoroliov/PersistedValue)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FDimaKoroliov%2FPersistedValue%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/DimaKoroliov/PersistedValue)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FDimaKoroliov%2FPersistedValue%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/DimaKoroliov/PersistedValue)

A simple way to have persisted data in different storages (like Keychain or UserDefaults) that can be easily extended or tested.

* [Motivation](#motivation)
* [Usage](#usage)
  * [`AnyPersistedValue`](#anypersistedvalue)
  * [`Mocks`](#mocks)
* [Requirements](#requirements)
* [Installation](#installation)
* [Alternatives](#alternatives)

## Motivation
We can have different types of storages (UserDefaults, NSCache, Keychain etc) for storing some simple data by key. But each of these stores has its own API.

This is the moment when `PersistedStorage` and `PersistedValue` can help. Caller side of this protocol knows nothing about the type of storage as the API will be the same. It also solved a problem with persisted type and you can store any type you want without changing API.

## Usage
`PersistedValue` has a number of operators that can simplify usage. Here an example some of them:

```swift
 let persistedValue = storage.persistedValue(forKey: "key")
     // store Codable types
     .codable(Model.self)
     // provides default value
     .default(Model())
     // print setters and getter in console
     .print()

 // reads current value
 let model = persistedValue.wrappedValue

 // writes a new value
 persistedValue.wrappedValue = Model()
```

Highly recommend wrapping persisted values in separate service. It'll be single source of truth and can be easily injected.

```swift
protocol PersistedValuesServiceProtocol {
  var userToggle: AnyPersistedValue<Bool> { get }
  var userId: AnyPersistedValue<String?> { get }
  var token: PersistedValues.Subject<Token?> { get }
}

final class PersistedValuesService: PersistedValuesServiceProtocol {

  let userToggle: AnyPersistedValue<Bool>
  let userId: AnyPersistedValue<String?>
  let token: PersistedValues.Subject<Token?>

  init(
    keychain: PersistedStorage,
    userDefaults: PersistedStorage
  ) {
    self.userToggle = userDefaults.persistedValue(forKey: "user_toogle")
      .bool()
      .default(false)
      .eraseToAnyPersistedValue()

    self.userId = keychain.persistedValue(forKey: "user_id")
      .string()
      .eraseToAnyPersistedValue()

    self.token = keychain.persistedValue(forKey: "token")
      .codable(Token.self)
      .subject(didChage: keychain.didChange(forKey: "token"))
  }
}

struct Token: Codable {
  let access: String
}

struct SomeViewModel {
  private let persistedValues: PersistedValuesServiceProtocol

  init(persistedValues: PersistedValuesServiceProtocol) {
    self.persistedValues = persistedValues
  }

  func logOut() {
    self.persistedValues.userId.wrappedValue = nil
  }
}
```

### AnyPersistedValue
The `AnyPersistedValue` provides a type-erasing wrapper for the `PersistedValue` protocol, that helps to avoid introducing generics in your code in some cases like this:

```swift
class SomeViewModel<PV> where PV: PersistedValue, Value == String? {
  private let userId: PV

  init(userId: PV) {
    self.userId = userId
  }

  func logOut() {
    self.userId.wrappedValue = nil
  }
}
```

This generic `SomeViewModel<PersistedValue>` will be hard to have as a property and you don't get benefits by this generic model. So it can be refactored with `AnyPersistedValue` in this way:

```swift
class SomeViewModel {
  private let userId: AnyPersistedValue<String?>

  init<PV>(userId: PV) where PV: PersistedValue, Value == String? {
    self.userId = userId.eraseToAnyPersistedValue()
  }

  func logOut() {
    self.userId.wrappedValue = nil
  }
}
```

## Mocks
For testing proposals you can use `MockPersistedStorage` and `MockPersistedValue` from `PersistedValueTestingUtilities` target.

```swift
import PersistedValueTestingUtilities

final class PersistedValuesServiceTests: XCTestCase {

  private var keychain: MockPersistedStorage!
  private var userDefaults: MockPersistedStorage!
  private var service: PersistedValuesService!

  override func setUp() {
      self.keychain = .init()
      self.userDefaults = .init()
      self.service = .init(keychain: keychain, userDefaults: userDefaults)
  }

  override func tearDown() { ... }

  func testUserId() {
    self.serive.userId.wrappedValue = "ID"
    XCTAssertEqual(self.storage.sets["user_id"], 1)
  }
}
```

## Requirements

* Xcode 12.4 and higher
* Swift 5.3 and higher

## Installation

You can add PersistedValue to an Xcode project by adding it as a package dependency.

  1. **File › Add Packages…**
  2. Enter "https://github.com/DimaKoroliov/PersistedValue" into the package URL text field

## Alternatives
