# WhitePages PRO API 2 Graph Response Explorer
#
# Author: Matt Woodward
#
# For more information on the WhitePages PRO API, visit:
# http://whitepages.github.io/pro-api-doc/
#
# This software provided under the MIT License
#
# The MIT License (MIT)
#
# Copyright (c) 2013 WhitePages, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'graphviz'
require 'httparty'
require 'json'

API_KEY="your-api-key-here"

DEFAULT_FORMAT = { fontsize: 8, fontname: "monaco" }

if(ARGV[0] && ARGV[1])
  request = ARGV[0] + "&api_key=#{API_KEY}"

  # make a request to whitepages
  response = HTTParty.get(request)

  # Create a new graph
  g = GraphViz.new ( :G )
  { labelloc: "t", label: request, URL: request }.merge(DEFAULT_FORMAT).each { |k, v| g[k] = v }

  dictionary = response["dictionary"]
  results = response["results"]
  unfulfilled_nodes = { }

  # build the nodes in the graph
  dictionary.each do |(key, value)|
    node_format = { }
    node_text = ""
    case value["id"]["type"]
    when "Person"
      node_text = value["best_name"]
    when "Phone"
      node_text = value["phone_number"]
    when "Location"
      [value["standard_address_line1"], value["standard_address_line2"], value["standard_address_location"]].each do |v|
        if v && !v.length.zero?
          node_text << '\n' unless node_text.length.zero?
          node_text << v
        end
      end
    when "Business"
      node_text = value["name"]
    else
      node_text = "unknown"
    end

    node_text << "\n" << value["id"]["type"] << "\n" << value["id"]["uuid"] << "\n" << value["id"]["durability"]

    value["node"] = g.add_nodes(node_text, { "tooltip" => JSON.pretty_generate(value), shape: "record" }.merge(DEFAULT_FORMAT).merge(node_format))
    value["node"]["URL"] = value["id"]["url"] if value["id"]["url"]
  end

  # build the edges
  dictionary.each do |(key, value)|
    edge_sets = [{edges: (value["locations"] || []).select{|x| x["is_historical"] == true} , descr: "historical"},
                 {edges: (value["locations"] || []).select{|x| x["is_historical"] == false}, descr: "location"},
                 {edges: value["phones"] || [], descr: "phone"},
                 {edges: value["legal_entities_at"] || [], descr: "legal\nentity at"},
                 {edges: value["belongs_to"] || [], descr: "belongs to"},
                 {edges: value["associated_locations"] || [], descr: "associated\nlocation"},
                ]

    edge_sets.each do |edge_set|
      edge_set[:edges].each do |edge|

        destination_node = (dictionary[edge["id"]["key"]] && dictionary[edge["id"]["key"]]["node"]) ||
          unfulfilled_nodes[edge["id"]["key"]] ||
          unfulfilled_nodes[edge["id"]["key"]] = g.add_nodes(edge["id"]["key"], {"URL" => edge["id"]["url"] }.merge(DEFAULT_FORMAT))

        e = g.add_edges( value["node"], destination_node, { label: edge_set[:descr] }.merge(DEFAULT_FORMAT) )
      end
    end
  end

  # color the result nodes
  results.each do |key|
    dictionary[key]["node"]["style"] = "filled"
    dictionary[key]["node"]["fillcolor"] = "dodgerblue"
  end

  # gray the unfulfilled nodes
  unfulfilled_nodes.each do |(k, v)|
    v["style"] = "filled"
    v["fillcolor"] = "lightgray"
  end

  # output as SVG
  g.output(:svg => ARGV[1])
else
  puts "USAGE: ruby graphviz-response.rb APIrequest outputSVG"
end
