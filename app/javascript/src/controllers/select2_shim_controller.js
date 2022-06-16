import { Controller } from 'stimulus'
import $ from 'jquery'

export default class extends Controller {
  connect() {
    // Fire native DOM events alongside jquery events so
    // stimulus can listen to them
    $(this.element).on('select2:select', function () {
      const event = new Event('change', { bubbles: true })
      this.dispatchEvent(event)
    })
  }
}
