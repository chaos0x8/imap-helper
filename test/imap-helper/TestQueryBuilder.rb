#!/usr/bin/env ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../../lib/imap-helper/QueryBuilder'

class TestQueryBuilder < Test::Unit::TestCase
  context('TestQueryBuilder') {
    setup {
      @sut = ImapHelper::QueryBuilder.new
    }

    should('add seen flag') {
      assert(@sut.seen.build.include? 'SEEN')
    }

    should('add unflagged flag') {
      assert(@sut.unflagged.build.include? 'UNFLAGGED')
    }

    should('add from flags') {
      query = @sut.from('email').build

      assert(query.include? 'FROM')
      assert(query.include? 'email')
    }

    should('add to flags') {
      assert_equal(['TO', 'email'], @sut.to('email').build)
    }

    should('add or flag when few emails') {
      emails = ['1', '2', '3']

      assert_equal(['OR', 'FROM', '1', 'OR', 'FROM', '2', 'FROM', '3'], @sut.from(emails).build)
    }

    should('add before flag') {
      assert_equal(['BEFORE', ImapHelper::ImapDate.now.daysAgo(7).to_s], @sut.before(7).build)
    }

    should('add few flags') {
      assert_equal(['SEEN', 'UNFLAGGED', 'FROM', 'a'], @sut.seen.unflagged.from('a').build)
    }

    context('with email file') {
      setup {
        @emailFile = mock
        @emailFile.stubs(:instance_of?).with(ImapHelper::EmailFile).returns(true)
      }

      should('add from flags from EmailFile') {
        @emailFile.expects(:read).returns(['a'])

        assert_equal(['FROM', 'a'], @sut.from(@emailFile).build)
      }
    }
  }
end
