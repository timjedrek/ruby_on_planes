import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    // Set up initial state if there's a value
    const rating = parseInt(this.inputTarget.value) || 0
    if (rating > 0) {
      this.updateStars(rating)
    }
  }

  rate(event) {
    const starButton = event.currentTarget
    const value = parseInt(starButton.dataset.value)
    
    // Update hidden input
    this.inputTarget.value = value
    
    // Update stars visually
    this.updateStars(value)
  }
  
  highlight(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    
    // Highlight stars up to the hovered one
    this.starTargets.forEach((star, index) => {
      if (index < value) {
        star.querySelector('svg').classList.add('text-yellow-400')
        star.querySelector('svg').classList.remove('text-gray-300')
      }
    })
  }
  
  restore() {
    const selectedValue = parseInt(this.inputTarget.value) || 0
    
    // Restore to selected rating or clear all
    this.updateStars(selectedValue)
  }
  
  updateStars(value) {
    this.starTargets.forEach((star, index) => {
      const svg = star.querySelector('svg')
      if (index < value) {
        svg.classList.add('text-yellow-400')
        svg.classList.remove('text-gray-300')
      } else {
        svg.classList.remove('text-yellow-400')
        svg.classList.add('text-gray-300')
      }
    })
  }
} 