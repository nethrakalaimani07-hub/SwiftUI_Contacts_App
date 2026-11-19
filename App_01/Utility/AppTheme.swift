//
//  AppTheme.swift
//  App_01
//


import Foundation

enum AppTheme: String, CaseIterable, Identifiable {
    case classic
    case ocean
    case sage
    case sand
    case graphite

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .ocean: return "Ocean Blue"
        case .sage: return "Sage Garden"
        case .sand: return "Warm Sand"
        case .graphite: return "Graphite"
        }
    }

    private var assetPrefix: String {
        switch self {
        case .classic: return ""
        case .ocean: return "Ocean"
        case .sage: return "Sage"
        case .sand: return "Sand"
        case .graphite: return "Graphite"
        }
    }

    var backgroundColorName: String {
        self == .classic ? "AppBackground" : "\(assetPrefix)Background"
    }

    var surfaceColorName: String {
        self == .classic ? "Surface" : "\(assetPrefix)Surface"
    }

    var primaryColorName: String {
        self == .classic ? "CustomPrimary" : "\(assetPrefix)Primary"
    }

    var secondaryColorName: String {
        self == .classic ? "CustomSecondary" : "\(assetPrefix)Secondary"
    }

    var textColorName: String {
        self == .classic ? "Text" : "\(assetPrefix)Text"
    }

    var subtextColorName: String {
        self == .classic ? "Subtext" : "\(assetPrefix)Subtext"
    }

    var avatarTextColorName: String {
        self == .classic ? "AvatarText" : "\(assetPrefix)AvatarText"
    }

    // Reads the current theme straight from UserDefaults
    static var current: AppTheme {
        guard
            let rawValue = UserDefaults.standard.string(forKey: "selectedTheme"),
            let theme = AppTheme(rawValue: rawValue)
        else {
            return .classic
        }
        return theme
    }
}
