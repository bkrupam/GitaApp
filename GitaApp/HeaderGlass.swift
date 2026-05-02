import SwiftUI

// MARK: - Grouping

/// Shared chrome for floating controls. On **iOS 26+** uses neutral **Liquid Glass** (no added tint).
/// On earlier OS versions uses `Material` fills — same translucent look as before.
enum GitaChrome {

    /// Wraps siblings that use Liquid Glass so the system can composite them (iOS 26+ only).
    @ViewBuilder
    static func glassEffectGroup<Content: View>(spacing: CGFloat = 20, @ViewBuilder content: () -> Content) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            content()
        }
    }
}

// MARK: - Legacy materials (iOS < 26)

private enum LegacyHeaderMaterial {
    static func capsuleFill() -> some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
    }

    static func circleFill() -> some View {
        Circle()
            .fill(.ultraThinMaterial)
            .overlay(
                Circle()
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
    }

    static func roundedFieldFill(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            )
    }
}

// MARK: - View extensions

extension View {

    /// Capsule Liquid Glass (or material) for header pills — **neutral** glass unless `tint` is set.
    @ViewBuilder
    func gitaHeaderCapsuleGlass(
        tint: Color? = nil,
        glassID: String? = nil,
        glassNamespace: Namespace.ID? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass = {
                if let tint {
                    return Glass.regular.tint(tint).interactive()
                }
                return Glass.regular.interactive()
            }()
            if let glassID, let glassNamespace {
                self
                    .glassEffect(glass, in: Capsule())
                    .glassEffectID(glassID, in: glassNamespace)
            } else {
                self.glassEffect(glass, in: Capsule())
            }
        } else {
            self.background { LegacyHeaderMaterial.capsuleFill() }
        }
    }

    /// Circle Liquid Glass for icon buttons — **neutral** glass unless `tint` is set.
    @ViewBuilder
    func gitaHeaderCircleGlass(
        tint: Color? = nil,
        glassID: String? = nil,
        glassNamespace: Namespace.ID? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass = {
                if let tint {
                    return Glass.regular.tint(tint).interactive()
                }
                return Glass.regular.interactive()
            }()
            if let glassID, let glassNamespace {
                self
                    .glassEffect(glass, in: Circle())
                    .glassEffectID(glassID, in: glassNamespace)
            } else {
                self.glassEffect(glass, in: Circle())
            }
        } else {
            self.background { LegacyHeaderMaterial.circleFill() }
        }
    }

    /// Rounded rect glass for text fields — **neutral** unless `tint` is set (non-interactive glass on iOS 26).
    @ViewBuilder
    func gitaInputFieldGlass(
        cornerRadius: CGFloat = 20,
        tint: Color? = nil,
        glassID: String? = nil,
        glassNamespace: Namespace.ID? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass = {
                if let tint {
                    return Glass.regular.tint(tint)
                }
                return Glass.regular
            }()
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            if let glassID, let glassNamespace {
                self
                    .glassEffect(glass, in: shape)
                    .glassEffectID(glassID, in: glassNamespace)
            } else {
                self.glassEffect(glass, in: shape)
            }
        } else {
            self.background { LegacyHeaderMaterial.roundedFieldFill(cornerRadius: cornerRadius) }
        }
    }

    /// Floating circular chrome behind an indeterminate `ProgressView` (e.g. chat loading).
    @ViewBuilder
    func gitaLoadingSpinnerChrome() -> some View {
        if #available(iOS 26.0, *) {
            self
                .padding(18)
                .glassEffect(Glass.regular, in: Circle())
        } else {
            self
                .padding(18)
                .background { LegacyHeaderMaterial.circleFill() }
        }
    }

    /// Subtle caption chip under the verse list (iOS 26 glass only; plain text on earlier OS).
    @ViewBuilder
    func gitaProgressCaptionGlass(
        tint: Color? = nil,
        glassID: String? = nil,
        glassNamespace: Namespace.ID? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass = {
                if let tint {
                    return Glass.regular.tint(tint)
                }
                return Glass.regular
            }()
            let padded = self
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            if let glassID, let glassNamespace {
                padded
                    .glassEffect(glass, in: Capsule())
                    .glassEffectID(glassID, in: glassNamespace)
            } else {
                padded.glassEffect(glass, in: Capsule())
            }
        } else {
            self
        }
    }
}
