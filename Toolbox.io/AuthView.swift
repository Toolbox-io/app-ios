import SwiftUI
import LocalAuthentication

struct AuthView: View {
    @State private var enteredPin = ""
    @State private var isCorrectPin = false
    @State private var shake = false
    @State private var dotScale: [CGFloat] = [1, 1, 1, 1]
    @State private var pressedButton: String? = nil
    @State private var isChecking = false
    @State private var showDots = true
    @State private var combineDots = false
    @State private var animateErase = false
    @State private var spinnerRotation = 0.0
    @Environment(\.dismiss) var dismiss
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    startCheckPinAnimation(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            Text("Введите PIN-код")
                .font(.title)
                .padding(.bottom, 20)
            
            ZStack {
                if showDots {
                    HStack(spacing: combineDots ? -20 : 16) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < enteredPin.count ? Color.primary : Color.secondary.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .scaleEffect(dotScale[index])
                                .opacity(animateErase && index < enteredPin.count ? 0 : 1)
                                .animation(.easeInOut(duration: 0.25).delay(animateErase ? Double(index) * 0.05 : 0), value: animateErase)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: dotScale[index])
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
                        Image(systemName: "faceid")
                            .font(.largeTitle)
                            .padding()
                            .frame(width: 70, height: 70)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    numberButton(text: "0")
                    eraseButton()
                }
            }
        }
        .padding()
        .onAppear {
            isCorrectPin = false
            dotScale = [1, 1, 1, 1]
            showDots = true
            isChecking = false
            combineDots = false
            animateErase = false
            spinnerRotation = 0
        }
    }
    
    // Функция для создания кнопки с номером
    private func numberButton(text: String) -> some View {
        Button(action: {
            pressedButton = text
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                if enteredPin.count < 4 {
                    enteredPin += text
                    dotScale[enteredPin.count - 1] = 1.3
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
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
                    enteredPin.removeLast()
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
        if success != nil && success.unsafelyUnwrapped {
            
        }
        
        if enteredPin == "1234" || (success != nil && success.unsafelyUnwrapped) {
            isCorrectPin = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
        } else {
            // Step 4: Morph spinner back to dots and erase
            withAnimation(.easeInOut(duration: 0.2)) {
                isChecking = false
                showDots = true
                combineDots = false
            }
            // Step 5: Animate erase
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                animateErase = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateErase = false
                    enteredPin = ""
                    dotScale = [1, 1, 1, 1]
                    // Step 6: Shake
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
    AuthView()
}
