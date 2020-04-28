autoload :DateTime, 'date'

module ImapHelper
  class ImapDate
    def ImapDate.now
      new(DateTime.now)
    end

    def initialize date
      @date_ = date
    end

    def daysAgo num
      @date_ -= num
      self
    end

    def to_s
      d = @date_.strftime('%d')
      m = ::Date::ABBR_MONTHNAMES[@date_.strftime('%m').to_i(10)]
      y = @date_.strftime('%Y')

      [ d, m, y ].join('-')
    end

    private_class_method :new
  end
end
