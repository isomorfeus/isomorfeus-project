class SimpleEdge < LucidData::Edge::Base
  attribute :one

  execute_load do |key:|
    target_key = key.to_i + 1
    target_key = 5 if target_key > 5
    { key: key, attributes: { one: key }, from: ['SimpleNode', key], to: ['SimpleNode', target_key] }
  end

  execute_save do |key:, revision: nil, from:, to:, attributes: nil|
  end

  execute_destroy do |key:|
    true
  end
end
