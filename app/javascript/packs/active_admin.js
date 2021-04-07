import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import '@activeadmin/activeadmin'
import 'activeadmin_addons'
import '../stylesheets/active_admin'
import '../src/assignments_transfer_from'

const application = Application.start()
const context = require.context('../src/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))
