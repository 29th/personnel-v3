import { Controller } from 'stimulus'
import { formatInTimeZone, toDate } from 'date-fns-tz'
const railsTimezone = require('rails-timezone')

export default class extends Controller {
  static targets = [
    'comparisons',
    'timeZone',
    'startsAt',
    'bulkDates',
    'time'
  ]
  
  static values = {
    timeZones: Array
  }
  
  connect () {
    this.update()
  }
  
  update () {
    const dateTimeString = this._getDateTimeString()
    const timeZone = railsTimezone.from(this.timeZoneTarget.value)

    if (dateTimeString && timeZone) {
      const parsedDate = toDate(dateTimeString, { timeZone })
      this.comparisonsTarget.innerHTML = this._renderComparisons(parsedDate)
    } else {
      this.comparisonsTarget.innerText = ''
    }
  }
  
  _getDateTimeString () {
    if (this._hasSplitFields()) {
      return this._getSplitFieldsValue()
    } else {
      return this.startsAtTarget.value
    }
  }
  
  _hasSplitFields () {
    return this.hasBulkDatesTarget && this.hasTimeTarget
  }

  _getSplitFieldsValue () {
    const dates = this.bulkDatesTarget.value.split(', ')
    const sampleDate = dates[0]
    const time = this.timeTarget.value

    return sampleDate && time ? `${sampleDate}T${time}` : ''
  }
  
  _renderComparisons (date) {
    const timeZones = this._getTimeZones()
    const formatStr = 'HH:mm zzzz'
    return timeZones
      .map((timeZone) => formatInTimeZone(date, timeZone, formatStr))
      .join('<br>')
  }

  _getTimeZones () {
    return Array.from(this.timeZoneTarget.options)
      .map((opt) => railsTimezone.from(opt.value))
      .filter((tz) => tz) // remove empty items
  }
}
