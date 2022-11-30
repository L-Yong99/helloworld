import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="summarypage"
export default class extends Controller {
  connect() {
    console.log("i am summary controller")

    this.#selectDateEventPopUp()

  }

  #selectDateEventPopUp() {
    // Pop up date event listener (AJAX) - Add activities
    const dateEl = document.querySelector(".summary-date");
    console.log("date", dateEl);

    dateEl.addEventListener("change", (e) => {
      // const daysEl = document.querySelectorAll(".summary-day");
      const day = e.target.value;
      console.log(day)

      const summaryDateFormEl = document.querySelector(".summary-date-form");

      summaryDateFormEl.addEventListener("submit", (e) => {
        e.preventDefault();
        console.log("lets send");
        fetch(summaryDateFormEl.action, {
          method: "POST",
          headers: { Accept: "application/json" },
          body: new FormData(summaryDateFormEl),
        })
          .then((response) => response.json())
          .then((data) => {
            // console.log(data);
            if (data.inserted_item) {
              console.log(data.inserted_item)
              // const daysContainerEl = document.querySelector(".days-container");
              this.element.innerHTML = "";
              this.element.insertAdjacentHTML(
                "beforeend",
                data.inserted_item
              );

            }
            this.formTarget.outerHTML = data.form;
          });
      });

      const submitEl = document.querySelector(".summary-date-submit");
      submitEl.click();
    });
  }
}
