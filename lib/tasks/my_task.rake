task :stats => "omakase:stats"

namespace :omakase do
  task :stats do

    require 'rails/code_statistics'

    class CodeStatistics
      alias calculate_statistics_orig calculate_statistics
      def calculate_statistics
        @pairs.inject({}) do |stats, pair|
          if 3 == pair.size
            stats[pair.first] = calculate_directory_statistics(pair[1], pair[2]); stats
          else
            stats[pair.first] = calculate_directory_statistics(pair.last); stats
          end
        end
      end
    end

    ::STATS_DIRECTORIES << ["Workers", "app/workers"]
    ::STATS_DIRECTORIES << ["Observers", "app/observers"]
    ::STATS_DIRECTORIES << ["Mailers", "app/mailers"]
    ::STATS_DIRECTORIES << ['Views',  'app/views', /\.(rhtml|erb|rb)$/]
  end
end