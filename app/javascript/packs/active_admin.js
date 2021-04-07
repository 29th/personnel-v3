import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import '@activeadmin/activeadmin'
import 'activeadmin_addons'

import '../stylesheets/active_admin'

const application = Application.start()
const context = require.context('../src/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))
