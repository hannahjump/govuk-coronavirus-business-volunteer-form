# frozen_string_literal: true

class CoronavirusForm::OfferOtherSupportController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    support_other = sanitize(params[:support_other]).presence

    session[:offer_other_support] = support_other

    invalid_fields = validate_radio_field(
      PAGE,
      other: support_other,
    )

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    elsif session["check_answers_seen"]
      redirect_to controller: "coronavirus_form/check_answers", action: "show"
    elsif session[:medical_equipment] == I18n.t("coronavirus_form.medical_equipment.options.option_yes.label")
      redirect_to controller: "coronavirus_form/#{NEXT_PAGE}", action: "show"
    else
      redirect_to controller: "coronavirus_form/#{PAGE}", action: "show"
    end
  end

private

  PAGE = "offer_other_support"
  NEXT_PAGE = "your_business_details"

  def previous_path
    "/"
  end
end
