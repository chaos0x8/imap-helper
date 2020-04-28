#!/usr/bin/env ruby

require 'mail'
require 'json'

module ImapHelper
  class EmailFile
    class Error < RuntimeError; end

    class ModeError < Error
      def initialize mode
        super("ModeError unsupported file mode [#{mode}]")
      end
    end

    class DetectError < Error
      def initialize ext
        super("DetectError failed to match mode to extension [#{ext}]")
      end
    end

    def initialize fn, mode = nil
      @fn_ = fn
      @mode_ = mode

      unless @mode_
        case ext = File.extname(@fn_)
        when '.txt'
          @mode_ = :txt
        when '.json'
          @mode_ = :json
        else
          raise DetectError.new(ext)
        end
      end
    end

    def read
      case @mode_
      when :txt
        File.open(@fn_, 'r:bom|utf-8') { |f|
          @data_ ||= f.each_line.collect(&:strip).reject(&:empty?).collect { |v|
            Mail::Encodings.decode_encode(v, :encode)
          }
        }
      when :json
        File.open(@fn_, 'r:bom|utf-8') { |f|
          @data_ ||= JSON.parse(f.read).collect { |v|
            Mail::Encodings.decode_encode(v, :encode)
          }
        }
      else
        raise ModeError.new(@mode_)
      end
    end
  end
end
