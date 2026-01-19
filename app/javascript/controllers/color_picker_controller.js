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
      element.style.backgroundColor = ""
      element.style.backgroundImage = `linear-gradient(to bottom right, ${bgValue}, ${gradValue})`
    } else if (bgValue.length > 0) {
      element.style.backgroundImage = ""
      element.style.backgroundColor = bgValue
    } else if (gradValue.length > 0) {
      element.style.backgroundImage = ""
      element.style.backgroundColor = gradValue
    } else {
      element.style.backgroundColor = ""
      element.style.backgroundImage = `linear-gradient(to bottom right, ${effectiveBg}, ${effectiveGrad})`
    }
  }
}
