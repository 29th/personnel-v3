# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    audits = Audit.includes(:user, :auditable)
      .order(created_at: :desc)
      .page(params[:page])
      .per(5)

    panel "Recent Activity" do
      paginated_collection(audits, download_links: false) do
        ul do
          audits.map do |audit|
            if authorized?(:show, audit.auditable)
              li do
                text_node link_to audit.user
                text_node " "
                text_node audit.action_past
                text_node " "
                text_node audit.auditable_type
                text_node " "
                text_node auto_link audit.auditable
                text_node " "
                time audit.created_at, :datetime => audit.created_at,
                  "data-controller" => "timeago"
              end
            end
          end
        end
      end
    end
  end
end
