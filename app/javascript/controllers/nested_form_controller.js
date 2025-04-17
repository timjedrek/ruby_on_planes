import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container", "add_item"]

  connect() {
    this.wrapperClass = this.data.get("wrapperClass") || "nested-fields"
    this.ensureAtLeastOneField();
  }

  add(event) {
    if (event) event.preventDefault();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString());
    this.containerTarget.insertAdjacentHTML('beforeend', content);
  }

  remove(event) {
    event.preventDefault();
    const item = event.target.closest("." + this.wrapperClass);
    
    // If it's a persisted record, we need to mark it for deletion
    if (item.dataset.newRecord === "false") {
      const destroyField = item.querySelector("input[name*='_destroy']");
      destroyField.value = "1";
      item.style.display = "none";
    } else {
      // If it's a new record, we can just remove it from the DOM
      item.remove();
    }
    
    // Make sure we always have at least one field
    this.ensureAtLeastOneField();
  }

  ensureAtLeastOneField() {
    // Get all visible fields (exclude hidden ones marked for deletion)
    const visibleFields = Array.from(this.containerTarget.querySelectorAll("." + this.wrapperClass))
                         .filter(field => field.style.display !== "none");
                         
    if (visibleFields.length === 0) {
      this.add();
    }
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

    // Get the airport code and school slug from the page path
    let airportCode, schoolSlug
    
    // Try to get airport code and school slug from the page URL
    const pageUrl = window.location.pathname
    console.log("Page URL:", pageUrl)
    
    const urlMatch = pageUrl.match(/\/airports\/([^\/]+)\/schools\/([^\/]+)/)
    if (urlMatch && urlMatch.length >= 3) {
      airportCode = urlMatch[1]
      schoolSlug = urlMatch[2]
      console.log("From page URL - Airport code:", airportCode, "School slug:", schoolSlug)
    } else {
      // Fallback to form action if page URL doesn't match expected pattern
      const formAction = form.getAttribute('action')
      console.log("Form action:", formAction)
      
      const formMatch = formAction.match(/\/airports\/([^\/]+)\/schools\/([^\/]+)/)
      if (!formMatch || formMatch.length < 3) {
        this._showError(wrapper, "Could not determine airport code and school slug from URL", button, originalText)
        return
      }
      
      airportCode = formMatch[1]
      schoolSlug = formMatch[2]
      console.log("From form action - Airport code:", airportCode, "School slug:", schoolSlug)
    }
    
    // Final check
    if (!airportCode || !schoolSlug) {
      this._showError(wrapper, "Missing airport code or school slug", button, originalText)
      return
    }
    
    // Build URL for the AJAX request
    let url
    let method
    
    if (contactId && contactId !== '') {
      // Update existing contact
      url = `/airports/${airportCode}/schools/${schoolSlug}/contact_people/${contactId}`
      method = 'PATCH'
    } else {
      // Create new contact
      url = `/airports/${airportCode}/schools/${schoolSlug}/contact_people`
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