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

      it "defaults `skip_record_validation_for` to an empty set" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {}
        })

        expect(config.skip_record_validation_for).to eq(::Set.new)
      end

      it "converts `skip_record_validation_for` from a YAML list of type names into a set" do
        config = Config.from_parsed_yaml("indexer" => {
          "latency_slo_thresholds_by_timestamp_in_ms" => {},
          "skip_record_validation_for" => ["Widget", "Component"]
        })

        expect(config.skip_record_validation_for).to eq(::Set["Widget", "Component"])
      end

      it "rejects `skip_record_validation_for` entries that are not GraphQL-style type names" do
        expect {
          Config.from_parsed_yaml("indexer" => {
            "latency_slo_thresholds_by_timestamp_in_ms" => {},
            "skip_record_validation_for" => ["widget"]
          })
        }.to raise_error Errors::ConfigError, a_string_including("skip_record_validation_for")
      end
    end
  end
end
