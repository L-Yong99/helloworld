import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "modal"]
  connect() {
    console.log("modal")
    console.log(this.modalTarget)
  }

  openModal(){
      this.modalTarget.classList.add("active")
  }

  closeModal(){
    this.modalTarget.classList.remove("active")
}
}
