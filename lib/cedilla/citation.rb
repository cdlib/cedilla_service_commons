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

# --------------------------------------------------------------------------------------------------------------------    
    def initialize(params = {})
      @authors = []
      @resources = []
      
      # Assign the appropriate params to their attributes, place everything 
      params.each do |key,val|
        key = key.id2name if key.is_a?(Symbol)
        
        if key == 'authors'
          val.each do |auth|
            if auth.is_a?(Cedilla::Author)
              @authors << auth
            else
              @authors << Cedilla::Author.new(auth)
            end 
          end
          
        elsif self.respond_to?("#{key}=")
          self.method("#{key}=").call(val)
        end
      end

    end
    
# --------------------------------------------------------------------------------------------------------------------    
# Establish the primary key for the object: identifiers and titles
# --------------------------------------------------------------------------------------------------------------------    
    def ==(object)
      return false unless object.is_a?(self.class)
      
      # Otherise determine if the genre and at least one of the identifiers match
      @genre == object.genre and (@issn == object.issn or @eissn == object.eissn or @isbn == object.isbn or @eisbn == object.eisbn or 
                                  @oclc == object.oclc or @lccn == object.lccn or @doi == object.doi or @pmid == object.pmid or
                                  @coden == object.coden or @sici == object.sici or @bici == object.bici or @document_id == object.document_id or
                                  @dissertation_number == object.dissertation_number or @bibcode == object.bibcode or @eric == object.eric or
                                  @oai == object.oai or @nbn == object.nbn or @hdl == object.hdl)
    end

# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation is valid
# --------------------------------------------------------------------------------------------------------------------
    def valid?
      # A Citation MUST have a genre and (at least one identifier OR a title and author)
      @genre and (has_identifier? or (@title and @authors.size > 0))
    end
    
# --------------------------------------------------------------------------------------------------------------------
# Determine whether or not the citation has an identifier
# --------------------------------------------------------------------------------------------------------------------    
    def has_identifier?
      (!@issn.nil? and @issn != '') or (!@eissn.nil? and @eissn != '') or 
            (!@isbn_10.nil? and @isbn_10 != '') or (!@eisbn_10.nil? and @eisbn_10 != '') or 
            (!@isbn_13.nil? and @isbn_13 != '') or (!@eisbn_13.nil? and @eisbn_13 != '') or 
            (!@oclc.nil? and @oclc != '') or (@lccn.nil? and @lccn != '') or (!@doi.nil? and @doi != '') or 
            (!@pmid.nil? and @pmid != '') or (@coden.nil? and @coden != '') or (!@sici.nil? and @sici != '') or
            (!@bici.nil? and @bici != '') or (@document_id.nil? and @document_id != '') or
            (!@dissertation_number.nil? and @dissertation_number != '') or (!@bibcode.nil? and @bibcode != '') or
            (!@eric.nil? and @eric != '') or (!@oai.nil? and @oai != '') or 
            (!@nbn.nil? and @nbn != '') or (!@hdl.nil? and @hdl != '')
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