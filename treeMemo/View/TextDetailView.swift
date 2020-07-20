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
    @State var showConfireAlert = false
    @State var isEdited = false
    @State var selectedRange: UITextRange?
    let completeHandler: (String) -> Void
    @ObservedObject var keyboard = KeyboardResponder()
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            NavigationView {
                TextView(text: self.$text, isEdited: self.$isEdited, selectedRange: self.$selectedRange)
                    .navigationBarTitle(Text(self.title), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        // Close Event
                        if self.isEdited {
                            self.showConfireAlert = true
                        } else {
                            ViewModel().dismissViewController()
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundColor(Color(.label))
                            .padding()
                    }), trailing: Button(action: {
                        // Save Event
                        self.completeHandler(self.text)
                        ViewModel().dismissViewController()
                    }, label: {
                        Image(systemName: "pencil")
                            .imageScale(.large)
                            .foregroundColor(Color(.label))
                            .padding()
                    }))
            }.padding(.bottom, keyboard.currentHeight)
            .navigationViewStyle(StackNavigationViewStyle())
        }.alert(isPresented: self.$showConfireAlert, content: {
            Alert(title: Text("Info"),
                  message: Text("Are you sure you want to exit editing without saving?"),
                  primaryButton: Alert.Button.default(Text("Exit"),
                                                      action: {
                                                        ViewModel().dismissViewController()
                  }),
                  secondaryButton: Alert.Button.cancel())
        })
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEdited: Bool
    @Binding var selectedRange: UITextRange?
    
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
        myTextView.backgroundColor = .init(white: 0.0, alpha: 0.05)
        myTextView.becomeFirstResponder()
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if !self.isEdited {
            uiView.text = text
        }
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
            self.parent.isEdited = true
            self.parent.selectedRange = textView.selectedTextRange
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
