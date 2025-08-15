import SwiftUI
import FirebaseFirestore

struct StaffOrderDetailsView: View {
    let orderId: String

    @State private var orderData: [String: Any]? = nil
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var items: [OrderItem] = []

    @State private var showVerification = false
    @State private var numberToVerify = 0

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 🔝 Top bar estilizado
            TopBar(
                title: "Order Details",
                location: orderData?["storeName"] as? String ?? "Store",
                onBack: {
                    dismiss()
                },
                useSafeAreaPadding: true
            )

            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    if isLoading {
                        Spacer()
                        ProgressView("Loading Order...")
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        Text("❌ \(error)")
                            .foregroundColor(.red)
                        Spacer()
                    } else {
                        // 🛒 Lista de produtos
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(items) { item in
                                    OrderItemCard(item: item)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.top)
                        }

                        // ⬇️ Parte inferior
                        VStack(spacing: 16) {
                            if let total = orderData?["total"] as? Double {
                                Text("Total: $\(String(format: "%.2f", total))")
                                    .font(.title2)
                                    .bold()
                            }

                            // ✅ Frase corrigida
                            Text("You will verify \(numberToVerify) of \(items.count) item(s) from this order.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            // ✅ Botão simplificado (sem recalcular numberToVerify)
                            Button("✅ Start Verification") {
                                showVerification = true
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.horizontal)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 50)
                        .background(Color.white)
                    }

                    // 🔁 Navegação para tela de verificação
                    NavigationLink(
                        destination: StaffVerificationView(
                            orderId: orderId,
                            validBarcodes: items.map { $0.barcode },
                            numberToVerify: numberToVerify
                        ),
                        isActive: $showVerification
                    ) {
                        EmptyView()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            fetchOrder()
        }
        .navigationBarBackButtonHidden(true)
    }

    func fetchOrder() {
        let db = Firestore.firestore()

        db.collection("orders").document(orderId).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching order: \(error.localizedDescription)"
            } else if let data = snapshot?.data() {
                self.orderData = data

                if let itemsData = data["items"] as? [[String: Any]] {
                    self.items = itemsData.compactMap { dict in
                        guard let name = dict["name"] as? String,
                              let quantity = dict["quantity"] as? Int,
                              let price = dict["price"] as? Double,
                              let barcode = dict["barcode"] as? String,
                              let imageUrl = dict["imageUrl"] as? String else {
                            return nil
                        }
                        return OrderItem(name: name, quantity: quantity, price: price, barcode: barcode, imageUrl: imageUrl)
                    }

                    // ✅ Calcula a quantidade a verificar
                    self.numberToVerify = min(5, self.items.count)
                }
            } else {
                self.errorMessage = "Order not found."
            }

            self.isLoading = false
        }
    }
}
