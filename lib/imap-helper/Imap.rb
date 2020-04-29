#!/usr/bin/env ruby

require_relative 'ImapOperation'

require 'net/imap'

module ImapHelper
  class Imap
    def initialize login, password
      @login = login
      @password = password
      @imap = nil
    end

    def fetch search, box: nil, exclude: []
      search = search.build if search.respond_to? :build

      Imap::Operation.fetch(@imap, box || data_.inbox, exclude) { |toFetch|
        @imap.search(search).each { |msgId|
          toFetch << msgId
        }
      }
    end

    def moveMails directory, search, box: nil, &condition
      search = search.build if search.respond_to? :build

      Imap::Operation.move(@imap, box || data_.inbox) { |toMove|
        msgIds = @imap.search(search)

        if condition
          if msgIds.size > 0
            @imap.fetch(msgIds, ['UID', 'RFC822']).collect { |fetchData|
              [fetchData.seqno, Imap::Message.new(fetchData: fetchData)]
            }.each { |msgId, msg|
              if condition.call(msg)
                toMove << { msgId => directory }
              end
            }
          end
        else
          msgIds.each { |msgId|
            toMove << { msgId => directory }
          }
        end
      }
    end

    def deleteMails directory, search, &condition
      search = search.build if search.respond_to? :build

      Imap::Operation.delete(@imap, directory) { |toDel|
        msgIds = @imap.search(search)
        if condition
          if msgIds.size > 0
            @imap.fetch(msgIds, ['UID', 'RFC822']).collect { |fetchData|
              [fetchData.seqno, Imap::Message.new(fetchData: fetchData)]
            }.each { |msgId, msg|
              if condition.call(msg)
                toDel << msgId
              end
            }
          end
        else
          msgIds.each { |msgId|
            toDel << msgId
          }
        end
      }

      rmdir directory if directory != data_.inbox
    end

    def rmdir directory
      messages = Imap::Operation::examine(@imap, directory) {
        @imap.search(['ALL']).to_a.size
      }

      if messages == 0
        Imap::Operation.rmdir @imap, directory
      end
    end

    def ls directory = nil
      Imap::Operation::ls @imap, directory
    end

    def login
      @imap = Net::IMAP.new(data_.imap, 993, true)
      begin
        @imap.login(@login, @password)

        begin
          yield
        ensure
          @imap.logout unless @imap.disconnected?
        end
      ensure
        @imap.disconnect unless @imap.disconnected?
      end
    end

  private
    class Gmail
      def imap
        'imap.gmail.com'
      end

      def inbox
        'INBOX'
      end
    end

    class Aol
      def imap
        'imap.aol.com'
      end

      def inbox
        'Inbox'
      end
    end

    class Wp
      def imap
        'imap.wp.pl'
      end

      def inbox
        'Inbox'
      end
    end

    def data_
      if @login.match(/@gmail\.com$/)
        Gmail.new
      elsif @login.match(/@aol\.com$/)
        Aol.new
      elsif @login.match(/@wp\.pl$/)
        Wp.new
      else
        raise 'Unknown imap server'
      end
    end
  end
end
