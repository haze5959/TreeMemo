//
//  HeaderView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    let viewModel = TreeMemoViewModel()
    @ObservedObject var State = TreeMemoState.shared
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                //설정 버튼
                Button(action: {
                    
                }, label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                })
                
                //스페이서
                Spacer()
                
                //타이틀
                Text(self.State.treeHierarchy.last ?? "TreeMemo")
                
                //스페이서
                Spacer()
                
                //편집 버튼
                Button(action: {
                    self.State.isEdit.toggle()
                }, label: {
                    Image(systemName: "pencil")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                })
            }
            
            //계층 정보
            HStack {
                Button(action: {
                    self.State.treeHierarchy.removeAll()
                }, label: {
                    Image(systemName: "house")
                        .imageScale(.small)
                        .padding()
                        .foregroundColor(Color(UIColor.label))
                })
                
                if self.State.treeHierarchy.count > 0 {
                    ForEach(0..<self.State.treeHierarchy.count, id: \.self) { index in
                        HStack {
                            Image(systemName: "chevron.compact.right")
                                .imageScale(.small)
                                .foregroundColor(Color(UIColor.label))
                            
                            Button(action: {
                                self.viewModel.selectTreeHierarchy(index: index)
                            }, label: {
                                Text(self.State.treeHierarchy[index])
                                    .font(Font.system(size: 10))
                                    .lineLimit(2)
                                    .padding()
                                    .foregroundColor(Color(UIColor.label))
                                    .frame(maxWidth: 80)
                            })
                        }
                    }
                }
                
                //스페이서
                Spacer()
            }
        }
    }
}

// MARK: Preview
struct Header_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            HeaderView()
            //            .environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
