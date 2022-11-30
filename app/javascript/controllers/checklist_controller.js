import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="checklist"
export default class extends Controller {
  connect() {
    console.log("checklist");
    this.#bookingChecklist();
    this.#addtodo();
    this.#checkTodo();

    const prepareChecklistEl = document.querySelector(
      ".prepare-checklist"
    );

    prepareChecklistEl.addEventListener("click", (e) => {
        console.log("mytarget",e.target.dataset)
        const listId = e.target.dataset.todoId
        // console.log(e.target.value, e.target.checked);
        console.log("listID",listId)


        const tododeletedataEl = document.querySelector(".todo-deletedata-hidden");
        tododeletedataEl.value = listId;
        console.log(tododeletedataEl);

        const tododeleteFormEl = document.querySelector(".todo-delete-form");
        console.log(tododeleteFormEl);

        tododeleteFormEl.addEventListener("click", (e) => {
          e.preventDefault();
          console.log("lets send");
          fetch(tododeleteFormEl.action, {
            method: "POST",
            headers: { Accept: "application/json" },
            body: new FormData(tododeleteFormEl),
          })
            .then((response) => response.json())
            .then((data) => {
              console.log(data.inserted_item);
              if (data.inserted_item) {
                console.log(data.inserted_item);
                const prepareChecklistEl =
                  document.querySelector(".prepare-checklist");
                prepareChecklistEl.innerHTML = "";
                prepareChecklistEl.insertAdjacentHTML(
                  "beforeend",
                  data.inserted_item
                );
                document.querySelector(".add-list").value = "";
              }
              this.formTarget.outerHTML = data.form;
            });
        });

        const tododeleteSubmitEl = document.querySelector(".todo-delete-submit");
        tododeleteSubmitEl.click();
      });


  }

  //========================= Functions ========================================
  #checkTodo() {
    const prepareChecklistEl = document.querySelector(
      ".prepare-checklist"
    );

    prepareChecklistEl.addEventListener("click", (e) => {
        console.log("mytarget",e.target)
        console.log(e.target.value, e.target.checked);
        const listId = e.target.value;
        const checked = e.target.checked;
        const dataOut = JSON.stringify([listId, checked]);

        const tododataEl = document.querySelector(".todo-data-hidden");
        tododataEl.value = dataOut;
        console.log(tododataEl);

        const todoFormEl = document.querySelector(".todo-form");
        console.log(todoFormEl);

        todoFormEl.addEventListener("click", (e) => {
          e.preventDefault();
          console.log("lets send");
          fetch(todoFormEl.action, {
            method: "POST",
            headers: { Accept: "application/json" },
            body: new FormData(todoFormEl),
          })
            .then((response) => response.json())
            .then((data) => {
              console.log(data);
              if (data.inserted_item) {
                console.log(data.inserted_item);
              }
              this.formTarget.outerHTML = data.form;
            });
        });

        const todoSubmitEl = document.querySelector(".todo-submit");
        todoSubmitEl.click();
      });

  }

  #addtodo() {
    console.log("checklist");
    this.#bookingChecklist();

    const addFormEl = document.querySelector(".add-form");

    addFormEl.addEventListener("submit", (e) => {
      console.log(addFormEl);

      e.preventDefault();
      console.log("lets send");
      fetch(addFormEl.action, {
        method: "POST",
        headers: { Accept: "application/json" },
        body: new FormData(addFormEl),
      })
        .then((response) => response.json())
        .then((data) => {
          console.log(data);
          if (data.inserted_item) {
            console.log(data.inserted_item);
            const prepareChecklistEl =
              document.querySelector(".prepare-checklist");
            prepareChecklistEl.innerHTML = "";
            prepareChecklistEl.insertAdjacentHTML(
              "beforeend",
              data.inserted_item
            );
            document.querySelector(".add-list").value = "";
          }
          this.formTarget.outerHTML = data.form;
        });
    });
  }

  #bookingChecklist() {
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
        console.log(bookingdataEl);

        const bookingFormEl = document.querySelector(".booking-form");
        console.log(bookingFormEl);

        bookingFormEl.addEventListener("click", (e) => {
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
