module PragmaticSegmenter
  module Languages
    class Armenian < Common
      SENTENCE_BOUNDARY = /.*?[։՜:]|.*?$/

      class Process < PragmaticSegmenter::Process
        private

        def sentence_boundary_punctuation(txt)
          txt.scan(SENTENCE_BOUNDARY)
        end

        def punctuation_array
          Armenian::Punctuations
        end
      end

      Punctuations = ['։', '՜', ':']
    end
  end
end
