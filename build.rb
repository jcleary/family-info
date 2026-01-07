#!/usr/bin/env ruby

require "erb"
# require "json"
# require "net/http"
# require "uri"
# require "time"
require "fileutils"
# require "csv"
require "./lib/bindicator"

@bindicator = Bindicator.new

template = File.read("templates/index.html.erb")
html = ERB.new(template).result(binding)

FileUtils.mkdir_p("dist")
File.write("dist/index.html", html)
puts "Wrote dist/index.html"