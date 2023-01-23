require_relative "lib/diff_checker"
require_relative "lib/oneline_logger"

desc "Bitcoinノードの最新ブロックと、Explorerの最新ブロックのブロック差分を監視するスクリプト"
task :check_diff do
  # 環境変数から必要なパラメータを取得
  host = ENV["BITCOIND_HOST"] || abort("Please set BITCOIND_HOST")
  port = ENV["BITCOIND_PORT"] || abort("Please set BITCOIND_PORT")
  username = ENV["BITCOIND_USERNAME"] || abort("Please set BITCOIND_USERNAME")
  password = ENV["BITCOIND_PASSWORD"] || abort("Please set BITCOIND_PASSWORD")
  slack_webhook_url = ENV["SLACK_WEBHOOK_URL"] || abort("Please set SLACK_WEBHOOK_URL")

  checker = DiffChecker.new(host, port, username, password, slack_webhook_url)
  checker.run
rescue => e
  logger = OnelineLogger.get
  logger.error(e)
end
