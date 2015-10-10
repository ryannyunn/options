class Contract < ActiveRecord::Base
  include AASM

  belongs_to :seller, foreign_key: :seller_id, class_name: 'User'
  has_many :bids

  aasm column: :status do
    state :listed, initial: true
    state :pending
    state :accepted
    state :confirmed
    state :secured

    event :pend do
      transitions from: :listed, to: :pending
    end

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :confirmed do
      transitions from: :accepted, to: :confirmed
    end

    event :secure do
      transitions from: :confirmed, to: :secured
    end
  end
end
