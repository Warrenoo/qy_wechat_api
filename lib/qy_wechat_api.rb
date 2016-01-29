# encoding: utf-8

require 'active_support/all'
require "typhoeus"
require "carrierwave"
require 'yajl/json_gem'

require "qy_wechat_api/carrierwave/qy_wechat_api_uploader"
require "qy_wechat_api/config"
require "qy_wechat_api/client"
require "qy_wechat_api/handler"
require "qy_wechat_api/api"
require "qy_wechat_api/suite"

module QyWechatApi

  # Storage
  autoload(:Storage,       "qy_wechat_api/storage/storage")
  autoload(:ObjectStorage, "qy_wechat_api/storage/object_storage")
  autoload(:RedisStorage,  "qy_wechat_api/storage/redis_storage")

  ENDPOINT_URL   = "https://qyapi.weixin.qq.com/cgi-bin".freeze
  SUITE_ENDPOINT = "https://qy.weixin.qq.com/cgi-bin".freeze
  OK_MSG  = "ok".freeze
  OK_CODE = 0.freeze

  class << self

    def http_get_without_token(url, params={})
      logger.info("url: #{url}--- params: #{params}")
      get_api_url = ENDPOINT_URL + url
      response = Typhoeus.get(get_api_url, params: params)
      if response.success?
        load_json(response.body)
      else
        logger.error("response fail!")
      end
    end

    def http_post_without_token(url, payload={}, params={})
      logger.info("url: #{url}-- payload: #{payload}-- params: #{params}")
      post_api_url = ENDPOINT_URL + url
      payload = JSON.dump(payload) if !payload[:media].is_a?(File)
      response = Typhoeus.post(post_api_url, body: payload, params: params)
      if response.success?
        load_json(response.body)
      else
        logger.error("response fail!")
      end
    end

    # return hash
    def load_json(string)
      result_hash = JSON.parse(string)
      code   = result_hash.delete("errcode")
      en_msg = result_hash.delete("errmsg")
      ResultHandler.new(code, en_msg, result_hash)
    end

    def open_endpoint(url)
      "https://open.weixin.qq.com#{url}"
    end

    def cache
      if config.try(:cache_store)
        config.cache_store
      elsif on_rails?
        Rails.cache
      else
        raise Errors::ConfigException, "You should appoint cache_store, e.g. Rails.cache or lookup ActiveSupport::Cache#lookup_store"
      end
    end

    def logger
      if config.try(:logger)
        config.logger
      elsif on_rails?
        Rails.logger
      else
        raise Errors::ConfigException, "You should appoint one logger, e.g. Rails.logger or lookup ActiveSupport::Logger"
      end
    end

    def on_rails?
      defined?(Rails)
    end
  end
end
