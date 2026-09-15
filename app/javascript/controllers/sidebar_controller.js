import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  get closedClass() {
    return document.documentElement.dir === 'rtl' ? "translate-x-full" : "-translate-x-full"
  }

  open() {
    this.sidebarTarget.classList.remove(this.closedClass)
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.sidebarTarget.classList.add(this.closedClass)
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  toggle() {
    if (this.sidebarTarget.classList.contains(this.closedClass)) {
      this.open()
    } else {
      this.close()
    }
  }
}
