import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["animate"]

  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("fade-in-up");
          this.observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });

    document.querySelectorAll('.animate-on-scroll').forEach((el) => {
      this.observer.observe(el);
    });
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}
