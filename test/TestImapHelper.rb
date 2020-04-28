#!/usr/bin/env ruby

require 'test/unit'
require 'mocha/setup'
require 'shoulda'

require_relative '../lib/imap-helper'

class TestImapHelper < Test::Unit::TestCase
  context('TestImapHelper') {
    should('require Imap') {
      assert(!! defined? ImapHelper::Imap)
    }

    should('require QueryBuilder') {
      assert(!! defined? ImapHelper::QueryBuilder)
    }

    should('require EmailFile') {
      assert(!! defined? ImapHelper::EmailFile)
    }

    should('require ImapDate') {
      assert(!! defined? ImapHelper::ImapDate)
    }

    should('require Operation') {
      assert(!! defined? ImapHelper::Operation)
    }
  }
end

