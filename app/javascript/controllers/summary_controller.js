// import { Controller } from "@hotwired/stimulus"


// export default class extends Controller {
//  static targets = [ "start", "view", "end", "review" ]
//  static values = { index: Number }

//   startTrip() {
//     console.log("trip started")
//     this.startTarget.hidden = true
//     this.viewTarget.hidden = false
//     this.endTarget.hidden = false
//   }

  // clickview() {
  //   this.indexValue++
  // }


  // indexValueChanged() {
  //   this.showCurrentButton()
  // }

  // showCurrentButton() {
  //   this.buttonTargets.forEach((element, index) => {
  //     this.indexValue = this.indexValue % 4
  //     element.hidden = (index != this.indexValue)
  //   })
  // }
  // showEndButton() {
  //   this.buttonTargets.forEach((element, index) => {
  //     this.indexValue = this.indexValue % 4
  //     element.hidden = (index != this.indexValue)
  //   })
  // }


// }

// Connects to data-controller="summary"
// export default class extends Controller {
//   connect() {
//     console.log("wooha");
//     let summaryBtn = document.querySelector(".summary_btn");
//     console.log("check summary button innertext", summaryBtn.textContent);
//     let parentLink = summaryBtn.closest("form[action]");
//     console.log("parent link", parentLink.action);

//     if (summaryBtn.innerText == "start trip") {
//         summaryBtn.addEventListener("click", () => {
//         console.log("btn linked and click working");
//         console.log("if matches", summaryBtn.innerText)
//         summaryBtn.innerText = "view trip"
//         console.log("bhuh");
//       });

//     };

//   };
// };
