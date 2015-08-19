class ExpiringOffersWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(3) }

  def perform
    expiring = Offer.approved.where('expires_at <= ?', Time.zone.today)
    if expiring.count > 0
      OfferMailer.expiring_mail(expiring.count, expiring.pluck(:id)).deliver
      expiring.update_all unapproved_reason: 'expired'
      expiring.update_all approved: false
    end
  end
end
