//
//  LaunchView.swift
//  GetAccelerometer
//
//  Created by Олег Чикин on 19.11.2022.
//

import SwiftUI

struct LaunchView: View {
    @State private var isActive = false
    @State private var size = 0.5
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        }
        else {
            ZStack{
                Color(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                        Text("GetAcc")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation() {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
