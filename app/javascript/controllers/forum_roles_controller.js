import { Controller } from '@hotwired/stimulus'
import $ from 'jquery'

export default class extends Controller {
  static targets = ['forum', 'discourseRoles', 'vanillaRoles']

  connect() {
    this.showForumRoles()
  }

  showForumRoles() {
    const forum = $(this.forumTarget).val()
    $(this.discourseRolesTarget).parent('li').toggle(forum === 'discourse')
    $(this.vanillaRolesTarget).parent('li').toggle(forum === 'vanilla')
  }
}
