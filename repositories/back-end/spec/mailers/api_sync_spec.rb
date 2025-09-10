require 'rails_helper'

ENV['API_ERRORS_EMAIL_TO'] = 'email@email.example'
ENV['DEFAULT_EMAIL_FROM'] = 'no-reply@thepeakbeyond.com'

describe ApiSyncMailer do
  let(:store) { create :treez_store, dispensary_name: 'xxx' }
  let(:text_part) { mail.text_part.body.decoded }
  let(:html_part) { mail.html_part.body.decoded }
  let(:errors) { [{ row: 1, messages: 'error message' }, { row: 2, messages: 'error message 2' }] }

  describe '#sync_error' do
    let(:mail) { ApiSyncMailer.sync_error(store.id, errors: errors) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Store sync error (#{store.name})")
      expect(mail.to).to eq(['email@email.example'])
      expect(mail.from).to eq(['no-reply@thepeakbeyond.com'])
    end

    it 'renders the body' do
      expect(text_part).to match "Error syncing store #{store.name}"

      expect(html_part).to match 'Error syncing store'
      expect(html_part).to match CGI.escapeHTML(store.name)
      expect(html_part).to match 'row: 1, messages: error message'
      expect(html_part).to match 'row: 2, messages: error message 2'
    end
  end
end
