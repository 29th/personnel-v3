import { Controller } from 'stimulus'
import $ from 'jquery'

export default class extends Controller {
  static targets = ['forum', 'discourseRoles', 'vanillaRoles']

  connect() {
    $(this.forumTarget).on('select2:select', function () {
      const event = new Event('change', { bubbles: true })
      this.dispatchEvent(event)
    })
    this.showForumRoles()
  }

  showForumRoles() {
    const forum = $(this.forumTarget).val()
    $(this.discourseRolesTarget).parent('li').toggle(forum === 'discourse')
    $(this.vanillaRolesTarget).parent('li').toggle(forum === 'vanilla')
  }
}
