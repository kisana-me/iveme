import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hidden", "picker", "defaultToggle"]
  static values = { defaultColor: String }

  connect() {
    this.syncFromHidden()
  }

  pick() {
    if (this.hasDefaultToggleTarget && this.defaultToggleTarget.checked) return
    this.hiddenTarget.value = this.pickerTarget.value
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
}
