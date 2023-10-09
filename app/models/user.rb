# frozen_string_literal: true

class User < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :birthdate, presence: true
  validate :age_is_over18

  def age_is_over18
    return if birthdate && birthdate < 18.years.ago

    errors.add(:birthdate, 'indicate user is under 18')
  end
end
