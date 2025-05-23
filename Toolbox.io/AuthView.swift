import SwiftUI
import LocalAuthentication
import CryptoKit

enum AuthMode {
    case enterPassword
    case enterOldPassword
    case enterNewPassword
    case confirmNewPassword
}

class PrivacyOverlayAuthInProgress {
    static let shared = PrivacyOverlayAuthInProgress()
    private init() {}
    var isAuthenticating = false
}

struct AuthView: View {
    @AppStorage("allowBiometric") private var allowBiometric = false
    @AppStorage("passwordLockHash") private var passwordLockHash: String = ""

    let mode: AuthMode
    let onSuccess: ((String?) -> Void)?
    let newPassword: String?

    @State private var enteredPin = ""
    @State private var isCorrectPin = false
    @State private var shake = false
    @State private var dotScale: [CGFloat] = [1, 1, 1, 1]
    @State private var dotOpacity: [Double] = [1, 1, 1, 1]
    @State private var pressedButton: String? = nil
    @State private var isChecking = false
    @State private var showDots = true
    @State private var combineDots = false
    @State private var spinnerRotation = 0.0
    @Environment(\.dismiss) var dismiss
    
    private var title: String {
        switch mode {
        case .enterPassword: return "Enter password"
        case .enterOldPassword: return "Enter old password"
        case .enterNewPassword: return "Enter new password"
        case .confirmNewPassword: return "Confirm new password"
        }
    }
    
    private var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    private var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "faceid"
        }
    }
    private var isBiometricAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            PrivacyOverlayAuthInProgress.shared.isAuthenticating = true
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                PrivacyOverlayAuthInProgress.shared.isAuthenticating = false
                // authentication has now completed
                if success {
                    startCheckPinAnimation(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onSuccess?(nil)
                        dismiss()
                    }
                } else {
                    startCheckPinAnimation(false)
                    print(authenticationError.unsafelyUnwrapped.localizedDescription)
                }
            }
        } else {
            print("error: no biometrics")
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .padding(.bottom, 20)
            
            ZStack {
                if showDots {
                    HStack(spacing: combineDots ? -20 : 16) {
                        ForEach(0..<4, id: \ .self) { index in
                            Circle()
                                .fill(index < enteredPin.count ? Color.primary : Color.secondary.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .scaleEffect(dotScale[index])
                                .opacity(dotOpacity[index])
                        }
                    }
                    .modifier(Shake(animatableData: CGFloat(shake ? 1 : 0)))
                    .animation(.default, value: shake)
                    .font(.largeTitle)
                }
                if isChecking {
                    LoadingSpinner(rotation: spinnerRotation)
                        .frame(width: 32, height: 32)
                        .transition(.scale)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                spinnerRotation = 360
                            }
                        }
                }
            }
            .frame(height: 32)
            
            // Панель ввода PIN
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    numberButton(text: "1")
                    numberButton(text: "2")
                    numberButton(text: "3")
                }
                
                HStack(spacing: 20) {
                    numberButton(text: "4")
                    numberButton(text: "5")
                    numberButton(text: "6")
                }
                
                HStack(spacing: 20) {
                    numberButton(text: "7")
                    numberButton(text: "8")
                    numberButton(text: "9")
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        authenticate()
                    }) {
                        Image(systemName: biometricIcon)
                            .font(.largeTitle)
                            .padding()
                            .frame(width: 70, height: 70)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .invisibleAndDisabled(!allowBiometric || !isBiometricAvailable || mode == .enterOldPassword || mode == .enterNewPassword || mode == .confirmNewPassword)
                    numberButton(text: "0")
                    eraseButton()
                }
            }
        }
        .padding()
        .onAppear {
            isCorrectPin = false
            dotScale = [1, 1, 1, 1]
            dotOpacity = [1, 1, 1, 1]
            showDots = true
            isChecking = false
            combineDots = false
            spinnerRotation = 0
        }
    }
    
    // Функция для создания кнопки с номером
    private func numberButton(text: String) -> some View {
        Button(action: {
            pressedButton = text
            if enteredPin.count < 4 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    enteredPin += text
                    dotScale[enteredPin.count - 1] = 1.3
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    dotScale = [1, 1, 1, 1]
                }
                pressedButton = nil
            }
            if enteredPin.count == 4 {
                startCheckPinAnimation(nil)
            }
        }) {
            Text(text)
                .font(.largeTitle)
                .padding()
                .frame(width: 70, height: 70)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 5)
                .scaleEffect(pressedButton == text ? 0.85 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: pressedButton == text)
        }
    }
    
    // Custom erase button with dot fade-out animation
    private func eraseButton() -> some View {
        Button(action: {
            if enteredPin.count > 0 {
                let index = enteredPin.count - 1
                withAnimation(.easeInOut(duration: 0.15)) {
                    dotScale[index] = 0.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if enteredPin.count > 0 {
                        enteredPin.removeLast()
                    }
                    dotScale[index] = 1.0
                }
            }
        }) {
            Image(systemName: "eraser.fill")
                .font(.largeTitle)
                .padding()
                .frame(width: 70, height: 70)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    // Start the animation sequence for checking PIN
    private func startCheckPinAnimation(_ success: Bool?) {
        // Step 1: Combine dots
        withAnimation(.easeInOut(duration: 0.2)) {
            combineDots = true
        }
        // Step 2: Morph to spinner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDots = false
                isChecking = true
            }
            // Step 3: Check PIN after spinner appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                checkPin(success)
            }
        }
    }
    
    // Проверка введенного PIN
    private func checkPin(_ success: Bool?) {
        switch mode {
        case .enterPassword, .enterOldPassword:
            let hash = Self.hashPin(enteredPin)
            print("stored hash: \(passwordLockHash), generated: \(hash)")
            if hash == passwordLockHash {
                isCorrectPin = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onSuccess?(enteredPin)
                    dismiss()
                }
            } else {
                failAnimation()
            }
        case .enterNewPassword:
            onSuccess?(enteredPin)
            // dismiss()
        case .confirmNewPassword:
            if enteredPin == newPassword {
                passwordLockHash = Self.hashPin(enteredPin)
                print("generated hash: \(passwordLockHash)")
                onSuccess?(enteredPin)
                dismiss()
            } else {
                failAnimation()
            }
        }
    }
    
    private func failAnimation() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isChecking = false
            showDots = true
            combineDots = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            eraseDotsAnimated {
                enteredPin = ""
                dotScale = [1, 1, 1, 1]
                dotOpacity = [1, 1, 1, 1]
                withAnimation {
                    shake.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        shake.toggle()
                    }
                }
            }
        }
    }
    
    private func eraseDotsAnimated(completion: @escaping () -> Void) {
        let count = enteredPin.count
        guard count > 0 else { completion(); return }
        func animateDot(_ index: Int) {
            guard index >= 0 else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: completion)
                return
            }
            withAnimation(.easeInOut(duration: 0.18)) {
                dotScale[index] = 0.1
                dotOpacity[index] = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                animateDot(index - 1)
            }
        }
        animateDot(count - 1)
    }
    
    static func hashPin(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Shake effect modifier
struct Shake: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// Loading spinner view
struct LoadingSpinner: View {
    var rotation: Double
    var body: some View {
        ZStack {
            ForEach(0..<8) { i in
                Circle()
                    .fill(Color.primary.opacity(Double(i+1)/8.0))
                    .frame(width: 6, height: 6)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    AuthView(mode: .enterPassword, onSuccess: nil, newPassword: nil)
}
