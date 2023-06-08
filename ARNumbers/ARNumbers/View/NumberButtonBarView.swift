//
//  NumberButtonBarView.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI

struct NumberButtonBarView: View {
    var number: Number
    @State private var showAlert = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            Button {
                if(number.hasBox) {
                    number.num -= 1
                    //print("Tap -: \(number.num)")
                } else {
                    showAlert = true
                }
            } label: {
                //Image(systemName: "minus.diamond")
                PulseAnimation(color: .red, leftToRight: true)
            }
            
            Button {
                number.num = 0
                number.hasBox = false
                //print("Tap X: \(number.num)")
            } label: {
                Image(systemName: "xmark.diamond.fill")
            }
            
            Button {
                if(number.hasBox) {
                    number.num += 1
                    //print("Tap +: \(number.num)")
                } else {
                    showAlert = true
                }
            } label: {
                //Image(systemName: "plus.diamond")
                PulseAnimation(color: .green)
            }
        }
        .padding(.bottom, 15)
        .font(.system(size: 32))
        .foregroundColor(.white)
        .frame(width: UIScreen.main.bounds.width, height: 80, alignment: .center)
        .background(.black)
        .opacity(0.87)
        .alert("Press AR View first", isPresented: $showAlert, actions: {})
    }
}

#if DEBUG
struct NumberButtonBarView_Previews : PreviewProvider {
    static var previews: some View {
        NumberButtonBarView(number: Number())
    }
}
#endif
