import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

import AssignmentTransferController from './controllers/assignment_transfer_controller'
import FlatpickrController from './controllers/flatpickr_controller'
import ForumRolesController from './controllers/forum_roles_controller'
import JqueryShimController from './controllers/jquery_shim_controller'
import TimeZoneComparisonController from './controllers/time_zone_comparison_controller'
import TimeagoController from './controllers/timeago_controller'
import TooltipController from './controllers/tooltip_controller'

application.register("assignment-transfer", AssignmentTransferController)
application.register("flatpickr", FlatpickrController)
application.register("forum-roles", ForumRolesController)
application.register("jquery-shim", JqueryShimController)
application.register("time-zone-comparison", TimeZoneComparisonController)
application.register("timeago", TimeagoController)
application.register("tooltip", TooltipController)
