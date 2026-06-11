# Copyright 2024 - 2026 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/indexer/config"
require "yaml"

module ElasticGraph
  class Indexer
    RSpec.describe Config do
      it "raises an error when given an unrecognized config setting" do
        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "fake_setting" => 23
          })
        }.to raise_error Errors::ConfigError, a_string_including("fake_setting")
      end

      it "converts the values of `skip_derived_indexing_type_updates` to a set" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {},
          "skip_derived_indexing_type_updates" => {
            "WidgetCurrency" => ["USD"]
          }
        })

        expect(config.skip_derived_indexing_type_updates).to eq("WidgetCurrency" => ["USD"].to_set)
      end

      it "defaults `skip_record_validation_for` to an empty hash" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {}
        })

        expect(config.skip_record_validation_for).to eq({})
      end

      it "accepts `skip_record_validation_for` as a map of GraphQL type names to skip rates" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {},
          "skip_record_validation_for" => {"Widget" => 0.9, "Component" => 1.0}
        })

        expect(config.skip_record_validation_for).to eq("Widget" => 0.9, "Component" => 1.0)
      end

      it "coerces integer rates (e.g. `1`) to `Float` so consumers see a uniform numeric type" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {},
          "skip_record_validation_for" => {"Widget" => 1, "Component" => 0}
        })

        expect(config.skip_record_validation_for).to eq("Widget" => 1.0, "Component" => 0.0)
        expect(config.skip_record_validation_for.values).to all be_a(::Float)
      end

      it "rejects `skip_record_validation_for` keys that are not GraphQL-style type names" do
        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "skip_record_validation_for" => {"widget" => 1.0}
          })
        }.to raise_error Errors::ConfigError, a_string_including("skip_record_validation_for")
      end

      it "rejects `skip_record_validation_for` rates outside the `[0.0, 1.0]` range" do
        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "skip_record_validation_for" => {"Widget" => 1.5}
          })
        }.to raise_error Errors::ConfigError, a_string_including("skip_record_validation_for")

        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "skip_record_validation_for" => {"Widget" => -0.1}
          })
        }.to raise_error Errors::ConfigError, a_string_including("skip_record_validation_for")
      end

      it "rejects `skip_record_validation_for` values that are not numeric" do
        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "skip_record_validation_for" => {"Widget" => "high"}
          })
        }.to raise_error Errors::ConfigError, a_string_including("skip_record_validation_for")
      end
    end
  end
end
