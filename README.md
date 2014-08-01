# Ruby Gem For Creating Cedilla Services

## Overview

[![Build Status](https://secure.travis-ci.org/cdlib/cedilla_service_commons.png?branch=master)](http://travis-ci.org/cdlib/cedilla_service_commons)

This is a ruby gem that can be used to help you build out services for your implementation of services used within the larger Cedilla ecosystem: https://github.com/cdlib/cedilla.  

The gem provides you with a uniform way of parsing JSON messages from cedilla and serializing JSON messages back to cedilla. It also provides you with a standardized data model (Request, Citation, Author, and Resource) and a service which makes a call to your HTTP endpoint. 

The gem allows you to quickly create a cedilla service without having to worry about parsing JSON requests from Cedilla, serializing JSON messages sent back to cedilla, or dealing with HTTP calls, redirects, and error handling. You can spend your time focused on dealing with what's important, managing the format of the querystring or form data being passed to the endpoint and handling responses from the endpoint.

For a concrete example of this Gem being used to ease the work needed to build your cedilla services, look at the cedilla_services project: https://github.com/cdlib/cedilla_services. That project uses this Ruby gem as a base for services used to communicate with SFX, Internet Archive, CoverThing, Worldcat Discovery, etc.

#### Dependencies

* Ruby 2.1.x
* Minitest and Webmock gems if you're going to run the tests (just run ```bundle install``` to pull them down)

## Installation 
#### If you use Git and want Git to help you manage this gem's codebase
```
> cd [project root]
> git submodule add https://github.com/cdlib/cedilla_service_commons.git vendor/cedilla_service_commons
> cd vendor/cedilla_service_commons
> gem build cedilla.gemspec
> gem install cedilla-[version].gem
``` 

#### If you don't use Git or don't want the gem as part of your project
```
> git clone https://github.com/cdlib/cedilla_service_commons.git
> cd cedilla_service_commons
> gem build cedilla.gemspec
> gem install cedilla-[version].gem
```

#### If you're just looking to hack on the codebase:
Just clone the code per normal and have fun. If you're making generic changes that you think might be useful to the larger community, please send us a Pull Request and share your innovations with the rest of the community!


## Usage
For this example we use the lightweight [http://www.sinatrarb.com/intro.html](Sinatra) framework to create a web server that we will use to expose our service implementation. This will require the installation of the sinatra gem.

The example consists of 3 files, the root project file that acts as your Sinatra Application or the web app's controller. It receives the incoming web request and sends it along to your service implementation for processing. The service requires a configuration YAML file, and we include it here so that you can see how it is incorporated. This example however overrides any interaction with the configuration settings since we are not actually calling an external endpoint. 

To get started, use the install instructions above to downaload and install the Cedilla Gem, install the Sinatra gem, and then create a new directory to store your project. Once the gems are installed, create the following three files:

#### The service: my_service.rb
```ruby
require 'cedilla/service'
require 'cedilla/citation'

# -------------------------------------------------------------------------
# An Implementation of the CedillaService Gem
# -------------------------------------------------------------------------
class MyService < Cedilla::Service
  
  # --------------------------------------------------------------------------------
  # The service.process_request calls this function when it is finished. You 
  # MUST implement your own code here. The gem expects you to return either
  # a Cedilla:Citation or a Cedilla:Error from this method
  # --------------------------------------------------------------------------------
  def process_response
    # Just dumping the HTTP response information capture in process_request
    puts "HTTP Status from endpoint: #{@response_status}"
    puts "HTTP Headers from enpoint: #{@response_headers.inspect}"
    puts "HTTP Body from endpoint: "
    puts @response_body
    
    Cedilla::Citation.new({:publisher => 'Well known publishing house',
                           :publication_place => 'London',
                           :authors => [{:last_name => 'Dickens', :first_name => 'Charles'}]})
  end
  
  # --------------------------------------------------------------------------------
  # A common method that usually needs to be overriden to properly format the
  # url of the target system 
  # --------------------------------------------------------------------------------
  def add_citation_to_target(citation)
    # Just dumping the value to the console so you can see what it does
    target = super(citation)
    puts "URL that will be used to contact the endpoint: #{target}"
    
    target
  end
  
  # --------------------------------------------------------------------------------
  # This method is rarely ever overriden. We do so here simply to prevent the service
  # from actually calling out to the endpoint. Once you have a legitimate endpoint
  # defined in the configuration file, remove this method
  # --------------------------------------------------------------------------------
  def process_request(request, headers)
    @response_status = 200
    @response_headers = {}
    @response_body = "This is sample data sent back from our fake endpoint."
    
    self.process_response
  end
end
```

#### The configuration file: my_service.yml
```yaml
enabled: true
max_attempts: 1

target: 'http://localhost:4567/advancedsearch.php?'

minimum_api_version: 1.1

query_string: 'keep_apostrophes=true&fl[]=*&fmt=json&xmlsearch=Search&rows=999'

http_method: 'get'
http_timeout: 5
http_error_on_non_200: true
http_max_redirects: 5
```

#### The controller: my_project.rb
```ruby
require 'sinatra'
require 'yaml'

require 'cedilla'

require_relative './my_service.rb'

post '/my_service' do
  config = YAML.load_file('./my_service.yml')

  # Create an instance of the Gem's controller
  cedilla  = CedillaController.new
  
  begin
    # Call the controller's only method and send it the HTTPRequest, HTTPResponse, and an instance of your Service implementation
    resp = cedilla.handle_request(request, response, MyService.new(config))

    # Set the outgoing status and body so that it is sent back to the caller
    status resp.status
    resp.body
    
  rescue Exception => e
    status 500
    # Use the gem's Translator and Error objects to send back an error that Cedilla can work with!
    Cedilla::Translator.to_cedilla_json(params["id"], Cedilla::Error.new(Cedilla::Error::LEVELS[:fatal], 
                                "Was unable to process the request! #{e.message}"))
  end
end
```

Once the files have been created yoou can start the Sinatra web server by typing ```> ruby my_project.rb ```.

Then in a separate tab you can test the service by using the curl command and send the controller some test JSON.
```json
> curl --data '{"time":"2014-06-30T23:11:11.700Z","id":"e9d6576astor_ip":"127.0.0.1","citation":{"authors":[{"last_name":"Dickens"}],"title":"A Tale of Two Cities","genre":"book"}}' http://localhost:4567/my_service
```

You should receive a JSON response from the controller that is a representation of a citation update from our test endpoint. Here is what the response should look like:
```json
{"time":"2014-08-01 09:42:32 -0700",
 "id":"e9d6576a-99a8-4ffb-95ae-7bb363c482f0",
 "citations":[{"publisher":"Well known publishing house",
               "publication_place":"London",
               "authors":[{"full_name":"Charles Dickens",
                           "last_name":"Dickens",
                           "first_name":"Charles",
                           "first_initial":"C.",
                           "initials":"C."}]}
              ]
 }
```

For more information on the JSON messages that a cedilla service should expect, please check out the Cedilla Wiki: https://github.com/cdlib/cedilla/wiki/JSON-Data-Model:-Between-Aggregator-and-Services

## Notes on working with the Gem:

The Gem contains a Cedilla::Translator class that can help you convert incoming JSON messages from Cedilla into concrete ruby objects and can in turn translate those ruby objects into JSON messages that Cedilla is expecting you to return.

The Cedilla::Citation, Cedilla::Author, and Cedilla::Resource objects contain equality methods that can help you quickly detect duplicate or similar information coming back from an endpoint.

The Cedilla::Author object contains a Cedilla::Author.from_abritrary_string(value) method that returns a Cedilla::Author object. This static method contains various regular expressions that will parse out various author names into their appropriate fields (e.g. 'Doe, John A.', 'John A. Doe', 'J A Doe', 'J. Doe 1934 - 1996', etc.)

Cedilla expects your service implementation to return errors as JSON messages. Use the Cedilla::Error object to create appropriate errors and pass them through the Cedilla::Translator to generate the JSON.
 
You must ALWAYS override the Cedilla::Service.process_response method. This method is where you should interact with the @response_status, @response_headers, and @rsponse_body instance variables to transform the results from your endpoint into Cedilla::Citation object (or an array of Cedilla::Citation objects). 
 

## Notes on including this project as a Git submodule in your own project
* When this code base is updated you will need to do a: ```> git submodule update``` and then install the new version of the gem.
* If you clone your project onto a machine you will need to do the following after the initial clone:
```
> git submodule init
> git submodule update
> cd vendor/cedilla_service_commons
> gem build cedilla.gemspec
> gem install cedilla-[version].gem
```


## Notes on using Bundler in your project
If you use Bundler in a project that implements this Ruby gem, you may potentially need to do the following whenever this gem is updated:
```
> cd [project root]
> rm *.lock
> bundle install
```

## License

The Cedilla Ruby Gem uses adheres to the [BSD 3 Clause](./LICENSE.md) license agreement.


