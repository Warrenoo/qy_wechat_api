# encoding: utf-8

require "rest-client"
require 'yajl/json_gem'

require "qy_wechat_api/client"
require "qy_wechat_api/handler"
require "qy_wechat_api/api"

module QyWechatApi
  ENDPOINT_URL = "https://qyapi.weixin.qq.com/cgi-bin"
  OK_MSG     = "ok".freeze
  OK_CODE    = 0.freeze

  class << self
    def corpid
      "wxb9ce1d023fe6eb69"
    end

    def corpsecret
      "UOofFIah4PVLmkG8xMH3lpDxj6NTnQSKMrFt-HubiPB4kjB09EmTVcUjgNeermps"
    end

    def http_get_without_token(url, params={})
      get_api_url = ENDPOINT_URL + url
      puts get_api_url
      puts params
      load_json(RestClient.get(get_api_url, params: params))
    end

    def http_post_without_token(url, payload={}, params={})
      post_api_url = ENDPOINT_URL + url
      puts post_api_url
      puts payload
      puts params
      payload = JSON.dump(payload)
      load_json(RestClient.post(post_api_url, payload, params: params))
    end

    # return hash
    def load_json(string)
      result_hash = JSON.parse(string)
      code   = result_hash.delete("errcode")
      en_msg = result_hash.delete("errmsg")
      ResultHandler.new(code, en_msg, result_hash)
    end
  end
end