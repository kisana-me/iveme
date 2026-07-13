import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hidden", "range"]

  connect() {
    this.pick()
  }

  pick() {
    const main = document.querySelector("main")
    if (!main) return

    const raw = this.rangeTarget?.value
    const hue = Number.parseInt(raw, 10)
    if (Number.isNaN(hue)) return

    const clampedHue = Math.max(0, Math.min(360, hue))
    main.style.setProperty("--theme-hsl-color", `hsl(${clampedHue}, 75%, 70%)`)
    main.style.setProperty("--page-font-color", `hsl(${clampedHue}, 75%, 70%)`)
  }
}
