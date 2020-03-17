//
//  ImagePickerView.swift
//  treeMemo
//
//  Created by OQ on 2019/12/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    var presentationMode
    
    let pickerType: UIImagePickerController.SourceType
    let savePathHandler: (Data) -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        var image: Image?
        let savePathHandler: (Data) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             type: UIImagePickerController.SourceType = .photoLibrary,
             savePathHandler: @escaping (Data) -> Void) {
            _presentationMode = presentationMode
            self.savePathHandler = savePathHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            PinWheelView.shared.showProgressView(picker.view) {
                if self.saveImage(image: uiImage) {
                    self.image = Image(uiImage: uiImage)
                }

                self.presentationMode.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
        func saveImage(image: UIImage) -> Bool {
            let resizedImage = image.resizeTo1MB()
            guard let data = resizedImage?.pngData() else {
                return false
            }
            
            self.savePathHandler(data)
            return true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, savePathHandler: self.savePathHandler)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = self.pickerType
        picker.mediaTypes = ["public.image"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
