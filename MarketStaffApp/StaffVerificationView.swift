import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct StaffVerificationView: View {
    let orderId: String
    let validBarcodes: [String]
    let numberToVerify: Int
    let staffId = Auth.auth().currentUser?.uid ?? "unknown"
    let staffEmail = Auth.auth().currentUser?.email ?? "unknown"

    @State private var didScan = false
    @State private var scanningEnabled = true
    @State private var isCameraActive = true
    @State private var scannedBarcodes: [String] = []
    @State private var verificationComplete = false
    @State private var showSuccessAlert = false
    @State private var invalidBarcodes: [String] = []
    @State private var lastInvalidScan: String? = nil
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 🔝 Top bar com botão de fechar
            TopBar(
                title: "Verification",
                location: "Store", // você pode trocar por `locationManager.currentStore?.name ?? "Store"` se quiser mais dinâmico
                onBack: {
                    dismiss()
                },
                useSafeAreaPadding: true
            )
            
            // 🔍 Scanner embaixo da TopBar
            ZStack {
                GeometryReader { geo in
                    let boxSize: CGFloat = 250
                    let scanX = (geo.size.width - boxSize) / 2
                    let scanY = (geo.size.height - boxSize) / 2
                    let scanRect = CGRect(x: scanX, y: scanY, width: boxSize, height: boxSize)
                    
                    ZStack {
                        // 📸 Camera preview
                        CameraPreviewView(
                            didScan: $didScan,
                            scanningEnabled: $scanningEnabled,
                            isActive: $isCameraActive,
                            onBarcodeScanned: { code in
                                if scannedBarcodes.contains(code) || invalidBarcodes.contains(code) {
                                    print("⚠️ Código já escaneado")
                                    return
                                }

                                if validBarcodes.contains(code) {
                                    print("📦 Valid Scanned:", code)
                                    scannedBarcodes.append(code)

                                    if scannedBarcodes.count >= numberToVerify {
                                        verificationComplete = true
                                    }

                                    didScan = true
                                    scanningEnabled = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        didScan = false
                                        scanningEnabled = true
                                    }

                                } else {
                                    print("❌ Invalid item:", code)
                                    invalidBarcodes.append(code)
                                    lastInvalidScan = code

                                    didScan = true
                                    scanningEnabled = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        lastInvalidScan = nil
                                        didScan = false
                                        scanningEnabled = true
                                    }
                                }

                            },
                            scanRect: scanRect
                        )
                        .ignoresSafeArea()
                        
                        // 🟦 Overlay dos cantos brancos
                        ScanBoxOverlayView(scanRect: scanRect)
                        
                        VStack {
                            Spacer().frame(height: 60)

                            Text("\(scannedBarcodes.count)/\(numberToVerify) verified")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                            
                            if let invalid = lastInvalidScan {
                                Text("❌ Invalid item: \(invalid)")
                                    .foregroundColor(.red)
                                    .padding(.top, 8)
                            }

                            if verificationComplete {
                                Text("✅ Verification Complete")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.top, 4)

                                Button(action: {
                                    saveVerification()
                                    print("🔒 Finalizar verificação aqui")
                                }) {
                                    Text("Finalize Verification")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 8)
                            }

                            Spacer()
                        }

                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("🟢 Verification Scanner appeared")
            isCameraActive = true
            didScan = false
            scanningEnabled = true
        }
        .onDisappear {
            isCameraActive = false
        }
        .navigationBarBackButtonHidden(true)
        .alert("Verification Saved", isPresented: $showSuccessAlert) {
            Button("Return to Home") {
                dismiss()
            }
        } message: {
            Text("The verification was successfully saved.")
        }

    }
    
    func saveVerification() {
        let db = Firestore.firestore()
        
        let docRef = db.collection("verifications").document() // 👈 cria o docRef manualmente

        let data: [String: Any] = [
            "orderId": orderId,
            "verified": true,
            "verifiedAt": Timestamp(),
            "staffId": staffId,
            "staffEmail": staffEmail,
            "scannedItems": scannedBarcodes,
            "invalidItems": invalidBarcodes
        ]

        docRef.setData(data) { error in
            if let error = error {
                print("❌ Error saving verification:", error.localizedDescription)
            } else {
                print("✅ Verification saved successfully! ID: \(docRef.documentID)")
                showSuccessAlert = true
            }
        }
    }

    
}
