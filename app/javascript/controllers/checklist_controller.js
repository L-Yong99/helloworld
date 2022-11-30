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
        console.log(e.target.value, e.target.checked);
        const activityId = e.target.value;
        const checked = e.target.checked;
        const dataOut = JSON.stringify([activityId, checked]);

        const bookingdataEl = document.querySelector(".booking-data-hidden");
        bookingdataEl.value = dataOut;
        console.log(bookingdataEl)

        const bookingFormEl = document.querySelector(".booking-form");
        console.log(bookingFormEl)

        bookingFormEl.addEventListener("click",(e) => {
          e.preventDefault();
          console.log("lets send");
          fetch(bookingFormEl.action, {
            method: "POST",
            headers: { Accept: "application/json" },
            body: new FormData(bookingFormEl),
          })
            .then((response) => response.json())
            .then((data) => {
              console.log(data);
              if (data.inserted_item) {
                console.log(data.inserted_item);
                // const daysContainerEl = document.querySelector(".days-container");
                // this.element.innerHTML = "";
                // this.element.insertAdjacentHTML(
                //   "beforeend",
                //   data.inserted_item
                // );
              }
              this.formTarget.outerHTML = data.form;
            });
        });

        const bookingSubmitEl = document.querySelector(".booking-submit");
        bookingSubmitEl.click();
      });
    });
  }
}
