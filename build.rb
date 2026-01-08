#!/usr/bin/env ruby

require "erb"
require "fileutils"
require "./lib/bindicator"
require "./lib/config"

@config = Config.new('config.yml')
@bindicator = Bindicator.new(@config)

template = File.read("templates/index.html.erb")
html = ERB.new(template).result(binding)

FileUtils.mkdir_p("dist")
File.write("dist/index.html", html)
puts "Wrote dist/index.html"

FileUtils.mkdir_p("dist/images")
FileUtils.cp_r("images/.", "dist/images")
puts "Copied images to dist/images"