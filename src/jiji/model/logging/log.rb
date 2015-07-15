# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/pagenation'

module Jiji::Model::Logging
  class Log

    include Jiji::Utils::Pagenation

    def initialize( time_source, backtest = nil )
      @backtest    = backtest
      @time_source = time_source
    end

    def get(index, order=:asc)
      query = Query.new( filter, {timestamp: order}, index, 1 )
      data = query.execute(LogData)
      data && data.length > 0 ? data[0] : nil
    end

    def count
      LogData.where(filter).count
    end

    def delete_before(time)
      LogData.where(filter.merge({:timestamp.lte => time})).delete
    end

    def each
      query = Query.new( filter, {timestamp: :asc})
      query.execute(LogData).each do |data|
        yield data
      end
    end

    def write(message)
      @current = create_log_data unless @current
      @current << message
      shift if @current.full?
    end

    def close
      save_current_log_data
    end

    private

    def shift
      save_current_log_data
      @current = create_log_data
    end

    def create_log_data
      LogData::create(@time_source.now, nil, @backtest)
    end

    def save_current_log_data
      @current.save if @current
    end

    def filter
      {backtest_id: @backtest ? @backtest.id : nil}
    end

  end
end
