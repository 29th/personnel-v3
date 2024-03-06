import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    if (!this.element.value) {
      this.element.value = this._guessTimeZone()
    }
  }

  _guessTimeZone () {
    return Intl.DateTimeFormat().resolvedOptions().timeZone
  }
}
