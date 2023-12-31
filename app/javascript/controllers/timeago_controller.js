import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'
import { format } from 'timeago.js'

export default class extends Controller {
  connect () {
    const datetime = this.element.getAttribute('datetime')
    const timeago = format(datetime)
    this.element.innerHTML = timeago

    const currentTitle = this.element.getAttribute('title')
    if (!currentTitle) this.element.setAttribute('title', datetime)
  }
}
