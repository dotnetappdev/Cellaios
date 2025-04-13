import SwiftUI

struct ScanningView: View {
    @State private var scannedCode: String?
    @State private var scannedCodes: [String] = []
    @State private var isScannerPresented = false
    @State private var isContinuousScan = false
    @State private var showAlert = false
    @State private var currentScannedItem: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let scannedCode = scannedCode {
                    Text("Last Scanned Code: \(scannedCode)")
                        .font(.title2)
                        .padding()
                } else {
                    Text("No barcode scanned yet.")
                        .font(.title2)
                        .padding()
                }

                Button("Scan Single Barcode") {
                    isContinuousScan = false
                    isScannerPresented = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Button("Scan Multiple Barcodes") {
                    isContinuousScan = true
                    isScannerPresented = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                if !scannedCodes.isEmpty {
                    List {
                        Section(header: Text("Scanned Codes")) {
                            ForEach(scannedCodes, id: \.self) { code in
                                Text(code)
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Barcode Scanner")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Scanned Code"),
                    message: Text(currentScannedItem ?? "Unknown code"),
                    dismissButton: .default(Text("OK"), action: {
                        if !isContinuousScan {
                            isScannerPresented = false
                        }
                    })
                )
            }
        }
        .sheet(isPresented: $isScannerPresented) {
            BarcodeScannerView(continuous: isContinuousScan) { scanned in
                self.currentScannedItem = scanned
                self.scannedCodes.append(scanned)
                showAlert = true
            } onClose: {
                isScannerPresented = false
            }
        }
    }
}
