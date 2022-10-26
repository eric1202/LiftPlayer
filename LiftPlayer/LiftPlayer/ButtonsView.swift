//
//  ButtonsView.swift
//  LiftPlayer
//
//  Created by 中战云台 on 2022/10/24.
//

import SwiftUI
import AudioToolbox
import AVFoundation

struct ButtonsView: View {
    private let synth = AVSpeechSynthesizer()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func getFloorData() -> [String] {
        return (type == "kone" ? (-1...5) : (-3...32)).map { "\($0)" }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 140,maximum: 300))
    ]
    
    @State var type = ""
    
    @State var selecteds = [""]
    @State var curentFloor = "1"
    @State private var nextFloor = "1"
    
    @Binding var doorSpacing:Double
    
    @State private var closeLongPress = false
    @State private var openLongPress = false
    
    
    //-1 0 1 电梯方向
    @State private var floorState = 0
    fileprivate func beep() {
        let soundID = 1057 // 1306//1104//
        AudioServicesPlaySystemSound(SystemSoundID(soundID))
    }
    
    var body: some View {
        VStack{
            Spacer().frame(height:12)
            HStack{
                HStack{
                    Text(curentFloor)
                        .font(.custom("Seravek-Bold", size:64))
                        .frame(width: 80, alignment: .trailing)
                        .onReceive(timer) { time in
                            print("The time is now \(time)")
                            
                            if curentFloor == nextFloor {
                                floorState = 0
                                if let index = selecteds.firstIndex(of: nextFloor) {
                                    selecteds.remove(at: index)
                                    synth.stopSpeaking(at: .immediate)
                                    
                                    let utterance = AVSpeechUtterance(string: "\(curentFloor)层 到了")
                                    utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                                    
                                    utterance.rate = 0.4
                                    synth.speak(utterance)
                                    
                                    let utterance2 = AVSpeechUtterance(string: "\(curentFloor)层 到啦")
                                    utterance2.voice = AVSpeechSynthesisVoice(language: "zh-hk")
                                    utterance2.rate = 0.4
                                    
                                    synth.speak(utterance2)
                                    
                                    let utterance3 = AVSpeechUtterance(string: "电梯\(floorState > 0 ? "上" : "下")行")
                                    utterance3.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                                    
                                    utterance3.rate = 0.4
                                    synth.speak(utterance3)
                                    
                                    let utterance4 = AVSpeechUtterance(string: "going\(floorState > 0 ? " up" : " down")")
                                    utterance4.rate = 0.3
                                    synth.speak(utterance4)
                                    
                                }
                                return
                            }
                            
                            floorState = (Int(curentFloor) ?? 0) < (Int(nextFloor) ?? 0) ? 1 : -1
                            
                            if floorState < 0 {
                                curentFloor = String((Int(curentFloor) ?? 0) - 1)
                            }else{
                                curentFloor = String((Int(curentFloor) ?? 0) + 1)
                            }
                            NotificationCenter.default.post(name: NSNotification.Name("liftY"),
                                                            object: floorState, userInfo: ["info": "floor"])
                        }
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 80, height: 100)
                        .overlay {
                            Image(systemName: "arrow.\(floorState > 0 ? "up" : "down")")
                                .font(.system(size: 40, weight: .heavy))
                        }
                        .padding(.leading)
                }
                .background(Color.blue.opacity(0.3)).frame( height: 80)
                .padding(.trailing, 90)
                
                Image(systemName: "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left")
                    .font(.system(size: 40))
                    .foregroundColor(closeLongPress ? .blue : .black)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(closeLongPress ? .blue : .black, lineWidth: 4)
                    )
                    .padding(.trailing, 20)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { amount in
                                closeLongPress = true
                            }
                            .onEnded { amount in
                                closeLongPress = false
                            }
                            .simultaneously(with: TapGesture().onEnded({
                                synth.stopSpeaking(at: .immediate)
                                withAnimation(.easeInOut(duration: 2)) {
                                    doorSpacing = 4
                                }
                                beep()
                                
                                let utterance = AVSpeechUtterance(string: "小心关门")
                                utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                                
                                utterance.rate = 0.3
                                synth.speak(utterance)
                                
                                let utterance2 = AVSpeechUtterance(string: " 小心关门")
                                utterance2.voice = AVSpeechSynthesisVoice(language: "zh-hk")
                                utterance2.rate = 0.3
                                
                                synth.speak(utterance2)
                                
                                let utterance3 = AVSpeechUtterance(string: "door closing")
                                utterance3.rate = 0.3
                                
                                synth.speak(utterance3)
                            }))
                    )
                
                
                
                Image(systemName: "arrowtriangle.left.fill.and.line.vertical.and.arrowtriangle.right.fill")
                    .font(.system(size: 40))
                    .foregroundColor(openLongPress ? .blue : .black)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(openLongPress ? .blue : .black, lineWidth: 4)
                    )
                
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { amount in
                                openLongPress = true
                            }
                            .onEnded { amount in
                                openLongPress = false
                            }
                            .simultaneously(with: TapGesture().onEnded({
                                synth.stopSpeaking(at: .immediate)
                                withAnimation(.easeInOut(duration: 2)) {
                                    doorSpacing = 140
                                }
                                beep()
                                let utterance = AVSpeechUtterance(string: "小心开门")
                                utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                                
                                utterance.rate = 0.3
                                synth.speak(utterance)
                                
                                let utterance2 = AVSpeechUtterance(string: " 小心开门")
                                utterance2.voice = AVSpeechSynthesisVoice(language: "zh-hk")
                                utterance2.rate = 0.3
                                
                                synth.speak(utterance2)
                                
                                let utterance3 = AVSpeechUtterance(string: "door opening")
                                utterance3.rate = 0.3
                                
                                synth.speak(utterance3)
                                
                            }))
                    )
                
                
            }
            //            .background(Color.green.opacity(0.7))
            .padding(.bottom)
            ScrollView {
                
                LazyVGrid(columns: columns) {
                    ForEach(getFloorData(), id: \.self) { item in
                        Button(action: {
                            if let index = selecteds.firstIndex(of: item) {
                                selecteds.remove(at: index)
                            }
                            else{
                                selecteds.append(item)
                                beep()
                                
                                //vibrate
                                AudioServicesPlaySystemSound(1520)
                                print("\(nextFloor)")
                                nextFloor = selecteds.max() ?? ""
                                
                            }
                        }) {
                            HStack {
                                Text(item)
                                    .foregroundColor( selecteds.contains(item) ? .white : .black)
                                    .font(.custom("Seravek-Bold", size: 44))
                                    .bold()
                                    .foregroundColor(Color.blue)
                            }
                            .frame(width: 120,height:120)
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                }
                .offset(y:10)
                .padding(.horizontal)
            }
            Spacer()
            
        }
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .hidden()
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.gray)
                    .shadow(color: Color.black.opacity(1), radius: 1)
            )
            .opacity(0.7)
            .overlay(configuration.label)
            .padding(.bottom, 20)
    }
}
