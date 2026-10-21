# Copyright 2024 - 2026 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

module ElasticGraph
  module SchemaArtifacts
    module RuntimeMetadata
      # Describes a `groupedBy` field whose GraphQL type is an object but which groups on a single leaf value in the index.
      # The grouping value of each bucket is returned wrapped in an object, as `{wrapper_field => value}`.
      #
      # @private
      class WrappedLeafGrouping < ::Data.define(:leaf_type, :wrapper_field)
        LEAF_TYPE = "leaf_type"
        WRAPPER_FIELD = "wrapper_field"

        def self.from_hash(hash)
          new(
            leaf_type: hash.fetch(LEAF_TYPE),
            wrapper_field: hash.fetch(WRAPPER_FIELD)
          )
        end

        def to_dumpable_hash
          {
            # Keys here are ordered alphabetically; please keep them that way.
            LEAF_TYPE => leaf_type,
            WRAPPER_FIELD => wrapper_field
          }
        end
      end
    end
  end
end
