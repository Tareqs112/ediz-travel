import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.menuTarget.classList.contains("hidden")
    if (isHidden) {
      this.menuTarget.classList.remove("hidden")
      document.addEventListener("click", this.boundCloseOnOutsideClick)
    } else {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this.boundCloseOnOutsideClick)
    }
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this.boundCloseOnOutsideClick)
    }
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseOnOutsideClick)
  }
}
