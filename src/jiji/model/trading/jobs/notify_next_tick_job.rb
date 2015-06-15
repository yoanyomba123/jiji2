# coding: utf-8

require 'encase'
require 'thread'

module Jiji::Model::Trading::Jobs
  class NotifyNextTickJob

    def initialize
      @counter = 0
    end

    def exec(trading_context, queue)
      before_do_next(trading_context, queue)
      trading_context.agents.next_tick(trading_context.broker.tick)
      after_do_next(trading_context, queue)
    end

    def before_do_next(trading_context, queue)
      trading_context.broker.refresh
      refresh_positions_and_account_per_minutes(trading_context)
    end

    def after_do_next(trading_context, queue)
      time = trading_context.broker.tick.timestamp
      trading_context.graph_factory.save_data(time)
    end

    private

    def refresh_positions_and_account_per_minutes(trading_context)
      @counter += 1
      return if @counter < 4

      trading_context.broker.refresh_positions
      trading_context.broker.refresh_account
      @counter = 0
    end

  end

  class NotifyNextTickJobForRMT < NotifyNextTickJob

  end

  class NotifyNextTickJobForBackTest < NotifyNextTickJob

    def initialize(start_time, end_time)
      super()
      @counter    = 0
      @start_time = start_time
      @end_time   = end_time
      @sec        = @end_time.to_i - @start_time.to_i
    end

    def after_do_next(context, queue)
      update_progress(context, context.broker.tick.timestamp)

      return unless context.alive?
      if context.broker.next?
        queue << self
        sleep 0.01
      else
        context.request_finish
      end
    end

    private

    def update_progress(context, timestamp)
      context[:current_time] = timestamp
      context[:progress] = calculate_progress(timestamp)
    end

    def calculate_progress(timestamp)
      return 0.0 if timestamp <= @start_time
      return 1.0 if timestamp >= @end_time
      (timestamp.to_i - @start_time.to_i).to_f / @sec
    end

  end
end
