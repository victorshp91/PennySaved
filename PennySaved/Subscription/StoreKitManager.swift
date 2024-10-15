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
    @Published var hasActiveSubscription: Bool = false
    @Published var hasLifetimeSubscription: Bool = false
    @Published var activeSubscription: Product?
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
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
        var updatedIDs = Set<String>()
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            updatedIDs.insert(transaction.productID)
        }
        self.purchasedProductIDs = updatedIDs
        self.hasActiveSubscription = !updatedIDs.isEmpty
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
            await updateSubscriptionStatus()
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
    
    func updateSubscriptionStatus() async {
        var foundActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if let product = self.products.first(where: { $0.id == transaction.productID }) {
                    if product.type == .autoRenewable || product.type == .nonConsumable {
                        self.activeSubscription = product
                        self.hasActiveSubscription = true
                        self.hasLifetimeSubscription = product.type == .nonConsumable
                        foundActiveSubscription = true
                        break
                    }
                }
            }
        }
        
        if !foundActiveSubscription {
            self.activeSubscription = nil
            self.hasActiveSubscription = false
            self.hasLifetimeSubscription = false
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
