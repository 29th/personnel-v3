import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'

export default class extends Controller {
  connect () {
    const content = this.element.getAttribute('title')
    tippy(this.element, { content, allowHTML: true})
    this.element.dataset.originalTitle = content
    this.element.setAttribute('title', '')
  }
}
