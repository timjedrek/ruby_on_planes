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
      return
    }
    
    // Get contact person ID for persisted records
    const contactId = wrapper.querySelector('input[name*="[id]"]')?.value
    
    if (!contactId) {
      console.error("Cannot find contact ID for deletion")
      return
    }
    
    // Show removal indicator
    wrapper.classList.add('opacity-50')
    wrapper.style.position = 'relative'
    
    const loadingOverlay = document.createElement('div')
    loadingOverlay.className = 'absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10'
    loadingOverlay.innerHTML = `
      <svg class="animate-spin h-8 w-8 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    `
    wrapper.appendChild(loadingOverlay)
    
    // Get airport code and school ID from page URL
    const pageUrl = window.location.pathname
    const urlMatch = pageUrl.match(/\/airports\/([^\/]+)\/schools\/(\d+)/)
    
    if (!urlMatch || urlMatch.length < 3) {
      console.error("Cannot extract airport code and school ID from URL")
      wrapper.classList.remove('opacity-50')
      loadingOverlay.remove()
      return
    }
    
    const airportCode = urlMatch[1]
    const schoolId = urlMatch[2]
    
    // Build URL for the AJAX delete request
    const url = `/airports/${airportCode}/schools/${schoolId}/contact_people/${contactId}`
    console.log("Making DELETE request to:", url)
    
    // Add CSRF token
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    
    // Send AJAX delete request
    fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'application/json'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error("Failed to delete contact")
      }
      
      // For successful deletion, remove the element
      wrapper.remove()
    })
    .catch(error => {
      console.error('Error deleting contact:', error)
      
      // In case of error, mark as deleted in the form but show an error
      wrapper.classList.remove('opacity-50')
      loadingOverlay.remove()
      
      // Set the _destroy flag but keep the element visible with error styling
      wrapper.querySelector("input[name*='_destroy']").value = 1
      
      // Add error message
      const messageDiv = document.createElement('div')
      messageDiv.className = 'text-red-600 text-sm mt-2 error-message'
      messageDiv.textContent = "Error deleting contact. The contact will be removed when you save the form."
      wrapper.querySelector('.mt-4').prepend(messageDiv)
      
      // Style to indicate pending deletion
      wrapper.classList.add('border-red-300', 'bg-red-50')
    })
  }

  saveContact(event) {
    event.preventDefault()
    const button = event.currentTarget
    const wrapper = button.closest("." + this.wrapperClass)
    
    // Remove any existing error message
    const existingMessages = wrapper.querySelectorAll('.error-message, .success-message')
    existingMessages.forEach(msg => msg.remove())
    
    const form = wrapper.closest("form")
    
    // Show saving indicator
    const originalText = button.innerHTML
    button.disabled = true
    button.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Saving...
    `

    // Extract the contact person ID if it exists (for updates)
    const contactId = wrapper.querySelector('input[name*="[id]"]')?.value

    // Get the airport code and school ID from the page path, not just the form action
    // The form action might be /airports/KGAI/schools/123/edit?params which needs careful parsing
    let airportCode, schoolId
    
    // Try to get airport code and school ID from the page URL first
    const pageUrl = window.location.pathname
    console.log("Page URL:", pageUrl)
    
    const urlMatch = pageUrl.match(/\/airports\/([^\/]+)\/schools\/(\d+)/)
    if (urlMatch && urlMatch.length >= 3) {
      airportCode = urlMatch[1]
      schoolId = urlMatch[2]
      console.log("From page URL - Airport code:", airportCode, "School ID:", schoolId)
    } else {
      // Fallback to form action if page URL doesn't match expected pattern
      const formAction = form.getAttribute('action')
      console.log("Form action:", formAction)
      
      const formMatch = formAction.match(/\/airports\/([^\/]+)\/schools\/(\d+)/)
      if (!formMatch || formMatch.length < 3) {
        this._showError(wrapper, "Could not determine airport code and school ID from URL", button, originalText)
        return
      }
      
      airportCode = formMatch[1]
      schoolId = formMatch[2]
      console.log("From form action - Airport code:", airportCode, "School ID:", schoolId)
    }
    
    // Final check
    if (!airportCode || !schoolId) {
      this._showError(wrapper, "Missing airport code or school ID", button, originalText)
      return
    }
    
    // Build URL for the AJAX request
    let url
    let method
    
    if (contactId && contactId !== '') {
      // Update existing contact
      url = `/airports/${airportCode}/schools/${schoolId}/contact_people/${contactId}`
      method = 'PATCH'
    } else {
      // Create new contact
      url = `/airports/${airportCode}/schools/${schoolId}/contact_people`
      method = 'POST'
    }
    
    console.log("Making request to:", url)

    // Create the form data object for this contact person only
    const contactFormData = new FormData()
    
    // Extract values from this contact person's form fields
    const nameField = wrapper.querySelector('input[name$="[name]"]')
    const titleField = wrapper.querySelector('input[name$="[title]"]')
    const emailField = wrapper.querySelector('input[name$="[email]"]')
    const phoneField = wrapper.querySelector('input[name$="[phone]"]')
    
    // Validate required fields
    if (!nameField.value.trim()) {
      this._showError(wrapper, "Name is required", button, originalText)
      return
    }
    
    contactFormData.append("contact_person[name]", nameField.value)
    if (titleField) contactFormData.append("contact_person[title]", titleField.value)
    if (emailField) contactFormData.append("contact_person[email]", emailField.value)
    if (phoneField) contactFormData.append("contact_person[phone]", phoneField.value)

    // Add CSRF token
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    
    // Send the AJAX request
    fetch(url, {
      method: method,
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'application/json'
      },
      body: contactFormData
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(data => {
          throw new Error(data.message || "Server error")
        })
      }
      return response.json()
    })
    .then(data => {
      // Show success message
      wrapper.classList.add('border-green-500')
      
      // If this was a new record, update the form with the ID
      if (!contactId && data.id) {
        const idField = document.createElement('input')
        idField.type = 'hidden'
        idField.name = `school[contact_people_attributes][${wrapper.dataset.index}][id]`
        idField.value = data.id
        wrapper.appendChild(idField)
        
        // Update data-new-record attribute
        wrapper.dataset.newRecord = "false"
      }
      
      // Add a success message
      this._showSuccess(wrapper, "Contact saved successfully!")
      
      // Remove the success styling after 3 seconds
      setTimeout(() => {
        wrapper.classList.remove('border-green-500')
      }, 3000)
    })
    .catch(error => {
      console.error('Error:', error)
      // Show error message
      this._showError(wrapper, error.message || "Error saving contact. Please try again.", button, originalText)
    })
    .finally(() => {
      // Restore button state
      button.disabled = false
      button.innerHTML = originalText
    })
  }
  
  _showError(wrapper, message, button, originalText) {
    // Make sure button is reset
    button.disabled = false
    button.innerHTML = originalText
    
    // Add error styling
    wrapper.classList.add('border-red-500')
    
    // Create error message
    const messageDiv = document.createElement('div')
    messageDiv.className = 'text-red-600 text-sm mt-2 error-message'
    messageDiv.textContent = message
    wrapper.querySelector('.mt-4').prepend(messageDiv)
    
    // Remove the error styling after 5 seconds
    setTimeout(() => {
      wrapper.classList.remove('border-red-500')
    }, 5000)
  }
  
  _showSuccess(wrapper, message) {
    // Create success message
    const messageDiv = document.createElement('div')
    messageDiv.className = 'text-green-600 text-sm mt-2 success-message'
    messageDiv.textContent = message
    wrapper.querySelector('.mt-4').prepend(messageDiv)
    
    // Remove the success message after 3 seconds
    setTimeout(() => {
      messageDiv.remove()
    }, 3000)
  }
} 