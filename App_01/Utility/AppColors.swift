//
//  AppColors.swift
//  App_01
//
//  Created by Nethra Kalaimani on 03/11/26.
//

import SwiftUI

// All the colors are computed values
extension Color {
    
    static var customAppBackground: Color {
        Color(AppTheme.current.backgroundColorName)
    }
    static var appSurface: Color {
        Color(AppTheme.current.surfaceColorName)
    }

    static var appPrimary: Color {
        Color(AppTheme.current.primaryColorName)
    }
    static var appSecondary: Color {
        Color(AppTheme.current.secondaryColorName)
    }

    // Text Colors

    static var appText: Color {
        Color(AppTheme.current.textColorName)
    }
    static var appSecondaryText: Color {
        Color(AppTheme.current.subtextColorName)
    }
    
    static var customAvatarText: Color {
        Color(AppTheme.current.avatarTextColorName)
    }
    
}
