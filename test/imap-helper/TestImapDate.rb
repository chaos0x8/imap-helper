#!/usr/bin/env ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/imap-helper/ImapDate'

class TestImapDate < Test::Unit::TestCase
  context('TestImapDate') {
    should('fail to create date with new') {
      assert_raise(NoMethodError) {
        ImapHelper::ImapDate.new(DateTime.now)
      }
    }

    should('create date with now') {
      assert(ImapHelper::ImapDate.now.instance_of? ImapHelper::ImapDate)
    }

    context('with sut') {
      setup {
        @sut = ImapHelper::ImapDate.now
      }

      should('return date as string') {
        assert(@sut.to_s.instance_of? String)
      }

      should('return date different that now') {
        assert_not_equal(@sut.to_s, ImapHelper::ImapDate.now.daysAgo(1).to_s)
      }
    }
  }
end

