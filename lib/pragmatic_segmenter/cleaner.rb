# -*- encoding : utf-8 -*-

module PragmaticSegmenter
  # This is an opinionated class that removes errant newlines,
  # xhtml, inline formatting, etc.
  class Cleaner
    # Rubular: http://rubular.com/r/ENrVFMdJ8v
    HTML_TAG_REGEX = /<\/?[^>]*>/

    # Rubular: http://rubular.com/r/XZVqMPJhea
    ESCAPED_HTML_TAG_REGEX = /&lt;\/?[^gt;]*gt;/

    # Rubular: http://rubular.com/r/V57WnM9Zut
    NEWLINE_IN_MIDDLE_OF_WORD_REGEX = /\n(?=[a-zA-Z]{1,2}\n)/

    # Rubular: http://rubular.com/r/3GiRiP2IbD
    NEWLINE_IN_MIDDLE_OF_SENTENCE_REGEX = /(?<=\s)\n(?=([a-z]|\())/

    # Rubular: http://rubular.com/r/UZAVcwqck8
    NEWLINE_IN_MIDDLE_OF_SENTENCE_PDF_REGEX = /(?<=[^\n]\s)\n(?=\S)/

    # Rubular: http://rubular.com/r/eaNwGavmdo
    NEWLINE_IN_MIDDLE_OF_SENTENCE_PDF_NO_SPACES_REGEX = /\n(?=[a-z])/

    # Rubular: http://rubular.com/r/bAJrhyLNeZ
    INLINE_FORMATTING_REGEX = /\{b\^&gt;\d*&lt;b\^\}|\{b\^>\d*<b\^\}/

    # Rubular: http://rubular.com/r/dMxp5MixFS
    DOUBLE_NEWLINE_WITH_SPACE_REGEX = /\n \n/

    # Rubular: http://rubular.com/r/H6HOJeA8bq
    DOUBLE_NEWLINE_REGEX = /\n\n/

    # Rubular: http://rubular.com/r/Gn18aAnLdZ
    NEWLINE_FOLLOWED_BY_BULLET_REGEX = /\n(?=•)/

    # Rubular: http://rubular.com/r/FseyMiiYFT
    NEWLINE_FOLLOWED_BY_PERIOD_REGEX = /\n(?=\.(\s|\n))/

    # Rubular: http://rubular.com/r/8mc1ArOIGy
    TABLE_OF_CONTENTS_REGEX = /\.{5,}\s*\d+-*\d*/

    # Rubular: http://rubular.com/r/DwNSuZrNtk
    CONSECUTIVE_PERIODS_REGEX = /\.{5,}/

    attr_reader :text, :doc_type
    def initialize(text:, **args)
      @text = text.dup
      @doc_type = args[:doc_type]
    end

    # Clean text of unwanted formatting
    #
    # Example:
    #   >> text = "This is a sentence\ncut off in the middle because pdf."
    #   >> PragmaticSegmenter::Cleaner(text: text).clean
    #   => "This is a sentence cut off in the middle because pdf."
    #
    # Arguments:
    #    text:       (String)  *required
    #    language:   (String)  *optional
    #                (two-digit ISO 639-1 code e.g. 'en')
    #    doc_type:   (String)  *optional
    #                (e.g. 'pdf')

    def clean
      return unless text
      @clean_text = remove_all_newlines(text)
      @clean_text = replace_double_newlines(@clean_text)
      @clean_text = replace_newlines(@clean_text)
      @clean_text = strip_html(@clean_text)
      @clean_text = strip_other_inline_formatting(@clean_text)
      @clean_text = clean_quotations(@clean_text)
      @clean_text = clean_table_of_contents(@clean_text)
    end

    private

    def remove_all_newlines(txt)
      clean_text = remove_newline_in_middle_of_sentence(txt)
      remove_newline_in_middle_of_word(clean_text)
    end

    def remove_newline_in_middle_of_sentence(txt)
      txt.dup.gsub!(/(?:[^\.])*/) do |match|
        next unless match.include?("\n")
        orig = match.dup
        match.gsub!(NEWLINE_IN_MIDDLE_OF_SENTENCE_REGEX, '')
        txt.gsub!(/#{Regexp.escape(orig)}/, "#{match}")
      end
      txt
    end

    def remove_newline_in_middle_of_word(txt)
      txt.gsub(NEWLINE_IN_MIDDLE_OF_WORD_REGEX, '')
    end

    def strip_html(txt)
      txt.gsub(HTML_TAG_REGEX, '').gsub(ESCAPED_HTML_TAG_REGEX, '')
    end

    def strip_other_inline_formatting(txt)
      txt.gsub(INLINE_FORMATTING_REGEX, '')
    end

    def replace_double_newlines(txt)
      txt.gsub(DOUBLE_NEWLINE_WITH_SPACE_REGEX, "\r")
        .gsub(DOUBLE_NEWLINE_REGEX, "\r")
    end

    def replace_newlines(txt)
      if doc_type.eql?('pdf')
        txt = remove_pdf_line_breaks(txt)
      else
        txt =
          txt.gsub(NEWLINE_FOLLOWED_BY_PERIOD_REGEX, '').gsub(/\n/, "\r")
      end
      txt
    end

    def remove_pdf_line_breaks(txt)
      txt.gsub(NEWLINE_FOLLOWED_BY_BULLET_REGEX, "\r")
        .gsub(NEWLINE_IN_MIDDLE_OF_SENTENCE_PDF_REGEX, '')
        .gsub(NEWLINE_IN_MIDDLE_OF_SENTENCE_PDF_NO_SPACES_REGEX, ' ')
    end

    def clean_quotations(txt)
      txt.gsub(/''/, '"').gsub(/``/, '"')
    end

    def clean_table_of_contents(txt)
      txt.gsub(TABLE_OF_CONTENTS_REGEX, "\r")
        .gsub(CONSECUTIVE_PERIODS_REGEX, ' ')
    end
  end
end
