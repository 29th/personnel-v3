import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['previousUnits', 'selection']

  connect() {
    if (this._selectedOption() === 'Yes') {
      this._show()
    } else {
      this._hide()
    }
  }

  toggle(event) {
    if (event.currentTarget.value === 'Yes') {
      this._show()
    } else {
      this._hide()
    }
  }
  
  _show() {
    this.previousUnitsTarget.style.display = 'block'
  }
  
  _hide() {
    this.previousUnitsTarget.style.display = 'none'
  }
  
  _selectedOption() {
    const selectedOption = this.selectionTargets.find((el) => el.checked)
    return selectedOption?.value
  }
}
