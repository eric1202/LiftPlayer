//
//  ContentView.swift
//  LiftPlayer
//
//  Created by 中战云台 on 2022/10/24.
//

import SwiftUI

struct ContentView: View {
    let pub = NotificationCenter.default
                .publisher(for: NSNotification.Name("liftY"))
    
    @State private var words: [String] = ["otis","kone"]
    @State private var selected: String?
    @State var floorOffset = -40.0
    @State var doorSpacing = 4.0
    
    var body: some View {
        NavigationView{
            List {
                ForEach(words, id: \.self) { word in
                    NavigationLink {
                        ButtonsView(type:word,doorSpacing:$doorSpacing)
                    } label: {
                        Text(word.uppercased()).bold()

                    }

                }
                
                /// lift ui
                VStack{
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 200)
                        .frame(minHeight: 300)
                        .overlay {
                            Capsule()
                                .fill(.white)
                                .frame(width: 100)
                                .padding(.top)
                                .padding(.bottom, -20)
                        }
                        .overlay {
                            VStack{
                                Spacer()
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 100,height:20)
                                .padding(.bottom, -20)
                                .offset(y:floorOffset)
                                .onReceive(pub) { (output) in
                                    guard let y = output.object as? Double else { return }
                                    floorOffset -= y * 10
                                }
                            }
                        }

                }.padding(.top, 40)
                    .padding(.bottom, 30)
                
                /// door
                VStack{
                    HStack(spacing:doorSpacing){
                        Color.gray
                            .overlay{
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 4)
                            }
                        Color.gray.overlay{
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 4)
                        }
                    }
                }
                .frame(height: 160)
                
            }
            .navigationTitle("Elevator")
            .navigationViewStyle(.columns)

            
//            ButtonsView()
//                .padding()
        }
        .navigationViewStyle(.columns)

        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
