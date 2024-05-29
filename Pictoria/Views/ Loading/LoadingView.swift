
import SwiftUI

struct LoadingView: View {
    
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
    
    @State private var isRotating: Bool = false
    @State private var angle: Double = 0
    
    @State private var showOnboarding: Bool = false

    @Binding var showed: Bool
    
    
    var body: some View {
            VStack {
                ZStack {
                    Image("app_launch_ic")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .offset(y: yOffset)
                    
                    Image("dinamic_cyrcle_ic")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(angle))
                        .offset(y: yOffset - 12)
                }
            }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            if !showed {
                    startRotating()
            } else {
                yOffset -= 150
            }
        }
    }
    
    // MARK: - Animation Start / End
    private func startRotating() {
        withAnimation(Animation.linear(duration: 0.9)) {
            angle += 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if !showed {
                self.startRotating()
            }
        }
    }
    
    private func stopRotatingAndShowContent() {
        let currentAngle = angle.truncatingRemainder(dividingBy: 360)
        let remainingAngle = 360 - currentAngle
        let durationAnimation = (remainingAngle / 360) * 0.9
        
        withAnimation(Animation.linear(duration: durationAnimation)) {
            angle += remainingAngle
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + durationAnimation) {
            angle = 0
            
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                yOffset -= 150
                
                showed = true
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    opacity = 1
                }
            }
        }
    }
}
