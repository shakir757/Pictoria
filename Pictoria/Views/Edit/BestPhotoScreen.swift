import Foundation
import SwiftUI

struct BestPhotoScreen: View {
    
    @State var otherParams: UIImage?
    @State var selectedImagesForScreen: [UIImage] = [UIImage(named:"placeholder") ?? UIImage(),
                                                     UIImage(named:"placeholder") ?? UIImage(),
                                                     UIImage(named:"placeholder") ?? UIImage(),
                                                     UIImage(named:"placeholder") ?? UIImage()]
    
    @State var goToCollageScreen: Bool = false
    
    @State var selectedImage = 1
    
    var examplePhoto: UIImage = UIImage(named: "example") ?? UIImage()
    
    @State var isSelectionEnabled = false
    
    @State var selectedImages: [UIImage]? = []
    @State var presentSelectingImages: Bool = false
    
    @State var showLoading: Bool = false
    @State var buttonText: String = "Open"
    var didSaveCollage: (() -> Void)
    
    @State private var isLoading = false


    var body: some View {
        
        ZStack {
            
            if isLoading {
                Color.gray.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Загрузка...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            VStack {
                Text("Best photo")
                    .foregroundStyle(Colors.blacker)
                    .font(.system(size: 36, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Text(!isSelectionEnabled ? "Choose up to 4 similar photos, the \n app will help you determine the \n best one to take " : "Below you can see the best photo \n that our system has selected")
                    .foregroundStyle(Colors.blacker)
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
                    .padding(.top, 5)
                
                if !isSelectionEnabled {
                    Text("You can see an example below")
                        .foregroundStyle(Colors.gray)
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                        .padding(.top, 10)
                }


                
                HStack(spacing: 18) {
                    Image(uiImage:  isSelectionEnabled ? selectedImagesForScreen[0] : examplePhoto)
                        .resizable()
                        .cornerRadius(14)
                        .frame(width: 175, height: 175)
                        .onTapGesture {
                            if isSelectionEnabled {
                                selectedImage = 0
                            }
                        }
                        .overlay {
                            if selectedImage == 0 {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Colors.deepBlue, lineWidth: 3)
                            }
                        }
                    
                    Image(uiImage: isSelectionEnabled ? selectedImagesForScreen[1] : examplePhoto)
                        .resizable()
                        .cornerRadius(14)
                        .frame(width: 175, height: 175)
                        .onTapGesture {
                            if isSelectionEnabled {
                                selectedImage = 1
                            }
                        }
                        .overlay {
                            if selectedImage == 1 {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Colors.deepBlue, lineWidth: 3)
                            }
                        }
                    
                }
                .padding(.top, 24)
                
                HStack(spacing: 8) {
                    Image(uiImage: isSelectionEnabled ? selectedImagesForScreen[2] : examplePhoto)
                        .resizable()
                        .cornerRadius(14)
                        .frame(width: 175, height: 175)
                        .onTapGesture {
                            if isSelectionEnabled {
                                selectedImage = 2
                            }
                        }
                        .overlay {
                            if selectedImage == 2 {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Colors.deepBlue, lineWidth: 3)
                            }
                        }
                    
                    Image(uiImage: isSelectionEnabled ? selectedImagesForScreen[3] : examplePhoto)
                        .resizable()
                        .cornerRadius(14)
                        .frame(width: 175, height: 175)
                        .onTapGesture {
                            if isSelectionEnabled {
                                selectedImage = 3
                            }
                        }
                        .overlay {
                            if selectedImage == 3 {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Colors.deepBlue, lineWidth: 3)
                            }
                        }
                }
                .padding(.top, 8)
                
                Spacer()
                
                if isSelectionEnabled {
                    Button {
                        let group = DispatchGroup()
                        isLoading = true

                        saveToCashImage(uiImage: selectedImagesForScreen[selectedImage], group: group)
                        group.notify(queue: .main) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                didSaveCollage()
                                isLoading = false
                            }
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Colors.deepBlue)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .overlay {
                                Text("Save this image")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom)
                    .navigationBarItems(
                              trailing: Button("Save") {
                                  let group = DispatchGroup()
                                  isLoading = true
                                  saveToCashImage(uiImage: selectedImagesForScreen[selectedImage], group: group)
                                  group.notify(queue: .main) {
                                      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                          didSaveCollage()
                                          isLoading = false
                                      }
                                  }
                                  print("Save button tapped")
                              }
                          )
                } else {
                    Button {
                        presentSelectingImages.toggle()
                    } label: {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Colors.deepBlue)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .overlay {
                                Text(buttonText)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom)
                }

                Spacer()
            }
            .navigationTitle("Best Photo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $presentSelectingImages) {
                PhotoPicker(selectedImages: $selectedImages,
                            selectedImage: $otherParams,
                            countForSelected: 4) {
                    isSelectionEnabled = true
                    
                    if let selected = selectedImages {
                        selectedImagesForScreen = selected
                        while selectedImagesForScreen.count != 4 {
                            selectedImagesForScreen.append(UIImage(named: "placeholder") ?? UIImage())
                        }
                        selectedImage = Int.random(in: 0...selectedImagesForScreen.count - 1)

                    }
                    buttonText = "Save this image"
                }
            }
            .onAppear {
                buttonText = "Open"
                selectedImages = []
                presentSelectingImages = false
                goToCollageScreen = false
                showLoading = false
            }
            
            if showLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    private func saveToCashImage(uiImage: UIImage, group: DispatchGroup) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            group.enter()
            
            var images: [UIImage] = []
            
            if let userDefaultsImages = UserDefaults.standard.array(forKey: "BestPhoto") as? [Data] {
                for imageData in userDefaultsImages {
                    if let image = UIImage(data: imageData) {
                        images.append(image)
                    }
                }
            }
            
            images.append(uiImage)
            
            let imageDataArray = images.compactMap { $0.pngData() }
            UserDefaults.standard.set(imageDataArray, forKey: "BestPhoto")
            
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            
            group.leave()
        }
    }
}
