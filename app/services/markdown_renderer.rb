class MarkdownRenderer
  def self.render(md, safe: true)
    md = md.to_s
    digest = Digest::SHA256.hexdigest(md)
    cache_key = [
      "markdown_renderer",
      "v1",
      safe ? "safe1" : "safe0",
      digest
    ].join(":")

    html = Rails.cache.fetch(cache_key) do
      options = {
        hard_wrap: true,
        with_toc_data: true,
        filter_html: safe
      }
      extensions = {
        tables: true,
        fenced_code_blocks: true,
        disable_indented_code_blocks: true,
        autolink: true,
        strikethrough: true,
        lax_spacing: true,
        space_after_headers: true,
        superscript: true,
        underline: true,
        highlight: true,
        quote: true,
        footnotes: true
      }
      renderer = Redcarpet::Render::HTML.new(options)
      markdown = Redcarpet::Markdown.new(renderer, extensions)
      markdown.render(md)
    end

    html.to_s.html_safe
  end

  def self.render_toc(md)
    renderer = Redcarpet::Render::HTML_TOC.new(nesting_level: 6)
    markdown = Redcarpet::Markdown.new(renderer, space_after_headers: true)
    markdown.render(md || "").html_safe
  end

  def self.render_plain(md)
    html = render(md)
    ApplicationController.helpers.strip_tags(html)
  end
end
