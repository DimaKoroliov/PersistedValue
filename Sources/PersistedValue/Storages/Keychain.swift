import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private let didChangeSubject = PassthroughSubject<String, Never>()

public final class KeychainStorage: PersistedStorage {

    /// Proxy for kSecAttrAccessible values
    public enum AttrAccessible {
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlocked
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlock
        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        case whenPasscodeSetThisDeviceOnly
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlockedThisDeviceOnly
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlockThisDeviceOnly
    }

    private let secAttrAccessible: CFString
    private let secClass = kSecClassGenericPassword

    public init(accessible: AttrAccessible = .afterFirstUnlock) {
        self.secAttrAccessible = accessible.kSecValue
    }

    public func persistedValue(forKey key: String) -> AnyPersistedValue<Data?> {
        AnyPersistedValue(
            get: { self.data(forKey: key) },
            set: { self.set($0, forKey: key) }
        )
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func didChange(forKey key: String) -> AnyPublisher<Void, Never> {
        didChangeSubject.filter { $0 == key }.map { _ in }.eraseToAnyPublisher()
    }

    private func data(forKey key: String) -> Data? {
        let query = [
            kSecClass: secClass,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecAttrAccessible: secAttrAccessible,
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard let data = result as? Data else {
            if status != errSecItemNotFound {
                assertionFailure(status.description)
            }

            return nil
        }

        return data
    }

    private func set(_ value: Data?, forKey key: String) {
        defer {
            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
                didChangeSubject.send(key)
            }
        }

        let containsValue = data(forKey: key) != nil
        guard let value = value else {
            if containsValue {
                self.delete(forKey: key)
            }

            return
        }

        if containsValue {
            self.update(value, forKey: key)
        } else {
            self.add(value, forKey: key)
        }
    }

    private func add(_ data: Data, forKey key: String) {
        let keychainItem = [
            kSecClass: secClass,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: secAttrAccessible,
        ] as CFDictionary

        let status = SecItemAdd(keychainItem, nil)
        guard status == errSecSuccess else {
            assertionFailure(status.description)
            return
        }
    }

    private func update(_ data: Data, forKey key: String) {
        let query = [
          kSecClass: secClass,
          kSecAttrAccount: key,
          kSecAttrAccessible: secAttrAccessible,
        ] as CFDictionary

        let updateFields = [
          kSecValueData: data
        ] as CFDictionary

        let status = SecItemUpdate(query, updateFields)
        guard status == errSecSuccess else {
            assertionFailure(status.description)
            return
        }
    }

    private func delete(forKey key: String) {
        let query = [
          kSecClass: secClass,
          kSecAttrAccount: key,
          kSecAttrAccessible: secAttrAccessible,
        ] as CFDictionary

        let status = SecItemDelete(query)
        guard status == errSecSuccess else {
            assertionFailure(status.description)
            return
        }
    }
}

private extension KeychainStorage.AttrAccessible {

    var kSecValue: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}
