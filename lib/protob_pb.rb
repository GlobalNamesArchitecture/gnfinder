# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protob.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "protob.Pong" do
    optional :value, :string, 1
  end
  add_message "protob.Void" do
  end
  add_message "protob.Params" do
    optional :text, :bytes, 1
    optional :with_bayes, :bool, 3
    optional :language, :string, 4
    optional :with_verification, :bool, 5
    repeated :sources, :int32, 6
  end
  add_message "protob.NameStrings" do
    optional :text, :bytes, 3
    repeated :names, :message, 6, "protob.NameString"
  end
  add_message "protob.NameString" do
    optional :value, :string, 1
    optional :verbatim, :string, 2
    optional :odds, :float, 3
    optional :path, :string, 4
    optional :curated, :bool, 5
    optional :edit_distance, :int32, 6
    optional :edit_distance_stem, :int32, 7
    optional :source_id, :int32, 8
    optional :match, :enum, 9, "protob.MatchType"
    repeated :sources_result, :message, 10, "protob.SourceResult"
  end
  add_message "protob.SourceResult" do
    optional :source_id, :int32, 1
    optional :title, :string, 2
    optional :name_id, :string, 3
    optional :taxon_id, :string, 4
  end
  add_enum "protob.MatchType" do
    value :NONE, 0
    value :EXACT, 1
    value :CANONICAL_EXACT, 2
    value :CANONICAL_FUZZY, 3
    value :PARTIAL_EXACT, 4
    value :PARTIAL_FUZZY, 5
  end
end

module Protob
  Pong = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Pong").msgclass
  Void = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Void").msgclass
  Params = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.Params").msgclass
  NameStrings = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.NameStrings").msgclass
  NameString = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.NameString").msgclass
  SourceResult = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.SourceResult").msgclass
  MatchType = Google::Protobuf::DescriptorPool.generated_pool.lookup("protob.MatchType").enummodule
end
