module Cedilla
  
  class Citation
    
    attr_accessor :genre
    
    attr_accessor :resources, :authors
    
    # These items are updated by the services and sent back to the aggregator
    attr_accessor :subject, :sample_cover_image, :abstract_text, :language
    
    # Identifiers
    attr_accessor :issn, :eissn, :isbn, :eisbn, :isbn, :eisbn, :oclc, :lccn, :doi
    attr_accessor :pmid, :coden, :sici, :bici, :document_id, :dissertation_number
    attr_accessor :bibcode, :eric, :oai, :nbn, :hdl
    
    # Titles
    attr_accessor :title, :article_title, :journal_title, :chapter_title, :book_title, :short_title
    
    # Publisher attributes
    attr_accessor :publisher, :publication_date, :publication_place
    
    # Detailed search attributes
    attr_accessor :year, :month, :day, :season, :quarter 
    attr_accessor :volume, :issue, :article_number, :enumeration, :part, :edition, :institution, :series
    attr_accessor :start_page, :end_page, :pages

    attr_accessor :extras

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params)
      if params.is_a?(Hash)
        @authors = []
        @resources = []
        @extras = {}
      
        # Assign the appropriate params to their attributes, place everything 
        params.each do |key,val|
          key = key.id2name if key.is_a?(Symbol)
        
          if key == 'authors'
            val.each do |auth|
              if auth.is_a?(Cedilla::Author)
                @authors << auth
              else
                unless auth.empty? 
                  @authors << Cedilla::Author.new(auth)
                end
              end 
            end
          
          elsif self.respond_to?("#{key}=")
            self.method("#{key}=").call(val)
          
          else
            if self.extras["#{key}"].nil?
              self.extras["#{key}"] = []
            end
          
            self.extras["#{key}"] << val
          end
        end

      else
        raise Error.new("You must supply an attribute hash!")
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: identifiers and titles
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      ret = false
      
      if object.is_a?(self.class)
        # Check all of the ids for a match
        ret = @issn == object.issn if !@issn.nil? and !object.issn.nil?
        ret = @eissn == object.eissn if (!@eissn.nil? and !object.eissn.nil?) and !ret
        ret = @isbn == object.isbn if (!@isbn.nil? and !object.isbn.nil?) and !ret
        ret = @eisbn == object.eisbn if (!@eisbn.nil? and !object.eisbn.nil?) and !ret
        ret = @oclc == object.oclc if (!@oclc.nil? and !object.oclc.nil?) and !ret
        ret = @lccn == object.lccn if (!@lccn.nil? and !object.lccn.nil?) and !ret
        ret = @doi == object.doi if (!@doi.nil? and !object.doi.nil?) and !ret
        ret = @pmid == object.pmid if (!@pmid.nil? and !object.pmid.nil?) and !ret
        ret = @coden == object.coden if (!@coden.nil? and !object.coden.nil?) and !ret
        ret = @sici == object.sici if (!@sici.nil? and !object.sici.nil?) and !ret
        ret = @bici == object.bici if (!@bici.nil? and !object.bici.nil?) and !ret
        ret = @document_id == object.document_id if (!@document_id.nil? and !object.document_id.nil?) and !ret
        ret = @dissertation_number == object.dissertation_number if (!@dissertation_number.nil? and !object.dissertation_number.nil?) and !ret
        ret = @bibcode == object.bibcode if (!@bibcode.nil? and !object.bibcode.nil?) and !ret
        ret = @eric == object.eric if (!@eric.nil? and !object.eric.nil?) and !ret
        ret = @oai == object.oai if (!@oai.nil? and !object.oai.nil?) and !ret
        ret = @nbn == object.nbn if (!@nbn.nil? and !object.nbn.nil?) and !ret
        ret = @hdl == object.hdl if (!@hdl.nil? and !object.hdl.nil?) and !ret
        
        # If no ids matched and either this Citation or the one passed in has no ids then match by titles!
        if (@issn.nil? and @eissn.nil? and @isbn.nil? and @eisbn.nil? and @oclc.nil? and @lccn.nil? and @doi.nil? and @pmid.nil? and
                          @coden.nil? and @sici.nil? and @bici.nil? and @document_id.nil? and @dissertation_number.nil? and
                          @bibcode.nil? and @eric.nil? and @oai.nil? and @nbn.nil? and @hdl.nil?) or
                  (object.issn.nil? and object.eissn.nil? and object.isbn.nil? and object.eisbn.nil? and object.oclc.nil? and 
                          object.lccn.nil? and object.doi.nil? and object.pmid.nil? and object.coden.nil? and object.sici.nil? and 
                          object.bici.nil? and object.document_id.nil? and object.dissertation_number.nil? and
                          object.bibcode.nil? and object.eric.nil? and object.oai.nil? and object.nbn.nil? and object.hdl.nil?)
                          
          ret = @article_title == object.article_title if (!@article_title.nil? and !object.article_title.nil?) and !ret
          ret = @book_title == object.book_title if (!@book_title.nil? and !object.book_title.nil?) and !ret
          ret = @title == object.title if (!@title.nil? and !object.title.nil?) and !ret
          ret = @journal_title == object.journal_title if (!@journal_title.nil? and !object.journal_title.nil?) and !ret
        end
      end
      
      ret
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
# Determine whether or not the citation is valid
# --------------------------------------------------------------------------------------------------------------------
    def valid?
      # A Citation MUST have a genre and (at least one identifier OR a title and author)
      (!@genre.nil? and (has_identifier? or (!@title.nil? and @title != '' and @authors.size > 0)))
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation has an identifier
# --------------------------------------------------------------------------------------------------------------------    
    def has_identifier?      
      ((!@issn.nil? and @issn != '')      or (!@eissn.nil? and @eissn != '') or 
            (!@isbn.nil? and @isbn != '') or (!@eisbn.nil? and @eisbn != '') or 
            (!@oclc.nil? and @oclc != '') or (!@lccn.nil? and @lccn != '')   or (!@doi.nil? and @doi != '') or 
            (!@pmid.nil? and @pmid != '') or (!@coden.nil? and @coden != '') or (!@sici.nil? and @sici != '') or
            (!@bici.nil? and @bici != '') or (!@document_id.nil? and @document_id != '') or
            (!@dissertation_number.nil? and @dissertation_number != '')      or (!@bibcode.nil? and @bibcode != '') or
            (!@eric.nil? and @eric != '') or (!@oai.nil? and @oai != '') or 
            (!@nbn.nil? and @nbn != '')   or (!@hdl.nil? and @hdl != ''))
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
      ret['isbn'] = @isbn unless @isbn.nil? or @isbn == ''
      ret['eisbn'] = @eisbn unless @eisbn.nil? or @eisbn == ''
      ret['oclc'] = @oclc unless @oclc.nil? or @oclc == ''
      ret['lccn'] = @lccn unless @lccn.nil? or @lccn == ''
      ret['doi'] = @doi unless @doi.nil? or @doi == ''
      ret['pmid'] = @pmid unless @pmid.nil? or @pmid == ''
      ret['coden'] = @coden unless @coden.nil? or @coden == ''
      ret['sici'] = @sici unless @sici.nil? or @sici == ''
      ret['bici'] = @bici unless @bici.nil? or @bici == ''
      ret['document_id'] = @document_id unless @document_id.nil? or @document_id == ''
      ret['dissertation_number'] = @dissertation_number unless @dissertation_number.nil? or @dissertation_number == ''
      ret['bibcode'] = @bibcode unless @bibcode.nil? or @bibcode == ''
      ret['eric'] = @eric unless @eric.nil? or @eric == ''
      ret['oai'] = @oai unless @oai.nil? or @oai == ''
      ret['nbn'] = @nbn unless @nbn.nil? or @nbn == ''
      ret['hdl'] = @hdl unless @hdl.nil? or @hdl == ''     
      ret
    end

# --------------------------------------------------------------------------------------------------------------------
    def authors=(val)
      val.each do |auth| 
        if auth.is_a?(Cedilla::Author)
          @authors << auth 
        elsif auth.is_a?(Hash)
          @authors << Cedilla::Author.new(auth)
        end
      end
    end
    
# --------------------------------------------------------------------------------------------------------------------
    def resources=(val)
      val.each do |res| 
        if res.is_a?(Cedilla::Resource)
          @resources << res 
        elsif res.is_a?(Hash)
          @resources << Cedilla::Resource.new(res)
        end
      end
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
        ret["#{name}"] = val unless val.nil? or ['!', 'resources', 'authors'].include?(name)
      end

      #authors to hash
      auths = Array.new
      @authors.each{ |auth| auths << auth.to_hash if auth.is_a?(Cedilla::Author)}
      ret["authors"] = auths unless auths.nil? or auths.empty?
      
      #resources to hash
      resArr = Array.new
      @resources.each{ |res| resArr << res.to_hash if res.is_a?(Cedilla::Resource)}
      ret["resources"] = resArr unless resArr.nil? or resArr.empty?
      
      ret
    end
    
  end
end