module ApplicationHelper
  def full_title(str)
    (str.blank? ? "" : str + " | ") + "App"
  end

  def full_url(path)
    URI.join(ENV.fetch("APP_URL"), path).to_s
  end

  def md_render(md, safe: false)
    ::MarkdownRenderer.render(md, safe: safe)
  end

  def md_render_toc(md)
    ::MarkdownRenderer.render_toc(md)
  end

  def md_render_plain(md)
    ::MarkdownRenderer.render_plain(md)
  end
end
