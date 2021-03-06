# Monkeypatch clarat_base Offer
require ClaratBase::Engine.root.join('app', 'models', 'offer')

class Offer < ActiveRecord::Base
  # Frontend-only Methods

  def canonical_section
    section_filters.pluck(:identifier).first
  end

  def in_section? section
    section_filters.where(identifier: section).count > 0
  end

  # Get an array of websites, ordered as follows: (1) own non-pdf (2) own pdf
  # (3+) remaining HOSTS in order, except "other"
  def structured_websites
    # TODO: Refactor!
    sites = [
      websites.own.non_pdf.first,
      websites.own.pdf.first
    ]
    Website::HOSTS[1..-2].each do |host| # no "other"
      sites << websites.send(host).first
    end
    sites.compact
  end

  # structured information to build a gmap marker for this offer
  def gmaps_info
    {
      title: name,
      address: location_address,
      organization_display_name: organization_display_name
    }
  end
end
