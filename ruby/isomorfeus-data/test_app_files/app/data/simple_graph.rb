class SimpleGraph < LucidData::Graph::Base
  attribute :one

  execute_load do |key:|
    if RUBY_ENGINE != 'opal'
    { key: key,
      edges: SimpleEdgeCollection.load(key: 1),
      nodes: SimpleCollection.load(key: 1),
      attributes: { one: key }}
    end
  end

  execute_save do |key:, revision: nil, attributes: nil, edges: nil, links: nil, nodes: nil, documents: nil, vertices: nil, vertexes: nil|
  end

  execute_destroy do |key:|
    true
  end
end
