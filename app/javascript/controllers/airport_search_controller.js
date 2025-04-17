import { Controller } from "@hotwired/stimulus"

// Airport search controller for filtering airports
export default class extends Controller {
  // Define the elements this controller will interact with
  static targets = ["query", "card", "noResults"]

  // When the controller connects to the DOM
  connect() {
    // Initialize with all airports visible
    this.showAllAirports()
  }

  // Show all airports and hide the "no results" message
  showAllAirports() {
    this.cardTargets.forEach(card => {
      card.classList.remove("hidden")
    })
    
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.classList.add("hidden")
    }
  }

  // Filter airports based on search query
  filter() {
    // Get the lowercase trimmed query
    const query = this.queryTarget.value.toLowerCase().trim()
    
    // If empty query, show all airports
    if (query === "") {
      this.showAllAirports()
      return
    }
    
    // Track visible airports count
    let visibleCount = 0
    
    // Filter each airport card
    this.cardTargets.forEach(card => {
      // Get the searchable data from data attributes
      const code = card.dataset.code || ""
      const name = card.dataset.name || ""
      const city = card.dataset.city || ""
      const state = card.dataset.state || ""
      const icao = card.dataset.icao || ""
      
      // Check if the card matches the search query
      const isVisible = 
        code.includes(query) || 
        name.includes(query) || 
        city.includes(query) || 
        state.includes(query) ||
        icao.includes(query)
      
      // Show or hide the card based on the match
      card.classList.toggle("hidden", !isVisible)
      
      // Increment visible count if this card is visible
      if (isVisible) {
        visibleCount++
      }
    })
    
    // Toggle the "no results" message based on visible count
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.classList.toggle("hidden", visibleCount > 0)
    }
  }
} 