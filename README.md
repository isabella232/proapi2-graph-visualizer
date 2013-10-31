# proapi2-graph-visualizer

Ruby, graphviz visualizer for WhitePages PRO API 2.0

## Requirements

* A WhitePages PRO API Key. For more information, please email [WhitePages PRO Sales](mailto:prosales@whitepages.com). You should also study the [documentation for the WhitePages PRO API 2.0](http://whitepages.github.io/pro-api-doc).
* Graphviz - for information on on Graphviz and installation packages can be found at [graphviz.org](http://www.graphviz.org)
* ruby-graphviz - ruby-graphviz can be installed with the included Gemfile and bundler. For more information on ruby-graphviz please visit [the Ruby-Graphviz project on GitHub](https://github.com/glejeune/Ruby-Graphviz/)
* httpparty - httparty can be installed with the included Gemfile and bundler. For more information on httparty, please visit [the httparty project on GitHub](https://github.com/jnunemaker/httparty).

## Use

The graph visualizer runs on the command line. It takes two parameters. The first is the api request you're making. For convenience, we append an API key you have provided in the main source file. The other parameter is the output SVG file.

SVG files can be read by many programs. For the purposes of examining the WhitePages API responses, it is recommended that you use Google Chrome to view the resulting SVG file. This will allow you to click the resulting graph nodes to retrieve them as well as click the original query in the graph title. While it isn't particularly pretty, you can view the JSON associated with a graph node by overing over the graph node.

## Examples

    ruby graph-response.rb "https://proapi.whitepages.com/2.0/business.json?name=whitepages&zip=98101" whitepages-bizsearch.svg
    ruby graph-response.rb "https://proapi.whitepages.com/2.0/phone.json?phone=2069735100" whitepages-phone.svg
    

