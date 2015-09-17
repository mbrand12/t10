module T10
  class Thesaurus

    @verbs = {}
    @nouns = {}
    @modifiers = {}

    def self.add_words(verbs, nouns, modifiers)
      @verbs = verbs
      @nouns = nouns
      @modifiers = modifiers
    end

    def self.scan(text)
      words = convert_to_sym_array(text)

      return [[],[],[:no_words]] if words.empty?

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
