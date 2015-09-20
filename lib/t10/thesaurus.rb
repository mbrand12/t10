module T10
  # This class matches the user provided input using {scan} input with the
  # verbs, nouns and modifiers provided by the {add_words} and returns the
  # words that match the criteria.
  #
  # The idea to check the user input just for the verbs, nouns and
  # adjectives/adverbs (simply named modifiers). Since all the verbs, nouns and
  # modifiers have synonyms this allows the user more freedom in expression.
  #
  # So for example the user can type:
  #
  #     "Exit trough the leftmost door."
  #
  #     or
  #
  #     "Enter trough dragon cress door."
  #
  # To do exactly the same thing, or the user can just type "Enter left door".
  # This way provides a solid illusion of verbosity.
  class Thesaurus
    @verbs = {}
    @nouns = {}
    @modifiers = {}

    # Populates the class instance variables with the hashes made of keywords
    # (hash key) and synonyms (hash value). The hashes should be provided with
    # {Room#words}.
    #
    # An example of hash:
    #
    #     @verbs = {
    #       look:  %i(look glare stare),
    #       touch: %i(touch poke)
    #     }
    #
    # @param verbs [Hash] A hash of allowed keywords and its synonyms.
    # @param nouns [Hash]
    # @param modifiers [Hash]
    # @return [void]
    def self.add_words(verbs, nouns, modifiers)
      @verbs = verbs
      @nouns = nouns
      @modifiers = modifiers
    end

    # Scans the user input string, converts every word to symbol and checks
    # which words match the synonyms then returns an array of verbs, nouns,
    # modifiers arrays.
    #
    # @param text [String] A user input string.
    # @return [[Array<Symbol>, Array<Symbol>, Array<Symbol>]]
    def self.scan(text)
      words = convert_to_sym_array(text)

      return [[],[],[:no_words]] if words.empty?

      # return_keywords checks the given words symbols and if it finds the
      # matching synonym it returns the corresponding keywords
      verbs, words = return_keywords(words, @verbs)
      nouns, words = return_keywords(words, @nouns)
      modifiers, words = return_keywords(words, @modifiers)

      if verbs.empty? && nouns.empty? && modifiers.empty?
        [[],[],[:no_words]]
      else
        [verbs, nouns, modifiers]
      end
    end

    private

    def self.convert_to_sym_array(text)
      text.downcase.tr('^a-z ','').split(' ').map(&:to_sym)
    end

    def self.return_keywords(word_candidates, keyword_hash)
      result_array = []
      keyword_hash.each do |k,v|
        word_candidates.each do |word|
          if v.include?(word)
            result_array << k
            word_candidates.delete(word)
            break
          end
        end
      end
      [result_array, word_candidates]
    end
  end
end
