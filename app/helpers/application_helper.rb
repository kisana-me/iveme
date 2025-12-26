module ApplicationHelper
  def full_title(str)
    base = "App"
    str.blank? ? base : "#{str} | #{base}"
  end

  def full_url(path)
    URI.join(ENV.fetch("APP_URL"), path).to_s
  end
end
