import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checklist"
export default class extends Controller {
  connect() {
    console.log("checklist");
    const bkCheckboxInputEls = document.querySelectorAll(
      ".booking-checkbox-input"
    );

    bkCheckboxInputEls.forEach((bkCheckboxInputEl) => {
      bkCheckboxInputEl.addEventListener("click", (e) => {
        console.log(e.target.value,e.target.checked);
      });
    });
  }
}
