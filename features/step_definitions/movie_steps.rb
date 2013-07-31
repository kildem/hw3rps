# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    if !Movie.find_by_title_and_rating(movie[:title], movie[:rating]) then
      Movie.create!(movie)
    end
  end
  assert (Movie.count >= movies_table.hashes.count), "Error inizializing DB" 
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body.index(e1) < page.body.index(e2) , "Wrong order"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(",").each do | rating |
    rating = "ratings_" + rating
    uncheck ? uncheck(rating) : check(rating)
  end
end

Then /^I should (not )?see movies rated: (.*)/ do |negation, rating_list|
  ratings = rating_list.split(",")
  exist = [] 
  find("#movies").all('tr').map { |row| row.all('td[2]').map{ |cell| exist << cell.text}}
  require 'set'
  if negation
    ratings.to_set.intersection(exist.to_set).should be_empty
  else
    ratings.to_set.should == exist.to_set
  end

end

Then /I should see (none|all) of the movies/ do |filter|
  db_size = 0
  db_size = Movie.all.size if filter == "all"
  page.find(:xpath, "//table[@id=\"movies\"]/tbody[count(tr) = #{db_size} ]")
end

