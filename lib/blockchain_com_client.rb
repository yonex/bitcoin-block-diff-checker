require "faraday"

# Blockchain.com の Query API 用クライアント
# https://www.blockchain.com/explorer/api/q
class BlockchainComClient
  def initialize
    @http_client = Faraday.new( # 書きやすかったので有名そうな Faraday を利用
      "https://blockchain.info",
      # デフォルトのタイムアウトは各60秒と長いようなので調整
      request: {open_timeout: 10, read_timeout: 10, write_timeout: 10}
    )
  end

  # Current block height in the longest chain
  # https://blockchain.info/q/getblockcount
  # @return [Integer] latest block number
  def get_block_count
    response = @http_client.get("/q/getblockcount")
    status = response.status
    body = response.body
    # ステータスコードの詳細仕様がわからないが、とりあえず簡単なものだけ入れておく
    if status != 200
      raise "Bad response status: status=#{status}, body=#{body}"
    end
    # レスポンスボディにそのまま数字が入ってくるシンプルなAPI
    body.to_i
  end
end
