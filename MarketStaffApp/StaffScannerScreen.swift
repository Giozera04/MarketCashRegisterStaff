import Foundation
import SwiftUI

struct StaffScannerScreen: View {
    @State private var didScan = false
    @State private var scannedCode: String? = nil
    @State private var scanningEnabled = true
    @State private var shouldShowOrderDetails = false
    @State private var scannedOrderId: String = ""
    @State private var isCameraActive = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 🔝 Top bar
            TopBar(
                title: "Scan Order",
                location: "Store", // Pode trocar por locationManager.currentStore?.name ?? "Store"
                onBack: {
                    dismiss()
                },
                useSafeAreaPadding: true
            )

            // 📷 Scanner embaixo da TopBar
            ZStack {
                GeometryReader { geo in
                    let scanWidth: CGFloat = 300
                    let scanHeight: CGFloat = 120
                    let scanX = (geo.size.width - scanWidth) / 2
                    let scanY = (geo.size.height - scanHeight) / 2
                    let scanRect = CGRect(x: scanX, y: scanY, width: scanWidth, height: scanHeight)

                    ZStack {
                        CameraPreviewView(
                            didScan: $didScan,
                            scanningEnabled: $scanningEnabled,
                            isActive: $isCameraActive,
                            onBarcodeScanned: { code in
                                scannedCode = code
                                scannedOrderId = code
                                shouldShowOrderDetails = true
                                scanningEnabled = false
                                didScan = true
                            },
                            scanRect: scanRect
                        )
                        .ignoresSafeArea()

                        ScanBoxOverlayView(scanRect: scanRect)
                    }
                }

                // 🔁 Navegação
                NavigationLink(
                    destination: StaffOrderDetailsView(orderId: scannedOrderId),
                    isActive: $shouldShowOrderDetails
                ) {
                    EmptyView()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("📷 Scanner screen appeared – resetting state")
            scanningEnabled = true
            didScan = false
            scannedCode = nil
            scannedOrderId = ""
            shouldShowOrderDetails = false
        }
        .onDisappear {
            isCameraActive = false
        }
        .navigationBarBackButtonHidden(true) // ⛔ Esconde botão padrão
    }
}
