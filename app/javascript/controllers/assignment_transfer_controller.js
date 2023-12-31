import { Controller } from '@hotwired/stimulus'
import $ from 'jquery'
import axios from 'axios'

export default class extends Controller {
  static targets = ['user', 'assignments']
  static values = { assignmentsUrl: String }

  connect() {
    this.loadAssignments()
  }

  async loadAssignments() {
    const $assignmentsTarget = $(this.assignmentsTarget)
    $assignmentsTarget.val(null).empty().trigger('change') // clear opts

    const user = this.userTarget.value
    if (!user) return

    const params = this._constructParams(user)
    const url = this.assignmentsUrlValue
    const response = await axios.get(url, { params })
    const options = response.data.map(this._constructOption)

    $assignmentsTarget
      .append(this._constructEmptyOption)
      .append(options)
      .trigger('change')
  }

  _constructParams(user) {
    return {
      'q[user_id_eq]': user,
      scope: 'active'
    }
  }

  _constructOption(assignment) {
    const text = `${assignment.unit.abbr} - ${assignment.position.name}`
    const id = assignment.id
    return new Option(text, id)
  }

  _constructEmptyOption() {
    return new Option('', '')
  }
}
