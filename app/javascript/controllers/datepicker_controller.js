import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {

  static targets = ["datePicker"]
  connect() {
    console.log("date picker")
    this.flatpickrInit();
  }

  flatpickrInit() {
    this.fp = flatpickr(this.datePickerTarget, {mode:"range"})
  }

  disconnect() {
    this.fp.destroy();
  }
}
