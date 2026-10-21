# Copyright 2024 - 2026 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/schema_artifacts/runtime_metadata/graphql_field"
require "elastic_graph/spec_support/runtime_metadata_support"

module ElasticGraph
  module SchemaArtifacts
    module RuntimeMetadata
      RSpec.describe GraphQLField do
        include RuntimeMetadataSupport

        it "builds from a minimal hash" do
          field = GraphQLField.from_hash({})

          expect(field).to eq GraphQLField.new(
            computation_function: nil,
            name_in_index: nil,
            relation: nil,
            resolver: nil,
            wrapped_leaf_grouping: nil
          )
        end

        it "round-trips `computation_function` through the dumped form, symbolizing it on load" do
          field = GraphQLField.new(
            computation_function: :sum,
            name_in_index: nil,
            relation: nil,
            resolver: configured_graphql_resolver(:self),
            wrapped_leaf_grouping: nil
          )

          expect(field.to_dumpable_hash).to include("computation_function" => "sum")
          expect(GraphQLField.from_hash(field.to_dumpable_hash).computation_function).to eq :sum
        end

        it "exposes `resolver` as nil when it is unset" do
          field = GraphQLField.from_hash({})

          expect(field.resolver).to eq nil
          expect(field.to_dumpable_hash).to include("resolver" => nil)
        end

        it "round-trips `wrapped_leaf_grouping` through the dumped form" do
          field = graphql_field_with(wrapped_leaf_grouping: WrappedLeafGrouping.new(leaf_type: "ID", wrapper_field: "id"))

          expect(field.to_dumpable_hash).to include("wrapped_leaf_grouping" => {"leaf_type" => "ID", "wrapper_field" => "id"})
          expect(GraphQLField.from_hash(field.to_dumpable_hash)).to eq field
        end

        it "is needed in the dumped runtime metadata when it has a `wrapped_leaf_grouping`, even if nothing else is customized" do
          field = graphql_field_with(name_in_index: "foo", wrapped_leaf_grouping: WrappedLeafGrouping.new(leaf_type: "ID", wrapper_field: "id"))

          expect(field.needed?("foo")).to be true
          expect(field.with(wrapped_leaf_grouping: nil).needed?("foo")).to be false
        end
      end
    end
  end
end
