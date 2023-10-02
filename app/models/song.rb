require 'csv'

class Song < ApplicationRecord
  include Searchable

  mapping do
    indexes :artist, type: :text
    indexes :title, type: :text
    indexes :lyrics, type: :text
    indexes :genre, type: :keyword
  end
  
  def self.import_csv!
    filepath = Rails.root.join("tcc_ceds_music.csv").to_s
    res = CSV.parse(File.read(filepath), headers: true)
    res.each_with_index do |s, ind|
      Song.create!(
        artist: s["artist_name"],
        title: s["track_name"],
        genre: s["genre"],
        lyrics: s["lyrics"]
      )
    end
  end
  
  def self.search(query)
    params = {
      query: {
        bool: {
          should: [
            { match: { title: query }},
            { match: { artist: { query: query, boost: 5, fuzziness: "AUTO" }}},
            { match: { lyrics: query }},
          ],
        }
      },
      highlight: { fields: { title: {}, artist: {}, lyrics: {} } }
    }
    self.__elasticsearch__.search(params)
  end
end
