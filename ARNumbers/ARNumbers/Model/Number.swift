//
//  Number.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import Foundation

class Number: ObservableObject {
    @Published var num = 0 // Published updated alle ObservableObjects
    @Published var hasBox = false
}
