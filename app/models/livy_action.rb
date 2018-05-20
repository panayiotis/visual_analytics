class LivyAction < Action
  def initialize(*)
    super
  end

  def last?
    %i[success error].include? payload.dig(:state)
  end

  def success?
    payload.dig(:state) == :success
  end

  class << self
    def new_from_response(statement)
      state = extract_type(statement)
      payload = send("extract_payload_of_#{state}", statement)
      new(
        type: 'ENGINE_COMPUTATION',
        payload: { state: state }.merge(payload),
        error: state == :error
      )
    end

    private

      def extract_type(statement)
        case statement[:state].downcase
        when 'waiting', 'running'
          statement[:state].to_sym
        when 'available'
          case statement.dig(:output, :status)
          when 'ok'
            :success
          when 'error'
            :error
          else
            raise 'LivyAdapter: Available statement: Unknown statement status'
          end
        else
          logger.error statement
          raise 'LivyAdapter: Unknown statement type'
        end
      end

      def extract_payload_of_waiting(statement)
        { progress: statement[:progress] }
      end

      def extract_payload_of_running(statement)
        { progress: statement[:progress] }
      end

      def extract_payload_of_success(statement)
        json = statement.dig(:output, :data, 'text/plain'.to_sym)
        if json
          JSON.parse(json, symbolize_names: true)
        else
          {}
        end
      end

      def extract_payload_of_error(statement)
        statement[:output]
      end
  end
end
