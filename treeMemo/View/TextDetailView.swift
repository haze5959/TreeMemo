//
//  TextDetailView.swift
//  treeMemo
//
//  Created by OQ on 2019/12/15.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI
import Combine

struct TextDetailView: View {
    let title: String
    @State var text: String
    let completeHandler: (String) -> Void
    @ObservedObject var keyboard = KeyboardResponder()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
            NavigationView {
                TextView(text: self.$text)
                    .navigationBarTitle(Text(self.title), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        // Close Event
                        ViewModel().dismissViewController()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundColor(Color(UIColor.label))
                            .padding()
                    }), trailing: Button(action: {
                        // Save Event
                        self.completeHandler(self.text)
                        ViewModel().dismissViewController()
                    }, label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(Color(UIColor.label))
                            .padding()
                    }))
            }.padding(.bottom, keyboard.currentHeight)
        }
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator
        
        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}

struct TextDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TextDetailView(title: "Text Title", text: """
sdfssfsf
sdfsfsfssdfsfsfssdfsfsfs
sdfsfsfssdfsfsfs
sdfsfsfs

sdfsfsfssdfsfsfs
sdfsfsfssdfsfsfs

sdfsfsfssdfsfsfssdfsfsfs

sdfsfsfssdfsfsfs
sdfsfsfs
sdfsfsfs

sdfsfsfssdfsfsfssdfsfsfs

sdfsfsfssdfsfsfs
sdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfssdfsfsfs
""", completeHandler: {(text) in
    print(text)
        })
    }
}
