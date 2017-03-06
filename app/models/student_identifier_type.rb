# frozen_string_literal: true
class StudentIdentifierType < ApplicationRecord
  default_scope { where(deleted_at: nil) }

  belongs_to :organization, -> { unscope(where: :deleted_at) }
  has_many :student_identifiers

  enum content_type: [:text, :number, :email]
end
