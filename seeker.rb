require_relative 'models.rb'
require 'fast-stemmer'
require 'debugger'
require 'ruport'

SEARCH_LIMIT = 19
COMMON_WORDS = File.read('common_words').split("\n")

def search(for_text)
  @search_params = for_text.gsub(/[\d]|[^\w\s]/, '').split.map(&:downcase).reject do |word|
    COMMON_WORDS.include?(word) or word.size > 25
  end.map(&:stem)
  wrds = []
  @search_params.each { |param| wrds << "stem = '#{param}'"}
  word_sql = "select * from words where #{wrds.join(" or ")}"
  @search_words = repository(:default).adapter.select(word_sql)
  puts "#{@search_words}\n\n"
  tables, joins, ids = [], [], []
  @search_words.each_with_index { |w, index|
    #puts "#{w} : #{index}"
    tables << "locations loc#{index}"
    joins << "loc#{index}.link_id = loc#{index+1}.link_id"
    ids << "loc#{index}.word_id = #{w.id}"
  }
  debugger
  joins.pop
  @common_select = "from #{tables.join(", ")} where #{(joins + ids).join(" and ")} group by loc0.link_id"
  rank[0..SEARCH_LIMIT]
end

def rank
  merge_rankings(frequency_ranking, location_ranking, distance_ranking)
end

def frequency_ranking
  freq_sql= "select loc0.link_id, count(loc0.link_id) as count #{@common_select} order by count desc"
  debugger
  list = repository(:default).adapter.select(freq_sql)
  rank = {}
  list.size.times { |i| rank[list[i].link_id] = list[i].count.to_f/list[0].count.to_f }
  return rank
end

def location_ranking
  total = []
  @search_words.each_with_index { |w, index| total << "loc#{index}.position + 1" }
  loc_sql = "select loc0.link_id, (#{total.join(" + ")}) as total #{@common_select} order by total asc"
  list = repository(:default).adapter.select(loc_sql)
  rank = {}
  list.size.times { |i| rank[list[i].link_id] = list[0].total.to_f/list[i].total.to_f }
  return rank
end

def distance_ranking
  return {} if @search_words.size == 1
  dist, total = [], []
  @search_words.each_with_index { |w, index| total << "loc#{index}.position" }
  total.size.times { |index| dist << "abs(#{total[index]} - #{total[index + 1]})" unless index == total.size - 1 }
  dist_sql = "select loc0.link_id, (#{dist.join(" + ")}) as dist #{@common_select} order by dist asc"
  list = repository(:default).adapter.select(dist_sql)
  rank = Hash.new
  list.size.times { |i| rank[list[i].link_id] = list[0].dist.to_f/list[i].dist.to_f }
  return rank
end

def merge_rankings(*rankings)
  r = {}
  rankings.each { |ranking| r.merge!(ranking) { |key, oldval, newval| oldval + newval}}
  r = r.sort_by { |key, value| -value }

  column_names = ["Link", "Rank"]
  rows = r.map do |x,y|
    [Link.get(x), y]
  end
  puts Ruport::Data::Table.new(column_names: column_names,
                               data: rows.map{ |x, y| [x.url, y]}).to_text
  rows
end
search("statsample")
