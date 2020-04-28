#!/usr/bin/env ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'
require 'tempfile'

require_relative '../../lib/imap-helper/EmailFile'

class TestEmailFile < Test::Unit::TestCase
  def set_content content, ext: nil
    @f = Tempfile.new(['email-file', ext.to_s])
    @f.write content
    @f.close
  end

  def self.readTest name, content, mode: nil, ext: nil, &block
    proc {
      should(name) {
        set_content content, ext: ext

        @sut = ImapHelper::EmailFile.new(@f.path, mode)

        instance_eval(&block)
      }
    }
  end

  def self.shouldRead name, content, mode: nil, ext: nil
    readTest(name, content, mode: mode, ext: ext) {
      assert_equal(['a', 'b', 'c'], @sut.read)
    }
  end

  def self.shouldRaiseOnCreate name, error, mode: nil, ext: nil
    proc {
      should(name) {
        set_content '', ext: ext

        assert_raise(error) {
          ImapHelper::EmailFile.new(@f.path, mode)
        }
      }
    }
  end

  def self.shouldRaiseOnRead name, error, mode: nil, ext: nil
    readTest(name, '', mode: mode, ext: ext) {
      assert_raise(error) {
        @sut.read
      }
    }
  end

  context('TestEmailFile') {
    teardown {
      @f.unlink if @f
    }

    merge_block(&shouldRaiseOnCreate(
      'raise detect error when file extension is unsupported',
      ImapHelper::EmailFile::DetectError, ext: '.png'))

    merge_block(&shouldRaiseOnRead(
      'raise mode error when mode is unsupported',
      ImapHelper::EmailFile::ModeError, mode: :png))

    [ "a\n \nb  \n  c  ",
      "a\nb\n  c  \n\n",
      "\xEF\xBB\xBFa\n \nb  \n  c  ",
      "\xEF\xBB\xBFa\nb\n  c  \n\n" ].each_with_index { |content, index|

      merge_block(&shouldRead("read txt content/#{index}", content, mode: :txt))
      merge_block(&shouldRead("read txt content with auto mode/#{index}", content, ext: '.txt'))
    }

    [ "[ \"a\", \"b\", \"c\" ]",
      "\xEF\xBB\xBF[ \"a\", \"b\", \"c\" ]" ].each_with_index { |content, index|

      merge_block(&shouldRead("read json content/#{index}", content, mode: :json))
      merge_block(&shouldRead("read json content with auto mode/#{index}", content, ext: '.json'))
    }
  }
end

