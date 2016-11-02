class Flashcards < Sinatra::Base

  configure do
    $base_url = ENV['BASE_URL'] || 'http://localhost:3001'

    $flashcards = {}
    Dir[File.dirname(__FILE__) + '/flashcards/*.yml'].each do |file|
      f = YAML.load_file(file)
      title = f["title"].gsub(" ", "_").downcase.to_sym
      $flashcards[title] = f
    end
  end

  before do
    # Switch on Caching
    cache_control :public, :must_revalidate, max_age: 60 if ENV['RACK_ENV'] == 'production'
  end

  # --------------------- Simple Redirects ------------------- #

  get '/' do
    erb :index
  end

  get '/cards.json' do
    content_type :json
    status 200
    $flashcards.each do |k,v|
      v["questions"].each do |question|
        unless question["answer"].respond_to? :each
          if question["answer"].match(/image\[(.+)\]/)
            question["answer"] = question["answer"].gsub(/image\[/, "http://foo.com/images/")[0..-2]
          end
        end
      end
    end
    $flashcards.to_json
  end

  get '/cards/:flashcard' do
    @flashcard = $flashcards[params[:flashcard].to_sym]
    erb :flashcard
  end
end
