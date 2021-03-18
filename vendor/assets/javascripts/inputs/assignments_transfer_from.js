$(document).ready(function () {
  if (!isNewAssignmentPage()) return

  const userInput = $('#assignment_member_id')
  const transferFromInput = $('#assignment_transfer_from_unit_id')
  if (!userInput || !transferFromInput) return

  fetchAssignmentsAndFillSelect() // run on load
  userInput.on('change', fetchAssignmentsAndFillSelect)

  function isNewAssignmentPage () {
    return !! document.querySelector('body.admin_assignments.new')
  }

  function fetchAssignmentsAndFillSelect () {
    transferFromInput.val(null).trigger('change') // clear opts

    const userId = userInput.val()
    if (!userId) return

    const url = constructUrl(userId)
    $.getJSON(url, function (assignments) {
      const options = assignments.map(constructOption)
      transferFromInput.append(options).trigger('change')
    })
  }

  function constructUrl (userId) {
    var query = {
      'q[user_id_eq]': userId,
      scope: 'active'
    }
    return `/admin/assignments.json?${$.param(query)}`
  }

  function constructOption (assignment) {
    const text = `${assignment.unit.abbr} - ${assignment.position.name}`
    const id = assignment.id
    return new Option(text, id)
  }
})
