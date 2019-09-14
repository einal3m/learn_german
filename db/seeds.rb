require 'csv'

CSV.read("db/words.csv", headers: true, header_converters: :symbol).each do |word|
  found_word = Word.find_by(german: word[:german])

  if found_word # update
    attrs = {
      article: word[:article], 
      plural: word[:plural], 
      category: word[:category],
      chapter: word[:chapter]
    }
    found_word.update(attrs)
    found_word.save
  else # create
    Word.create(
      german: word[:german], 
      article: word[:article], 
      plural: word[:plural], 
      category: word[:category],
      chapter: word[:chapter]
    )
  end
end
