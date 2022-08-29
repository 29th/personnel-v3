import StimulusFlatpickr from 'stimulus-flatpickr'
import 'flatpickr/dist/themes/light.css'

export default class extends StimulusFlatpickr {
  /**
   * By default, this plugin conflicts with activeadmin_addons.
   * activeadmin_addons automatically makes all <select> elements into
   * fancy _select2_ elements, unless they have the 'default-select' class.
   * This is a hacky workaround which adds that class to flatpickr elements.
   * See: https://github.com/platanus/activeadmin_addons/blob/master/docs/select2_default.md
   */
  ready (_selectedDates, _dateStr, instance) {
    const container = instance.calendarContainer
    const selects = Array.from(container.querySelectorAll('select'))
    selects.forEach((el) => el.classList.add('default-select'))
  }
}
