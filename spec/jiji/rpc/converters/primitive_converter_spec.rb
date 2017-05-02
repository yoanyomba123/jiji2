# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Converters::PrimitiveConverter do
  class Converter

    include Jiji::Rpc::Converters

  end

  let(:converter) { Converter.new }

  describe '#convert_timestamp_to_pb' do
    it 'converts Time to Google::Protobuf::Timestamp' do
      converted = converter.convert_timestamp_to_pb(Time.new(2016, 4, 5))
      expect(converted.seconds).to eq 1_459_782_000
      expect(converted.nanos).to be 0
    end
    it 'returns nil when a time is nil' do
      converted = converter.convert_timestamp_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_timestamp_from_pb' do
    it 'converts Google::Protobuf::timestamp to Time' do
      time = Google::Protobuf::Timestamp.new(seconds: 1_459_782_000, nanos: 0)
      converted = converter.convert_timestamp_from_pb(time)
      expect(converted).to eq Time.new(2016, 4, 5)
    end
    it 'returns nil when a time is nil' do
      converted = converter.convert_timestamp_from_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_hash_values_to_pb' do
    it 'converts Google::Protobuf::timestamp to Time' do
      converted = converter.convert_hash_values_to_pb({
        time: Time.new(2016, 4, 5)
      })
      expect(converted[:time].seconds).to eq 1_459_782_000
      expect(converted[:time].nanos).to be 0
    end
    it 'converts Symbol to String' do
      converted = converter.convert_hash_values_to_pb({
        symbol: :test
      })
      expect(converted[:symbol]).to eq 'test'
    end
    it 'deletes hash entry if a value of enty is nil' do
      converted = converter.convert_hash_values_to_pb({
        entry: nil
      })
      expect(converted.include?(:entry)).to eq false
    end
    it 'returns nil when a time is nil' do
      converted = converter.convert_hash_values_to_pb(nil)
      expect(converted).to eq nil
    end
  end

  describe '#convert_property_settings_to_pb' do
    it 'converts property settings to Rpc::PropertySetting' do
      converted = converter.convert_property_settings_to_pb({
        a: 'test',
        b: 1,
        c: :test
      })
      expect(converted.length).to eq 3
      expect(converted[0].id).to eq 'a'
      expect(converted[0].value).to eq 'test'
      expect(converted[1].id).to eq 'b'
      expect(converted[1].value).to eq '1'
      expect(converted[2].id).to eq 'c'
      expect(converted[2].value).to eq 'test'
    end
    it 'returns empty array when a property settings is nil' do
      converted = converter.convert_property_settings_to_pb(nil)
      expect(converted).to eq []
    end
  end
end