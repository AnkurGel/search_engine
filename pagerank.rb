require_relative 'models.rb'

module SearchEngine
  class PageRank

    def self.process
      d = 0.5 #Damping factor
      iteration = 0
      until iteration.eql?(10) do
        puts "Iteration - #{iteration}"

        Link.all.each do |link|
          puts " -> Processing link #{link.id}"
          inbounds_score = link.inbounds.map do |inbound|
            inbound.rank / inbound.total_outbound_links
          end.inject(:+)
          link.rank = d + (1-d)*inbounds_score
          puts " --> New rank = #{link.rank}"
          link.save
        end

        iteration += 1
      end
    end

  end
end

SearchEngine::PageRank.process
