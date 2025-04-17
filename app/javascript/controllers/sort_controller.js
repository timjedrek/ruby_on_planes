import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    paramName: String
  }

  connect() {
    // Controller connected
  }
  
  toggle(event) {
    const button = event.currentTarget
    const currentSort = button.getAttribute('data-current')
    const sortType = button.getAttribute('data-sort-type')
    const newSort = currentSort === 'desc' ? `${sortType}_asc` : `${sortType}_desc`
    
    const currentUrl = new URL(window.location.href)
    currentUrl.searchParams.set(this.paramNameValue, newSort)
    window.location.href = currentUrl.toString()
  }
} 