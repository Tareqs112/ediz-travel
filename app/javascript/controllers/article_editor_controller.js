import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "input", "tagInput", "imageUploadInput"]

  connect() {
    if (this.hasEditorTarget && this.hasInputTarget) {
      if (!this.editorTarget.innerHTML.trim() && this.inputTarget.value) {
        this.editorTarget.innerHTML = this.inputTarget.value
      }
    }
  }

  sync() {
    if (this.hasEditorTarget && this.hasInputTarget) {
      this.inputTarget.value = this.editorTarget.innerHTML
    }
  }

  format(event) {
    event.preventDefault()
    const command = event.currentTarget.dataset.command
    const value = event.currentTarget.dataset.value || null
    this.editorTarget.focus()
    document.execCommand(command, false, value)
    this.sync()
  }

  formatBlock(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    this.editorTarget.focus()
    document.execCommand("formatBlock", false, tag)
    this.sync()
  }

  createLink(event) {
    event.preventDefault()
    const url = prompt("Enter destination URL (e.g. https://... or /tours):")
    if (url) {
      this.editorTarget.focus()
      document.execCommand("createLink", false, url)
      this.sync()
    }
  }

  insertImageTag(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.imageUrl
    const alt = event.currentTarget.dataset.imageAlt || "Article image"
    if (url) {
      this.editorTarget.focus()
      const html = `<figure class="article-figure my-8"><img src="${url}" alt="${alt}" class="rounded-lg shadow-sm mx-auto max-w-full" loading="lazy" /></figure><p><br></p>`
      document.execCommand("insertHTML", false, html)
      this.sync()
    }
  }

  uploadInlineImage(event) {
    const file = event.target.files[0]
    if (!file) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content")
    const formData = new FormData()
    formData.append("file", file)

    fetch("/admin/travel_guides/upload_image", {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken
      },
      body: formData
    })
      .then(response => {
        if (!response.ok) throw new Error("Upload failed")
        return response.json()
      })
      .then(data => {
        this.editorTarget.focus()
        const html = `<figure class="article-figure my-8"><img src="${data.url}" alt="${data.filename}" class="rounded-lg shadow-sm mx-auto max-w-full" loading="lazy" /></figure><p><br></p>`
        document.execCommand("insertHTML", false, html)
        this.sync()
        // Reset file input
        event.target.value = ""
      })
      .catch(error => {
        alert("Image upload failed. Please try again.")
        console.error(error)
      })
  }

  appendTag(event) {
    event.preventDefault()
    const tag = event.currentTarget.dataset.tag
    if (!this.hasTagInputTarget || !tag) return

    const currentTags = this.tagInputTarget.value
      .split(",")
      .map(t => t.trim())
      .filter(t => t.length > 0)

    if (!currentTags.includes(tag)) {
      currentTags.push(tag)
      this.tagInputTarget.value = currentTags.join(", ")
    }
  }
}
