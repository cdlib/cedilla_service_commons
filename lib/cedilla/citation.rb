module Cedilla
  
  class Citation
    
    attr_accessor :genre, :content_type
    
    attr_accessor :resources, :authors
    
    # These items are updated by the services and sent back to the aggregator
    attr_accessor :subject, :cover_image, :abstract, :text_language
    
    # Identifiers
    attr_accessor :issn, :eissn, :isbn_10, :eisbn_10, :isbn_13, :eisbn_13, :oclc, :lccn, :doi
    attr_accessor :pmid, :coden, :sici, :bici, :dissertation_id
    
    # Titles
    attr_accessor :title, :article_title, :journal_title, :chapter_title, :book_title, :series_title
    
    # Publisher attributes
    attr_accessor :publisher, :publication_date, :publication_place
    
    # Detailed search attributes
    attr_accessor :date, :year, :month, :day, :season, :quarter 
    attr_accessor :volume, :issue, :article_number, :enumeration, :part, :edition, :institute, :series
    attr_accessor :start_page, :end_page, :pages, :charset
    
    # The others attribute is meant to store undefined citation parameters that came in from the client
    attr_accessor :short_titles, :others

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})  
      
      @resources = {} if params[:resources].nil?
      @authors = {}
      
      @others = {}
      @short_titles = {}
      
      auth_params = {}
      
      # Assign the appropriate params to their attributes, place everything else in others
      params.each do |key,val|
        key = key.id2name if key.is_a?(Symbol)
        
        if self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
          
        elsif key == 'short_titles' 
          @short_titles << val
          
        elsif key == 'others'
          @others << val
          
        elsif key == 'authors' and (val.is_a?(Hash))
          val.each{ |auth| @authors << auth unless self.has_author(auth) or !auth.is_a?(Cedilla::Author)}
          
        elsif key.index('author_') == 0
          auth_params["#{key.gsub('author_', '')}"] = val
          
        else
          @others << "#{key}=#{val}"
        end
      end
      
      @authors << Cedilla::Author.new(auth_params) unless auth_params.empty?

    end

# --------------------------------------------------------------------------------------------------------------------    
# Adds the data elements from the specified citation onto the current citation
# --------------------------------------------------------------------------------------------------------------------        
    def combine(citation, force=false)
      if citation.is_a?(Cedilla::Citation)
        
        citation.methods.each do |method|
          name = method.id2name.gsub('=', '')
          val = citation.method(name).call if (method.id2name[-1] == '=' and citation.respond_to?(name))
          
          unless val.nil?
            case name
            when 'others'
              val.each{ |item| @others << item if !@others.include?(item) }
              
            when 'resources'
              val.each{ |item| @resources << item if !self.has_resource?(item) }
              
            when 'authors'
              val.each{ |item| @authors << item if !self.has_author?(item) }
              
            when 'short_titles'
              val.each{ |item| @short_titles << item if !@short_titles.include?(item) or force }
              
            else
              unless ['!', 'error'].include?(name)
                self.method("#{name}=").call(val) if self.method("#{name}").call.nil? or force
              end
            end

          end
          
        end
        
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: identifiers and titles
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      return false unless object.is_a?(self.class)
      
      @genre == object.genre and @content_type == object.content_type and self.identifiers == object.identifiers
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation is valid
# --------------------------------------------------------------------------------------------------------------------
    def valid?
      # A Citation MUST have a genre and a content type
      !@genre.nil? and @genre != '' and !@content_type.nil? and @content_type != '' and @errors.empty?
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation has an identifier
# --------------------------------------------------------------------------------------------------------------------    
    def has_identifier?
      (!@issn.nil? and @issn != '') or (!@eissn.nil? and @eissn != '') or 
            (!@isbn_10.nil? and @isbn_10 != '') or (!@eisbn_10.nil? and @eisbn_10 != '') or 
            (!@isbn_13.nil? and @isbn_13 != '') or (!@eisbn_13.nil? and @eisbn_13 != '') or 
            (!@oclc.nil? and @oclc != '') or (!@lccn.nil? and @lccn != '') or (!@doi.nil? and @doi != '') or 
            (!@pmid.nil? and @pmid != '') or (!@coden.nil? and @coden != '') or (!@sici.nil? and @sici != '') or
            (!@bici.nil? and !@bici != '') or (!@dissertation_id.nil? and @dissertation_id != '')
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether the resource exists.
# --------------------------------------------------------------------------------------------------------------------
    def has_resource?(resource)
      ret = false
      @resources.each{ |rsc| ret = true if rsc == resource }
      ret
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether the author exists.
# --------------------------------------------------------------------------------------------------------------------
    def has_author?(author)
      ret = false
      @authors.each{ |auth| ret = true if auth == author }
      ret
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether the resource or author exists.
# --------------------------------------------------------------------------------------------------------------------
    def include?(item)
      ret = false
      @resources.each{ |rsc| ret = true if rsc == item }
      @authors.each{ |auth| ret = true if auth == item } unless ret 
      ret
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Return all of the identifiers for the citation
# --------------------------------------------------------------------------------------------------------------------
    def identifiers
      ret = {}
      ret['issn'] = @issn unless @issn.nil? or @issn == ''
      ret['eissn'] = @eissn unless @eissn.nil? or @eissn == ''
      ret['isbn_10'] = @isbn_10 unless @isbn_10.nil? or @isbn_10 == ''
      ret['eisbn_10'] = @eisbn_10 unless @eisbn_10.nil? or @eisbn_10 == ''
      ret['isbn_13'] = @isbn_13 unless @isbn_13.nil? or @isbn_13 == ''
      ret['eisbn_13'] = @eisbn_13 unless @eisbn_13.nil? or @eisbn_13 == ''
      ret['oclc'] = @oclc unless @oclc.nil? or @oclc == ''
      ret['lccn'] = @lccn unless @lccn.nil? or @lccn == ''
      ret['doi'] = @doi unless @doi.nil? or @doi == ''
      ret['pmid'] = @pmid unless @pmid.nil? or @pmid == ''
      ret['coden'] = @coden unless @coden.nil? or @coden == ''
      ret['sici'] = @sici unless @sici.nil? or @sici == ''
      ret['bici'] = @bici unless @bici.nil? or @bici == ''
      ret['dissertation_id'] = @dissertation_id unless @dissertation_id.nil? or @dissertation_id == ''
           
      ret
    end

# --------------------------------------------------------------------------------------------------------------------    
# The following 4 methods determine whether or not we're working with ISBN 10 or 13 and set the appropriate value. 
#      ISBN 10 is default
# --------------------------------------------------------------------------------------------------------------------    
    def isbn=(val)
      if val.is_a?(String)
        @isbn_13 = val if val.gsub(/[^0-9xX]/, '').size == 13
        @isbn_10 = val if val.gsub(/[^0-9xX]/, '').size != 13
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def isbn
      (@isbn_10.nil? or @isbn_10 == '') ? @isbn_13 : @isbn_1o
    end
    
# --------------------------------------------------------------------------------------------------------------------    
    def eisbn=(val)
      if val.is_a?(String)
        @eisbn_13 = val if val.gsub(/[^0-9xX]/, '').size == 13
        @eisbn_10 = val if val.gsub(/[^0-9xX]/, '').size != 13
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def eisbn
      (@eisbn_10.nil? or @eisbn_10 == '') ? @eisbn_13 : @eisbn_10
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def to_s
      "genre: '#{@genre}', content_type: '#{@content_type}', " + identifiers.map{ |x,y| "#{x}: '#{y}'" }.join(', ')
    end
  
# --------------------------------------------------------------------------------------------------------------------
    def to_hash
      ret = {}
      
      self.methods.each do |method|
        name = method.id2name.gsub('=', '')
        val = self.method(name).call if method.id2name[-1] == '=' and self.respond_to?(name)  
        ret["#{name}"] = val unless val.nil? or ['!', 'others', 'resources', 'short_titles', 'authors', 'errors'].include?(name)
      end

      ret["short_titles"] = @short_titles.first unless @short_titles.empty?
      
      @others.each{ |item| parts = item.split('='); ret["#{parts[0]}"] = "#{parts[1]}" }
      
      ret
    end
    
  end
end