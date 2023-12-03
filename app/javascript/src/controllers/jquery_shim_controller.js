import { Controller } from 'stimulus'
import { delegate, abnegate } from 'jquery-events-to-dom-events'
import $ from 'jquery'

/**
 * jQuery widgets like select2 and datetimepicker fire
 * jQuery events when they change. Stimulus listens to native
 * DOM events. This shim listens for a jQuery event and fires
 * it as a native DOM event with $ prepended to the event name.
 * 
 * Usage:
 * data-controller="jquery-shim"
 * data-jquery-shim-event-value="select2:select"
 * 
 * Note: the default event is 'change', so if you want to
 * listen to that event, the event-value attribute is optional.
 */
export default class extends Controller {
  static values = {
    event: String
  }

  connect () {
    this.eventValue = this.eventValue || 'change'
    this.delegate = delegate(this.eventValue)
  }
  
  disconnect () {
    abnegate(this.eventValue, this.delegate)
  }
}

