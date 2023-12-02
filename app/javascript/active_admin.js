import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import 'activeadmin_addons'

const application = Application.start()
const context = require.context('./src/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))
