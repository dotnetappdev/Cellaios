import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    var continuous: Bool = false
    var completion: (String) -> Void
    var onClose: () -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.continuous = continuous
        controller.completion = completion
        controller.onClose = onClose
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var completion: ((String) -> Void)?
    var onClose: (() -> Void)?
    var continuous: Bool = false
    private var scannedValues: Set<String> = []

    private var checkmarkLabel: UILabel?
    private var barcodeLabel: UILabel?
    private var scanningRectangle: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        captureSession = AVCaptureSession()

        // Initialize the scanning rectangle
        setupScanningRectangle()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .qr, .code128]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Add Exit button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Exit", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        closeButton.layer.cornerRadius = 8
        closeButton.frame = CGRect(x: view.bounds.width - 80, y: 50, width: 60, height: 30)
        closeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        closeButton.addTarget(self, action: #selector(closeScanner), for: .touchUpInside)
        view.addSubview(closeButton)

        // Add the scanning rectangle on top of the preview layer, but below the exit button
        view.addSubview(scanningRectangle)

        captureSession.startRunning()
    }

    private func setupScanningRectangle() {
        // Create a rectangular scanning area in the center
        scanningRectangle = UIView()
        scanningRectangle.layer.borderColor = UIColor.white.cgColor
        scanningRectangle.layer.borderWidth = 3
        scanningRectangle.layer.cornerRadius = 20  // Rounded corners for the scanner box
        scanningRectangle.frame = CGRect(x: view.bounds.width / 4, y: view.bounds.height / 3, width: view.bounds.width / 2, height: view.bounds.height / 3)
        scanningRectangle.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }

    @objc func closeScanner() {
        captureSession.stopRunning()
        onClose?()
        dismiss(animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }

        if continuous {
            if !scannedValues.contains(stringValue) {
                scannedValues.insert(stringValue)
                completion?(stringValue)
                
                // Show the green checkmark and barcode for a few seconds
                showScannedResult(stringValue)
                // Turn scanning rectangle green when barcode is detected
                highlightScanningRectangle(isDetected: true)
            }
        } else {
            captureSession.stopRunning()
            completion?(stringValue)
            showScannedResult(stringValue)
            highlightScanningRectangle(isDetected: true)
            dismiss(animated: true)
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    private func showScannedResult(_ barcode: String) {
        // Create green checkmark label
        if checkmarkLabel == nil {
            checkmarkLabel = UILabel()
            checkmarkLabel?.text = "✔️"
            checkmarkLabel?.font = UIFont.systemFont(ofSize: 100)
            checkmarkLabel?.textColor = .green
            checkmarkLabel?.center = view.center
            checkmarkLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            view.addSubview(checkmarkLabel!)
        }

        // Create barcode label
        if barcodeLabel == nil {
            barcodeLabel = UILabel()
            barcodeLabel?.font = UIFont.systemFont(ofSize: 20)
            barcodeLabel?.textColor = .white
            barcodeLabel?.textAlignment = .center
            barcodeLabel?.numberOfLines = 0
            barcodeLabel?.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            view.addSubview(barcodeLabel!)
        }
        
        // Set the barcode label text and position it below the checkmark
        barcodeLabel?.text = barcode
        barcodeLabel?.center = CGPoint(x: view.center.x, y: view.center.y + 60)

        // Remove the checkmark and barcode label after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkmarkLabel?.removeFromSuperview()
            self.barcodeLabel?.removeFromSuperview()
            // Reset scanning rectangle color after barcode scan
            self.highlightScanningRectangle(isDetected: false)
        }
    }

    private func highlightScanningRectangle(isDetected: Bool) {
        // Turn the scanning rectangle green if barcode is detected, otherwise reset
        scanningRectangle.layer.borderColor = isDetected ? UIColor.green.cgColor : UIColor.white.cgColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
}
