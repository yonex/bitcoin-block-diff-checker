require "bitcoin-client"
require "logger"
require_relative "../lib/oneline_logger"
require_relative "../lib/blockchain_com_client"
require_relative "../lib/diff_checker"
require "slack-notifier"

# 勉強のため rspec を雰囲気だけでも書きました
RSpec.describe DiffChecker do
  let(:logger) { instance_double(Logger) }
  let(:bitcoind_client) { instance_double(Bitcoin::Client) }
  let(:blockchain_com_client) { instance_double(BlockchainComClient) }
  let(:slack_notifier) { instance_double(Slack::Notifier) }
  let(:diff_checker) { DiffChecker.new("localhost", 8332, "username", "password", "url") }

  before {
    allow(Bitcoin::Client).to receive(:new).and_return(bitcoind_client)
    allow(BlockchainComClient).to receive(:new).and_return(blockchain_com_client)
    allow(OnelineLogger).to receive(:get).and_return(logger)
    allow(Slack::Notifier).to receive(:new).and_return(slack_notifier)
  }

  example "Bitcoin ノードが Explorer より3以上おくれているとき Slack に通知される" do
    allow(bitcoind_client).to receive(:getblockcount).and_return(1000)
    allow(blockchain_com_client).to receive(:get_block_count).and_return(1003)

    expect(logger).to receive(:info).exactly(3).times
    expect(slack_notifier).to receive(:ping).with(/ = 3$/).once

    diff_checker.run
  end

  example "Bitcoin ノードが Explorer より3以上すすんでいるときも Slack に通知される" do
    allow(bitcoind_client).to receive(:getblockcount).and_return(1099)
    allow(blockchain_com_client).to receive(:get_block_count).and_return(1000)

    expect(logger).to receive(:info).exactly(3).times
    expect(slack_notifier).to receive(:ping).with(/ = -99$/).once

    diff_checker.run
  end

  example "Diff が2以下のときは Slack に通知されないこと" do
    allow(bitcoind_client).to receive(:getblockcount).and_return(1000)
    allow(blockchain_com_client).to receive(:get_block_count).and_return(1002)

    expect(logger).to receive(:info).twice
    expect(slack_notifier).not_to receive(:ping)

    diff_checker.run
  end
end
