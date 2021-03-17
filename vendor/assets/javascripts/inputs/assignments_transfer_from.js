$(document).ready(function () {
  const userInput = $('#assignment_member_id')
  const transferFromInput = $('#assignment_transfer_from_unit_id')

  userInput && userInput.on('change', function (evt) {
    transferFromInput.val(null).trigger('change') // clear opts

    const userId = evt.target.value
    if (userId) fetchAssignmentsAndFillSelect(userId, transferFromInput)
  })

  // TODO: Trigger on load of userId has value too
  // TODO: check isNewAssignmentPage or only load this on the right page

  function isNewAssignmentPage () {
    const bodyClasses = document.body.classList
    return bodyClasses.contains('admin_assignments') && bodyClasses.contains('new')
  }

  function fetchAssignmentsAndFillSelect (userId, $select2Input) {
    const url = constructUrl(userId)
    $.getJSON(url, function (assignments) {
      const options = assignments.map(constructOption)
      $select2Input.append(options).trigger('change')
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
