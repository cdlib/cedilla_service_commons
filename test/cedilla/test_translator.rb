require_relative '../test_helper'

class TestTranslator < Test::Unit::TestCase

  def setup
    @translator = Cedilla::Translator.new

    @empty_citation = Cedilla::Citation.new
    @citation = Cedilla::Citation.new({:genre => 'book', :content_type => 'electronic', :title => 'The Metamorphosis', :date => '2014', 
                                       :authors => [Cedilla::Author.new({:last_name => 'Kafka', :first_name => 'Franz'})], 
                                       :abstract => 'This is " some < html> code.', :blah => 'yadda', :yadda => 'blah'})
    
    @json = '{"time":"2014-04-21T22:33:02.947Z","service":"service_test","citation":{"genre":"journal","title":"A Tale Of Two Cities","content_type":"full_text","authors":[{"last_name":"Dickens"}]}}'
  end
  
# -------------------------------------------------------------------------------------------------------  
  def test_from_cedilla_json
    citation = @translator.from_cedilla_json(@json)
    
    assert_equal 'journal', citation.genre, "Was expecting the citation has genre to be 'journal'!"
    assert_equal 'A Tale Of Two Cities', citation.title, "Was expecting the citation has title to be 'A Tale Of Two Cities'!"
    assert_equal 'full_text', citation.content_type, "Was expecting the citation has content_type to be 'full_text'!"
    
    authors = citation.authors
    assert !authors.empty?, "Was expecting some authors!"
    assert_equal 'Dickens', citation.authors.first.last_name, "Was expecting the author's last name to be 'Dickens'!"
  end
  
# -------------------------------------------------------------------------------------------------------  
  def test_to_cedilla_json
    service_name = 'service_test'
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    json = @translator.to_cedilla_json(service_name, citation)
    #json = {"time":"2014-04-24 10:47:02 -0700","service":"service_test","citation":{"genre":"journal","content_type":"electronic"}}.
    assert json.include?('"genre":"journal"'), "Was expecting a query string with generic attribute names from the translator!"
    assert json.include?('"content_type":"electronic"'), "Was expecting a query string with generic attribute names from the translator!"
    
    citation = Cedilla::Citation.new({:genre => 'journal', :title => 'A Tale Of Two Cities', :content_type => 'full_text', :authors => [{:last_name => 'Dickens'}]})
    assert !citation.authors.empty?, "Was expecting some authors!"
    assert_equal 'Dickens', citation.authors.first.last_name, "Was expecting author's last name to be 'Dickens'!"
    
    json = @translator.to_cedilla_json(service_name, citation)
    #json: {"time":"2014-04-24 13:35:32 -0700","service":"service_test","citation":{"genre":"journal","content_type":"full_text","title":"A Tale Of Two Cities","authors":[{"full_name":"Dickens","last_name":"Dickens"}]}}
    assert json.include?('"title":"A Tale Of Two Cities"'), "Was expecting a query string with generic attribute names from the translator!"
    assert json.include?('"authors":[{"full_name":"Dickens","last_name":"Dickens"}]'), "Was expecting a query string with generic attribute names from the translator!"

  end
  
# -------------------------------------------------------------------------------------------------------  
  def test_hash_to_query_string
    citation = Cedilla::Citation.new({:genre => 'journal', :content_type => 'electronic'})
    hash = citation.to_hash
    query_string = @translator.hash_to_query_string(hash)
    
    assert query_string.include?('genre=journal'), "Was expecting a query string with genre attribute to be 'journal'!"
    assert query_string.include?('content_type=electronic'), "Was expecting a query string with content_type attribute to be 'electronic'!"
    
    citation = Cedilla::Citation.new({:genre => 'journal', :title => 'A Tale Of Two Cities', :content_type => 'full_text', :authors => [{:last_name => 'Dickens'}]})
    query_string = @translator.hash_to_query_string(citation.to_hash)
    #query_string: genre=journal&content_type=full_text&title=A%20Tale%20Of%20Two%20Cities&full_name=Dickens&last_name=Dickens
    
    assert query_string.include?('genre=journal'), "Was expecting a query string with genre attribute to be 'journal'!"
    assert query_string.include?('title=A%20Tale%20Of%20Two%20Cities'), "Was expecting a query string with title attribute to be 'A%20Tale%20Of%20Two%20Cities'!"
    
    citation = Cedilla::Citation.new({:genre => 'book', :content_type => 'electronic', :title => 'The Metamorphosis', :date => '2014', 
                                      :authors => [{:last_name => 'Dickens', :first_initial => 'B.'}, {:last_name => 'Kafka', :first_name => 'Franz'}],
                                      :resources => [{:source => 'source 1', :location => 'location 1'}, {:source => 'source 2', :target => 'http://www.ucop.edu/link/to/item', :availability => true}]})
    hash = citation.to_hash
    #hash: {"genre"=>"book", "content_type"=>"electronic", "title"=>"The Metamorphosis", "date"=>"2014", 
    #       "authors"=>[{"full_name"=>"B. Dickens", "last_name"=>"Dickens", "first_initial"=>"B.", "initials"=>"B."}, {"full_name"=>"Franz Kafka", "last_name"=>"Kafka", "first_name"=>"Franz", "first_initial"=>"F.", "initials"=>"F."}], 
    #       "resources"=>[{"source"=>"source 1", "location"=>"location 1", "availability"=>false},{"source"=>"source 2", "target"=>"http://www.ucop.edu/link/to/item", "availability"=>true}]}
    
    query_string = @translator.hash_to_query_string(hash)

    #query_string: genre=book&content_type=electronic&title=The%20Metamorphosis&date=2014
    #              &full_name=B.%20Dickens&last_name=Dickens&first_initial=B.&initials=B.&full_name=Franz%20Kafka&last_name=Kafka&first_name=Franz&first_initial=F.&initials=F.
    #              &source=source%201&location=location%201&availability=false&source=source%202&target=http://www.ucop.edu/link/to/item&availability=true
    assert query_string.include?('title=The%20Metamorphosis'), "Was expecting a query string with title attribute to be 'The%20Metamorphosis'!"
    assert query_string.include?('full_name=Franz%20Kafka'), "Was expecting a query string with full_name attribute to be 'Franz%20Kafka'!"
    assert query_string.include?('first_initial=F.'), "Was expecting a query string with first_initial attribute to be 'F.'!"
    assert query_string.include?('target=http://www.ucop.edu/link/to/ite'), "Was expecting a query string with target attribute to be 'http://www.ucop.edu/link/to/ite'!"
  end
end