import SwiftUI

struct EditScreen: View {
    
    var hideTabBar: (() -> Void)
    var didSaveImage: (() -> Void)
    var didSaveCollage: (() -> Void)
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink {
                    EditScreenOnboarding {
                        didSaveImage()
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image("main_screen-edit_ic")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Edit photo now")
                            .foregroundStyle(Colors.deepGray)
                            .font(.system(size: 17)).bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                NavigationLink {
                    CollageOnboarding {
                        didSaveCollage()
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image("main_screen-collage_ic")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Collage my photos")
                            .foregroundStyle(Colors.deepGray)
                            .font(.system(size: 17)).bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 50)
            
            HStack() {
                NavigationLink {
                    BestPhotoScreen() {
                        didSaveImage()
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image("bestPhoto2")
                            .resizable()
                            .frame(width: 125, height: 100)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Best photo")
                            .foregroundStyle(Colors.deepGray)
                            .font(.system(size: 17)).bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.leading, 35)
                    }
                }
                NavigationLink {
                } label: {
                    VStack(spacing: 5) {
                        Image("main_screen-collage_ic")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Collage my photos")
                            .foregroundStyle(Colors.deepGray)
                            .font(.system(size: 17))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .opacity(0)
//                .padding(.leading, 20)
                Spacer()
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 50)
            
            Spacer()
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            hideTabBar()
        }
    }
}

