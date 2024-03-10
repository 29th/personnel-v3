# Most of these routes are carried over from when we were on Dreamhost.
# It's likely that the majority of them receive very little traffic today and
# could be disabled. See: https://github.com/orgs/29th/projects/2/views/1
class ReverseProxyController < ApplicationController
  include ReverseProxy::Controller

  before_action :force_trailing_slash

  SITES = {
    uploads: "https://uploads.29th.org",
    dreamhost: "https://29th.dreamhosters.com",
    github: "https://29th.github.io"
  }

  def a3
    mask :dreamhost, "/a3"
  end

  def awards
    mask :uploads, "/legacy-dreamhost/awards"
  end

  def bans
    # TODO: Update to use new discourse topic
    redirect_to "https://forums.29th.org/discussion/25818/how-to-dispute-your-ban",
      allow_other_host: true
  end

  def coats
    mask :uploads, "/legacy-dreamhost/coats"
  end

  def darkest_hour_infobank
    mask :github, "/darkest-hour-infobank"
  end

  def dh
    path = CGI.escape(params[:title]) if params[:title].present?
    redirect_to "/darkest-hour-infobank/#{path}",
      status: :moved_permanently
  end

  def forums
    # TODO: Should this instead redirect to smf.29th.org ?
    mask :dreamhost, "/forums"
  end

  def forum_post_images
    mask :uploads, "/legacy-dreamhost/ForumPostImages"
  end

  def handbook
    redirect_to "/wiki/FM_21-20_%22Cadet%27s_Handbook%22"
  end

  def images
    mask :uploads, "/legacy-dreamhost/images"
  end

  def medical
    mask :dreamhost, "/medical"
  end

  def roid
    mask :dreamhost, "/roid"
  end

  def rs
    mask :dreamhost, "/rs"
  end

  def signal_corps
    mask :uploads, "/legacy-dreamhost/signalcorps"
  end

  def sigs
    mask :uploads, "/legacy-dreamhost/sigs"
  end

  def stamps
    mask :uploads, "/legacy-dreamhost/stamps"
  end

  def wiki
    if params[:path] == "index.php"
      path = CGI.escape(params[:title]) if params[:title].present?
      redirect_to "/wiki/#{path}"
    else
      mask :github, "/wiki"
    end
  end

  private

  def mask(site_key, base_path)
    site = URI(SITES[site_key])
    path = File.join(base_path, params[:path] || "")
    logger.debug path

    reverse_proxy site,
      path: path,
      reset_accept_encoding: true,
      headers: {"Host" => site.host} do |config|
      config.on_response do |code, response|
        # prevent STS header being forwarded and having the browser apply it
        # for 29th.org
        response.delete("strict-transport-security")
      end
    end
  end

  def force_trailing_slash
    return if file?
    return if trailing_slash?

    url = url_for \
      request.path_parameters
        .merge(request.query_parameters)
        .merge(trailing_slash: true)

    redirect_to url, status: :moved_permanently
  end

  def trailing_slash?
    URI(request.original_url).path.ends_with? "/"
  end

  def file?
    URI(request.original_url).path.split("/")[-1]&.include? "."
  end
end
