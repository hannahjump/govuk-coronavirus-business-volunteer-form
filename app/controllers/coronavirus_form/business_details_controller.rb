# frozen_string_literal: true

class CoronavirusForm::BusinessDetailsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include FieldValidationHelper

  REQUIRED_FIELDS = %w(company_name).freeze

  def show
    render "coronavirus_form/#{PAGE}"
  end

  def submit
    @business_details = sanitized_business_details(params)
    session[:business_details] = @business_details

    invalid_fields = validate_fields(@business_details)

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      render "coronavirus_form/#{PAGE}"
    else
      redirect_to controller: session["check_answers_seen"] ? "coronavirus_form/check_answers" : "coronavirus_form/#{NEXT_PAGE}", action: "show"
    end
  end

private

  NEXT_PAGE = "contact_details"
  PAGE = "business_details"

  def validate_fields(business_details)
    missing_fields = validate_missing_fields(business_details)
    company_size_validation = validate_radio_field("#{PAGE}.company_size", radio: business_details[:company_size])
    company_location_validation = validate_radio_field("#{PAGE}.company_location", radio: business_details[:company_location])
    missing_fields + company_size_validation + company_location_validation
  end

  def validate_missing_fields(business_details)
    REQUIRED_FIELDS.each_with_object([]) do |field, invalid_fields|
      next if business_details[field].present?

      invalid_fields << {
        field: field.to_s,
        text: t("coronavirus_form.#{PAGE}.#{field}.custom_error",
                default: t("coronavirus_form.errors.missing_mandatory_text_field",
                           field: t("coronavirus_form.#{PAGE}.#{field}.label")).humanize),
      }
    end
  end

  def sanitized_business_details(params)
    {
      "company_name" => sanitize(params[:company_name]).presence,
      "company_number" => sanitize(params[:company_number]).presence,
      "company_size" => sanitize(params[:company_size]).presence,
      "company_location" => sanitize(params[:company_location]).presence,
    }
  end

  def previous_path
    coronavirus_form_are_you_a_manufacturer_path
  end
end
