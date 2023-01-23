require "logger"
require "oneline_log_formatter"

# ログは1行になってくれたほうがありがたいように感じたので
# https://github.com/sonots/oneline_log_formatter
class OnelineLogger
  # OnelineLogFormatter を適用した Logger を返す
  # @return [Logger]
  def self.get
    logger = Logger.new($stdout)
    logger.formatter = OnelineLogFormatter.new
    logger
  end
end
