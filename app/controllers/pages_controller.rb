class PagesController < ApplicationController
  def index
    @document = Document.unscoped.find_by(name_id: "index", status: :specific)
  end

  def terms_of_service
    @document = Document.unscoped.find_by(name_id: "terms_of_service", status: :specific)
  end

  def privacy_policy
    @document = Document.unscoped.find_by(name_id: "privacy_policy", status: :specific)
  end

  def contact
    @document = Document.unscoped.find_by(name_id: "contact", status: :specific)
  end

  def sitemap
    @document = Document.unscoped.find_by(name_id: "sitemap", status: :specific)
  end
end
