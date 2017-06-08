# frozen_string_literal: true

class Assignment
  class Editor
    attr_reader :assignment, :options

    class Result
      class Error < StandardError; end

      def self.success(assignment)
        new(:success, assignment: assignment)
      end

      def self.failed(error)
        new(:failed, error: error)
      end

      attr_reader :error, :assignment

      def initialize(status, assignment: nil, error: nil)
        @status     = status
        @assignment = assignment
        @error      = error
      end

      def success?
        @status == :success
      end

      def failed?
        @status == :failed
      end
    end

    # Public: Edit an Assignment.
    #
    # assignment - The Assignment that is being edited.
    # options    - The Hash of attributes being edited on the assignment.
    #
    # Returns a Assignment::Editor::Result.
    def self.perform(assignment:, options:)
      new(assignment: assignment, options: options).perform
    end

    def initialize(assignment:, options:)
      @assignment = assignment
      @options    = options
    end

    def perform
      deadline_param = @options.delete(:deadline)
      unless deadline_param == @assignment.deadline&.deadline_at
        recreate_deadline(deadline_param)
      end

      @assignment.update_attributes(@options)
      raise Result::Error, @assignment.errors.full_messages.join("\n") unless @assignment.valid?

      @assignment.previous_changes.each do |attribute, change|
        update_attribute_for_all_assignment_repos(attribute: attribute, change: change)
      end
      Result.success(@assignment)
    rescue Result::Error => err
      Result.failed(err.message)
    end

    private

    def recreate_deadline(deadline)
      @assignment.deadline&.destroy

      new_deadline(deadline) if deadline.present?
    end

    def new_deadline(deadline)
      new_deadline = Deadline::Factory.build_from_string(deadline_at: deadline)
      raise Result::Error, new_deadline.errors.full_messages.join("\n") unless new_deadline.valid?

      @assignment.deadline = new_deadline
    end

    def update_attribute_for_all_assignment_repos(attribute:, change:)
      case attribute
      when 'public_repo'
        Assignment::RepositoryVisibilityJob.perform_later(@assignment, change: change)
      end
    end
  end
end
