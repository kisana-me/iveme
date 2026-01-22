import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "icon",
    "iconInput",
    "removeIconToggle",
    "removeIconRow",
    "backgroundInput",
    "removeBackgroundToggle",
    "removeBackgroundRow",
  ]

  static values = {
    defaultIconUrl: String,
    applyToSelector: { type: String, default: "main" },
    hasIcon: Boolean,
    hasBackground: Boolean,
  }

  connect() {
    if (this.hasIconTarget) {
      this.originalIconSrc = this.iconTarget.getAttribute("src")
    }

    this.syncRemoveRows()
  }

  disconnect() {
    this.revokeIconObjectUrl()
    this.revokeBackgroundObjectUrl()
  }

  iconChanged() {
    const file = this.iconInputTarget?.files?.[0]

    if (!file) {
      this.restoreIconPreview()
      this.syncRemoveRows()
      return
    }

    if (this.hasRemoveIconToggleTarget) {
      this.removeIconToggleTarget.checked = false
    }

    this.revokeIconObjectUrl()
    this.iconObjectUrl = URL.createObjectURL(file)

    if (this.hasIconTarget) {
      this.iconTarget.src = this.iconObjectUrl
    }

    this.syncRemoveRows({ showIcon: true })
  }

  removeIconToggled() {
    const isRemoving = this.hasRemoveIconToggleTarget && this.removeIconToggleTarget.checked

    if (isRemoving) {
      if (this.hasIconInputTarget) {
        this.iconInputTarget.value = ""
      }

      this.revokeIconObjectUrl()

      if (this.hasIconTarget) {
        this.iconTarget.src = this.defaultIconUrlValue || this.originalIconSrc || ""
      }
    } else {
      this.restoreIconPreview()
    }

    this.syncRemoveRows()
  }

  backgroundChanged() {
    const file = this.backgroundInputTarget?.files?.[0]

    if (!file) {
      this.clearInlineBackgroundPreview()
      this.syncRemoveRows()
      return
    }

    if (this.hasRemoveBackgroundToggleTarget) {
      this.removeBackgroundToggleTarget.checked = false
    }

    this.revokeBackgroundObjectUrl()
    this.backgroundObjectUrl = URL.createObjectURL(file)

    const element = document.querySelector(this.applyToSelectorValue)
    if (!element) return

    element.style.backgroundImage = `url("${this.backgroundObjectUrl}")`
    element.style.backgroundSize = "cover"
    element.style.backgroundPosition = "center"
    element.style.backgroundAttachment = "fixed"
    element.style.backgroundColor = ""

    this.syncRemoveRows({ showBackground: true })
  }

  removeBackgroundToggled() {
    const isRemoving = this.hasRemoveBackgroundToggleTarget && this.removeBackgroundToggleTarget.checked

    if (isRemoving) {
      if (this.hasBackgroundInputTarget) {
        this.backgroundInputTarget.value = ""
      }

      this.revokeBackgroundObjectUrl()
      this.clearInlineBackgroundPreview()
    }

    this.syncRemoveRows({ showBackground: true })
    // The color-picker controllers will react to this change and apply
    // solid/gradient preview while remove_background is checked.
  }

  syncRemoveRows(options = {}) {
    const showIcon = options.showIcon === true || this.hasHasIconValue || (!!this.iconInputTarget?.files?.length)
    const showBackground =
      options.showBackground === true || this.hasHasBackgroundValue || (!!this.backgroundInputTarget?.files?.length)

    if (this.hasRemoveIconRowTarget) {
      this.removeIconRowTarget.style.display = showIcon ? "block" : "none"
      if (!showIcon && this.hasRemoveIconToggleTarget) this.removeIconToggleTarget.checked = false
    }

    if (this.hasRemoveBackgroundRowTarget) {
      this.removeBackgroundRowTarget.style.display = showBackground ? "block" : "none"
      if (!showBackground && this.hasRemoveBackgroundToggleTarget) this.removeBackgroundToggleTarget.checked = false
    }
  }

  restoreIconPreview() {
    const file = this.hasIconInputTarget ? this.iconInputTarget.files?.[0] : undefined
    if (file) {
      this.iconChanged()
      return
    }

    if (this.hasIconTarget) {
      this.iconTarget.src = this.originalIconSrc || this.defaultIconUrlValue || ""
    }
  }

  clearInlineBackgroundPreview() {
    const element = document.querySelector(this.applyToSelectorValue)
    if (!element) return

    element.style.backgroundImage = ""
    element.style.backgroundSize = ""
    element.style.backgroundPosition = ""
    element.style.backgroundAttachment = ""
    element.style.backgroundColor = ""
  }

  revokeIconObjectUrl() {
    if (this.iconObjectUrl) {
      URL.revokeObjectURL(this.iconObjectUrl)
      this.iconObjectUrl = null
    }
  }

  revokeBackgroundObjectUrl() {
    if (this.backgroundObjectUrl) {
      URL.revokeObjectURL(this.backgroundObjectUrl)
      this.backgroundObjectUrl = null
    }
  }
}
