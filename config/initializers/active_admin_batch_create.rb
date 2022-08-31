require "active_admin/batch_create"

::ActiveAdmin::DSL.send(:include, ActiveAdmin::BatchCreate::DSL)
