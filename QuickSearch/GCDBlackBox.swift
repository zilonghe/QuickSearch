//
//  GCDBlackBox.swift
//  QuickSearch
//
//  Created by 何子龙 on 18/01/2017.
//  Copyright © 2017 何子龙. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
