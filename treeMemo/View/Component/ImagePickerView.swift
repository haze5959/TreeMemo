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
    let savePathHandler: (String) -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        var image: Image?
        let savePathHandler: (String) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             type: UIImagePickerController.SourceType = .photoLibrary,
             savePathHandler: @escaping (String) -> Void) {
            _presentationMode = presentationMode
            self.savePathHandler = savePathHandler
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            if self.saveImage(image: uiImage) {
                image = Image(uiImage: uiImage)
            }
            presentationMode.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
        func saveImage(image: UIImage) -> Bool {
            guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
                return false
            }
            guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
                return false
            }
            do {
                let fileName = "\(Date().timeIntervalSinceReferenceDate).png"
                let path = directory.appendingPathComponent(fileName)!
                try data.write(to: path)
                self.savePathHandler(fileName)
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
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
