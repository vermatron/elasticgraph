# Copyright 2024 - 2026 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/support/config"
require "elastic_graph/errors"

module ElasticGraph
  class Indexer
    class Config < Support::Config.define(:latency_slo_thresholds_by_timestamp_in_ms, :skip_derived_indexing_type_updates, :skip_malformed_event_supersession_check)
      json_schema at: "indexer",
        optional: false,
        description: "Configuration for indexing operations and metrics used by `elasticgraph-indexer`.",
        properties: {
          latency_slo_thresholds_by_timestamp_in_ms: {
            description: "Map of indexing latency thresholds (in milliseconds), keyed by the name of " \
              "the indexing latency metric. When an event is indexed with an indexing latency " \
              "exceeding the threshold, a warning with the event type, id, and version will " \
              "be logged, so the issue can be investigated.",
            type: "object",
            patternProperties: {/.+/.source => {type: "integer", minimum: 0}},
            default: {}, # : untyped
            examples: [
              {}, # : untyped
              {"ingested_from_topic_at" => 10000, "entity_updated_at" => 15000}
            ]
          },
          skip_derived_indexing_type_updates: {
            description: "Setting that can be used to specify some derived indexing type updates that should be skipped. This " \
              "setting should be a map keyed by the name of the derived indexing type, and the values should be sets " \
              'of ids. This can be useful when you have a "hot spot" of a single derived document that is ' \
              "receiving a ton of updates. During a backfill (or whatever) you may want to skip the derived " \
              "type updates.",
            type: "object",
            patternProperties: {/^[A-Z]\w*$/.source => {type: "array", items: {type: "string", minLength: 1}}},
            default: {}, # : untyped
            examples: [
              {}, # : untyped
              {"WidgetWorkspace" => ["ABC12345678"]}
            ]
          },
          skip_malformed_event_supersession_check: {
            description: "Recovery-time lever to disable the version-supersession msearch that runs after validation " \
              "failures. By default, when an event fails validation, ElasticGraph queries the datastore (via " \
              "msearch, with no shard routing) to check if a later corrected event has already superseded the " \
              "malformed one, and silently drops superseded failures. During a sustained validation-failure " \
              "storm, that fan-out msearch can amplify load on an already-unhealthy cluster. Setting this to " \
              "`true` skips the msearch entirely and surfaces every malformed event as an outstanding failure " \
              "(including ones that have already been corrected upstream). Leave at the default unless an " \
              "active incident calls for it.",
            type: "boolean",
            default: false,
            examples: [false, true]
          }
        }

      private

      def convert_values(skip_derived_indexing_type_updates:, latency_slo_thresholds_by_timestamp_in_ms:, skip_malformed_event_supersession_check:)
        {
          skip_derived_indexing_type_updates: skip_derived_indexing_type_updates.transform_values(&:to_set),
          latency_slo_thresholds_by_timestamp_in_ms: latency_slo_thresholds_by_timestamp_in_ms,
          skip_malformed_event_supersession_check: skip_malformed_event_supersession_check
        }
      end
    end
  end
end
