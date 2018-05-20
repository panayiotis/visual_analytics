namespace :chunks do

  desc 'Compile visualization chunks described in the task'
  task precompile: :environment do
    print "\033\143" # reset
    @notebook = Notebook.first
    puts "Precompile chunks for notebook: #{@notebook.id} #{@notebook.name}"

    h = {
      type: '',
      fields: {
        nuts: {
          name: 'nuts',
          level: '1',
          levels: %w[
            0
            1
            2
            3
          ],
          drill: [
            nil,
            nil,
            nil,
            nil
          ]
        },
        date: {
          name: 'date',
          level: 'year',
          levels: %w[
            year
            month
          ],
          drill: [
            nil,
            nil
          ]
        },
        reported_by: {
          name: 'reported_by',
          level: nil,
          levels: [],
          drill: []
        },
        crime_type: {
          name: 'crime_type',
          level: '1',
          levels: %w[
            1
            2
          ],
          drill: [
            nil,
            nil
          ]
        }
      },
      view: 'view'
    }

    %w[1 2 3].each do |nuts_level|
      %w[month year].each do |date_level|
        h[:fields][:nuts][:level] = nuts_level
        h[:fields][:date][:level] = date_level
        request(h)
      end
    end
  end

  private

    # TODO: Move this functionality to a model. This method is a copy of
    # the ChunksChannel method.
    # rubocop:disable MethodLength, GuardClause
    def request(schema_hash)
      adapter = LivyAdapter.new
      livy_schema = LivySchema.new(schema_hash)
      sql = livy_schema.to_sql
      chunk = Chunk.find_or_initialize_by(
        code: sql,
        notebook: Notebook.first
      )

      unless chunk.blob
        time_a = Time.now.to_i
        adapter.request(livy_schema) do |action, new_schema, data|
          if action.success?
            time_b = Time.now.to_i
            json = data.to_json
            chunk.blob = { schema: new_schema, data: data }.to_json
            chunk.byte_size = json.size
            chunk.computation_time = time_b - time_a
            chunk.save
            ap chunk
          end
        end
      end
    end
  # rubocop:enable MethodLength, GuardClause
end
