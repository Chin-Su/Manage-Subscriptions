//
//  ContentView.swift
//  sandbox
//
//  Created by Đỗ Trung Thành on 13/1/26.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var showError = false
    @State private var errorMessage = ""

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }
    
    private var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }

    var body: some View {
        List {
            // App Header Section 
            Section {
                HStack(spacing: 14) {
                    // App Icon
                    if let icon = appIcon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    
                    // App Name & Description
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sandbox")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(NSLocalizedString("app_description", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Settings Section
            Section {
                SettingsRow(
                    icon: "gearshape.fill",
                    iconColor: .gray,
                    title: NSLocalizedString("settings_sandbox", comment: ""),
                    action: openAppSettings
                )
            }
            
            // Subscriptions Section
            Section {
                SettingsRow(
                    icon: "creditcard.fill",
                    iconColor: .blue,
                    title: NSLocalizedString("manage_sandbox_subscriptions", comment: ""),
                    action: openSandboxSubscriptions
                )
                
                SettingsRow(
                    icon: "bag.fill",
                    iconColor: .pink,
                    title: NSLocalizedString("manage_appstore_subscriptions", comment: ""),
                    showExternalLink: true,
                    action: openAppStoreSubscriptions
                )
            } header: {
                Text(NSLocalizedString("subscriptions_header", comment: ""))
            } footer: {
                Text(NSLocalizedString("subscriptions_footer", comment: ""))
            }
            
            // Footer
            Section {
            } footer: {
                Text("\(appVersion) • © vn.5137")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert(NSLocalizedString("error_title", comment: ""), isPresented: $showError) {
            Button(NSLocalizedString("ok", comment: ""), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func openSandboxSubscriptions() {
        guard let scene = activeWindowScene else {
            showSubscriptionError(NSLocalizedString("error_no_active_scene", comment: ""))
            return
        }
        Task { @MainActor in
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                showSubscriptionError(error.localizedDescription)
            }
        }
    }

    private var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first { $0.activationState == .foregroundInactive }
    }

    private func showSubscriptionError(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func openAppStoreSubscriptions() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var showExternalLink: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text(title)
                    .foregroundColor(.primary)

                Spacer()

                if showExternalLink {
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
