//
//  StoreKitManager.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/12/24.
//
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: ["thinkTwiceWeekly", "ThinkTwiceMonthly", "ThinkTwiceYearly", "ThinkTwiceLifetime"])
            self.products = products.sorted { $0.price < $1.price }
            print("Products loaded: \(products)")
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            purchasedProductIDs.insert(transaction.productID)
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Always finish a transaction.
                    await transaction.finish()
                    
                    await self.updatePurchasedProducts()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func hasActiveSubscription() -> Bool {
        // Check if any subscription or lifetime purchase is active
        return purchasedProductIDs.contains { productID in
            productID == "ThinkTwiceLifetime" ||
            productID.starts(with: "ThinkTwice") // This will match all subscription product IDs
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
