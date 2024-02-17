// Entry point for the build script in your package.json

import 'bootstrap.native/dist/bootstrap-native-v4'
import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

import NestedForm from 'stimulus-rails-nested-form'

application.register("nested-form", NestedForm)
