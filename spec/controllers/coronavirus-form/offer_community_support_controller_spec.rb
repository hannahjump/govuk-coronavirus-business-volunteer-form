# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::OfferCommunitySupportController, type: :controller do
  let(:current_template) { "coronavirus_form/offer_community_support" }
  let(:session_key) { :offer_community_support }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:selected) { permitted_values.sample }
    let(:permitted_values) do
      I18n.t("coronavirus_form.offer_community_support.options").map { |_, item| item[:label] }
    end

    it "sets session variables" do
      post :submit, params: { offer_community_support: selected }
      expect(session[session_key]).to eq selected
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { offer_community_support: selected }

      expect(response).to redirect_to(coronavirus_form_check_your_answers_path)
    end

    it "validates any option is chosen" do
      post :submit, params: { offer_community_support: "" }

      expect(response).to render_template(current_template)
    end

    it "validates a valid option is chosen" do
      post :submit, params: { offer_community_support: "<script></script>" }

      expect(response).to render_template(current_template)
    end
  end
end
