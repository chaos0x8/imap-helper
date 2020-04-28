#!/usr/bin/env ruby

require_relative 'EmailFile'
require_relative 'ImapDate'

module ImapHelper
  class QueryBuilder
    def initialize
      @to_ = []
      @from_ = []
      @all_ = nil
      @seen_ = nil
      @flagged_ = nil
      @before_ = nil
    end

    def all
      @all_ = 'ALL'
      self
    end

    def seen
      @seen_ = 'SEEN'
      self
    end

    def unseen
      @seen_ = 'UNSEEN'
      self
    end

    def flagged
      @flagged_ = 'FLAGGED'
      self
    end

    def unflagged
      @flagged_ = 'UNFLAGGED'
      self
    end

    def to val = []
      @to_ = convList_(val)
      self
    end

    def from val = []
      @from_ = convList_(val)
      self
    end

    def before daysAgo
      @before_ = daysAgo
      self
    end

    def build
      result = []

      result << @all_ if @all_
      result << @seen_ if @seen_
      result << @flagged_ if @flagged_
      result << ['BEFORE', ImapDate.now.daysAgo(@before_).to_s] if @before_
      result << or_(from_(@from_)) if @from_.size > 0
      result << or_(to_(@to_)) if @to_.size > 0

      result.flatten
    end

  private
    def convList_ val
      if val.instance_of? EmailFile
        [val.read].flatten
      else
        [val].flatten
      end
    end

    def to_ list
      list.collect { |v| ['TO', v] }
    end

    def from_ list
      list.collect { |v| ['FROM', v] }
    end

    def or_ list
      case list.size
      when 0
        []
      when 1
        list[0]
      else
        ['OR', list[0], or_(list[1..-1])]
      end
    end
  end
end
