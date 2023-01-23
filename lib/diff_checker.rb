require "bitcoin-client"
require_relative "blockchain_com_client"
require "slack-notifier"
require_relative "oneline_logger"

# Bitcoin ノードの最新ブロックと、Explorer の最新ブロックのブロック差分 Diff を監視するスクリプトの本体
class DiffChecker
  # @param [String] host bitcoind のホスト
  # @param [Integer] port bitcoind の JSON-RPC のポート
  # @param [String] username bitcoind の rpcuser
  # @param [String] password bitcoind の rpcpassword
  # @param [String] slack_webhook_url 通知先 Slack の Webhook URL
  def initialize(host, port, username, password, slack_webhook_url)
    @host = host
    @port = port
    @username = username
    @password = password
    @slack_webhook_url = slack_webhook_url
  end

  # Diff のチェックを実行する
  def run
    # - bitcoind から latest block number を取得する

    bitcoind_client = Bitcoin::Client.new(@username, @password, host: @host, port: @port)
    local_block_count = bitcoind_client.getblockcount
    logger = OnelineLogger.get
    logger.info("Latest block number on local bitcoind is #{local_block_count}")

    # - explorer から latest block number を取得する

    blockchain_com_client = BlockchainComClient.new
    explorer_block_count = blockchain_com_client.get_block_count
    logger.info("Latest block number on blockchain.com explorer is #{explorer_block_count}")

    # - bitcoind と explorer の差分の±3 block 以上の Diff があれば slack に通知し、Diff が±2以下であれば、何も通知しない

    diff = explorer_block_count - local_block_count
    if diff.abs > 2
      notifier = Slack::Notifier.new(@slack_webhook_url)
      notifier.ping("Diff is greater than 2: explorer_block_count(#{explorer_block_count}) - local_block_count(#{local_block_count}) = #{diff}")
      logger.info("Posted to slack")
    end

    nil
  end
end
