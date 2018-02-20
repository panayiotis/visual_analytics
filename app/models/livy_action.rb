class LivyAction < Action
  attr_accessor :type, :payload, :error, :meta

  def initialize(type: nil, payload: nil, error: nil, meta: nil)
    super
  end

  def last?
    %w[STATEMENT_AVAILABLE STATEMENT_ERROR].include? type
  end

  class << self
    def new_from_response(statement) # rubocop:disable Metrics/MethodLength
      case statement[:state]
      when 'waiting', 'running'
        new(
          type: "STATEMENT_#{statement[:state].upcase}",
          payload: statement[:progress]
        )
      when 'available'
        case statement.dig(:output, :status)
        when 'ok'
          data = JSON.parse(statement.dig(:output, :data, 'text/plain'.to_sym))
          new(
            type: "STATEMENT_#{statement[:state].upcase}",
            # TODO: fix schema
            payload: { schema: '', data: data }
          )
        when 'error'
          new(
            type: 'STATEMENT_ERROR',
            payload: statement[:output],
            error: true
          )
        else
          raise 'LivyAdapter: Available statement: Unknown statement status'
        end
      else
        logger.error statement
        raise 'LivyAdapter: Unknown statement type'
      end
    end
  end
end
