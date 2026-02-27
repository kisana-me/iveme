import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hidden", "picker", "defaultToggle"]
  static values = {
    defaultColor: String,
    cssVar: String,
    applyToSelector: { type: String, default: "main" },
  }

  connect() {
    this.syncFromHidden()
    this.applyPreview()

    this.form = this.element.closest("form")
    const watchesRemoveBackground =
      this.hasCssVarValue &&
      (this.cssVarValue === "--page-background-color" || this.cssVarValue === "--page-gradient-color")

    if (this.form && watchesRemoveBackground) {
      this._onFormChange = (event) => {
        const target = event.target
        if (!(target instanceof HTMLInputElement)) return
        if (target.type !== "checkbox") return

        if (target.name && target.name.endsWith("[remove_background]")) {
          this.applyPreview()
        }
      }

      this.form.addEventListener("change", this._onFormChange)
    }
  }

  disconnect() {
    if (this.form && this._onFormChange) {
      this.form.removeEventListener("change", this._onFormChange)
    }
  }

  pick() {
    if (this.hasDefaultToggleTarget && this.defaultToggleTarget.checked) return
    this.hiddenTarget.value = this.pickerTarget.value
    this.applyPreview()
  }

  toggleDefault() {
    if (!this.hasDefaultToggleTarget) return

    const isDefault = this.defaultToggleTarget.checked
    this.pickerTarget.disabled = isDefault

    if (isDefault) {
      this.hiddenTarget.value = ""
      this.pickerTarget.value = this.defaultColorValue || "#000000"
    } else {
      this.hiddenTarget.value = this.pickerTarget.value
    }

    this.applyPreview()
  }

  syncFromHidden() {
    const current = (this.hiddenTarget.value || "").trim()
    const isDefault = current.length === 0

    if (this.hasDefaultToggleTarget) {
      this.defaultToggleTarget.checked = isDefault
    }

    this.pickerTarget.disabled = isDefault
    this.pickerTarget.value = isDefault ? (this.defaultColorValue || "#000000") : current
  }

  applyPreview() {
    this.applyCssVarPreview()

    if (
      this.hasCssVarValue &&
      (this.cssVarValue === "--page-background-color" || this.cssVarValue === "--page-gradient-color")
    ) {
      this.applyBackgroundPreview()
    }
  }

  applyCssVarPreview() {
    if (!this.hasCssVarValue) return

    const element = document.querySelector(this.applyToSelectorValue)
    if (!element) return

    const useDefault = this.hasDefaultToggleTarget && this.defaultToggleTarget.checked
    const value = useDefault ? (this.defaultColorValue || "#000000") : this.pickerTarget.value

    element.style.setProperty(this.cssVarValue, value)
  }

  applyBackgroundPreview() {
    const element = document.querySelector(this.applyToSelectorValue)
    if (!element) return

    const form = this.element.closest("form")
    if (!form) return

    const hasBackgroundImage = (form.dataset.pageHasBackgroundImage || "").toLowerCase() === "true"
    const removeBackgroundToggle = form.querySelector('input[type="checkbox"][name$="[remove_background]"]')
    const removeBackground = !!(removeBackgroundToggle && removeBackgroundToggle.checked)

    const backgroundFileInput = form.querySelector('input[type="file"][name$="[background_file]"]')
    const hasNewBackgroundFile = !!(backgroundFileInput && backgroundFileInput.files && backgroundFileInput.files.length > 0)

    if (hasNewBackgroundFile && !removeBackground) {
      // Background is currently previewed via selected file (blob URL).
      // Don't clear/override it just because colors changed.
      return
    }

    if (hasBackgroundImage && !removeBackground) {
      // Restore the original (server-rendered) background image/overlay.
      element.style.removeProperty("--page-bg-image")
      element.style.removeProperty("--page-bg-overlay")
      element.style.removeProperty("--page-bg-size")
      element.style.removeProperty("--page-bg-position")
      element.style.removeProperty("--page-bg-attachment")
      element.style.removeProperty("--page-bg-gradient")
      element.style.removeProperty("--page-bg-color")
      return
    }

    if (removeBackground) {
      // Force-hide any existing background image while remove_background is checked.
      element.style.setProperty("--page-bg-image", "none")
      element.style.setProperty("--page-bg-overlay", "none")
      element.style.setProperty("--page-bg-size", "auto")
      element.style.setProperty("--page-bg-position", "0% 0%")
      element.style.setProperty("--page-bg-attachment", "scroll")
    }

    const bgHidden = form.querySelector('input[type="hidden"][name$="[background_color]"]')
    const gradHidden = form.querySelector('input[type="hidden"][name$="[gradient_color]"]')

    const bgValue = (bgHidden?.value || "").trim()
    const gradValue = (gradHidden?.value || "").trim()

    const bgDefault = (form.querySelector('[data-color-picker-css-var-value="--page-background-color"]')
      ?.dataset?.colorPickerDefaultColorValue || "#F0F0F0").trim()
    const gradDefault = (form.querySelector('[data-color-picker-css-var-value="--page-gradient-color"]')
      ?.dataset?.colorPickerDefaultColorValue || "#D0D0D0").trim()

    const effectiveBg = bgValue.length > 0 ? bgValue : bgDefault
    const effectiveGrad = gradValue.length > 0 ? gradValue : gradDefault

    element.style.setProperty("--page-background-color", effectiveBg)
    element.style.setProperty("--page-gradient-color", effectiveGrad)

    if (bgValue.length > 0 && gradValue.length > 0) {
      element.style.setProperty("--page-bg-color", "transparent")
      element.style.setProperty("--page-bg-gradient", `linear-gradient(to bottom right, ${bgValue}, ${gradValue})`)
    } else if (bgValue.length > 0) {
      element.style.setProperty("--page-bg-gradient", "none")
      element.style.setProperty("--page-bg-color", bgValue)
    } else if (gradValue.length > 0) {
      element.style.setProperty("--page-bg-gradient", "none")
      element.style.setProperty("--page-bg-color", gradValue)
    } else {
      element.style.setProperty("--page-bg-color", "transparent")
      element.style.setProperty("--page-bg-gradient", `linear-gradient(to bottom right, ${effectiveBg}, ${effectiveGrad})`)
    }
  }
}
