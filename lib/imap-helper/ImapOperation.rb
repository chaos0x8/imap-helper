#!/usr/bin/env ruby

require 'mail'

module ImapHelper
  class Message
    def self.attr_mail *args
      class_eval {
        args.each { |sym|
          define_method(sym) {
            @mail.send(sym)
          }
        }
      }
    end

    def initialize uid: nil, rfc822: nil, fetchData: nil
      @uid = uid || fetchData.attr['UID']
      @mail = Mail.read_from_string(rfc822 || fetchData.attr['RFC822'])
    end

    attr_mail :from, :subject
    attr_reader :uid
  end

  module Operation
    def examine imap, box
      res = nil

      if exist?(imap, box)
        imap.examine box

        begin
          res = yield
        ensure
          imap.close unless imap.disconnected?
        end
      end

      res
    end

    def fetch imap, box, exclude
      container = []
      res = []

      imap.select(box)

      begin
        yield container

        if not imap.disconnected?
          if container.size > 0
            uids = imap.fetch(container, 'UID').collect { |fetchData|
              fetchData.attr['UID']
            }.reject { |uid| exclude.include?(uid) }

            if uids.size > 0
              res = imap.uid_fetch(uids, ['UID', 'RFC822']).collect { |fetchData|
                Message.new(fetchData: fetchData)
              }
            end
          end
        end
      ensure
        imap.close unless imap.disconnected?
      end

      res.flatten.reject(&:nil?)
    end

    def move imap, box
      container = []

      imap.select(box)

      res = nil

      begin
        res = yield container

        _toOperations(container) { |dst, msgIds|
          if msgIds.size > 0
            ImapHelper::Operation.mkdir imap, dst
            imap.move(msgIds, dst)
          end
        }
      ensure
        imap.close unless imap.disconnected?
      end

      res
    end

    def delete imap, box
      container = []

      res = nil

      if exist?(imap, box)
        imap.select box

        begin
          res = yield container

          container.flatten!

          if container.size > 0
            imap.store(container, '+FLAGS', [:Seen, :Deleted])
            imap.expunge
          end
        ensure
          imap.close unless imap.disconnected?
        end
      end

      res
    end

    def exist? imap, dir
      if File.basename(dir) == dir
        !! imap.list(dir, '')
      else
        !! imap.list("#{File.dirname(dir)}/", File.basename(dir))
      end
    end

    def ls imap, dir = nil
      imap.list(dir || '%', '%')
    end

    def mkdir imap, dir
      if ! exist?(imap, dir)
        imap.create(dir)
      end
    end

    def rmdir imap, dir
      if ! exist?(imap, dir)
        imap.delete(dir)
      end
    end

    module_function :examine, :move, :delete, :exist?, :ls, :mkdir, :rmdir, :fetch

private
    def _toOperations container, &block
      operations = {}

      container.each { |map|
        map.each { |msgId, dst|
          operations[dst] ||= []
          operations[dst] << msgId
        }
      }

      operations.each(&block)
    end

    module_function :_toOperations
  end
end

