import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    autoHide: { type: Boolean, default: true },
    autoHideDelay: { type: Number, default: 5000 }
  }

  connect() {
    // Show toast when controller connects
    this.show()
    
    // Setup auto-hide if enabled
    if (this.autoHideValue) {
      this.hideTimeout = setTimeout(() => {
        this.hide()
      }, this.autoHideDelayValue)
    }
  }

  disconnect() {
    // Clear timeout if controller disconnects
    if (this.hideTimeout) clearTimeout(this.hideTimeout)
  }

  show() {
    // Add 'showing' class to trigger enter transition
    this.containerTarget.classList.remove("hidden")
    
    // Use setTimeout to ensure DOM updates before adding transition class
    setTimeout(() => {
      this.containerTarget.classList.add("opacity-100")
      this.containerTarget.classList.add("translate-y-0")
      this.containerTarget.classList.remove("opacity-0")
      this.containerTarget.classList.remove("translate-y-2")
    }, 10)
  }

  hide() {
    // Add 'hiding' class to trigger leave transition
    this.containerTarget.classList.add("opacity-0")
    this.containerTarget.classList.add("translate-y-2")
    this.containerTarget.classList.remove("opacity-100")
    this.containerTarget.classList.remove("translate-y-0")
    
    // Remove from DOM after transition
    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
    }, 300) // Match transition duration
  }

  close() {
    // Clear auto-hide timeout if it exists
    if (this.hideTimeout) clearTimeout(this.hideTimeout)
    
    // Trigger hide animation
    this.hide()
  }
} 