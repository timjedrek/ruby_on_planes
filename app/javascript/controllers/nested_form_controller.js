import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "add_item"]

  connect() {
    this.wrapperClass = this.data.get("wrapperClass") || "nested-fields"
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest("." + this.wrapperClass)
    
    // New records are simply removed from the page
    if (wrapper.dataset.newRecord == "true") {
      wrapper.remove()
      
    // Existing records are hidden and flagged for deletion
    } else {
      wrapper.querySelector("input[name*='_destroy']").value = 1
      wrapper.style.display = 'none'
    }
  }
} 