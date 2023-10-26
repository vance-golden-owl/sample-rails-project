# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:birthdate) }

    context 'when user is underage' do
      let(:user) { build(:user, birthdate: 17.years.ago) }

      it 'he/she can not create account' do
        expect(user.valid?).to be true
        expect(user.errors.full_messages).to include('Birthdate indicate user is under 18')
      end
    end
  end
end
