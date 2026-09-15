import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["date", "startTime", "endTime", "driver", "vehicle", "submitButton", "warningContainer"]
  static values = { url: String }

  connect() {
    this.check()
  }

  check() {
    const date = this.dateTarget.value
    const start = this.startTimeTarget.value
    const end = this.endTimeTarget.value
    const driver = this.driverTarget.value
    const vehicle = this.vehicleTarget.value

    if (!date || !start || !end) return
    if (!driver && !vehicle) return

    const params = new URLSearchParams({
      "trip_service[date]": date,
      "trip_service[start_time]": start,
      "trip_service[end_time]": end,
      "trip_service[driver_id]": driver,
      "trip_service[vehicle_id]": vehicle
    })

    fetch(`${this.urlValue}?${params.toString()}`, {
      headers: { "Accept": "application/json" }
    })
    .then(r => r.json())
    .then(data => {
      if (data.has_conflict) {
        this.warningContainerTarget.innerHTML = data.html
        this.warningContainerTarget.classList.remove("hidden")
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      } else {
        this.warningContainerTarget.classList.add("hidden")
        this.warningContainerTarget.innerHTML = ""
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      }
    })
  }
}
