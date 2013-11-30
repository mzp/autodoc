require "rspec"
require "autodoc/collector"
require "autodoc/configuration"
require "autodoc/document"
require "autodoc/transaction"
require "autodoc/version"

module Autodoc
  class << self
    def collector
      @collector ||= Autodoc::Collector.new
    end

    def configuration
      @configuration ||= Autodoc::Configuration.new
    end
  end
end

if ENV["AUTODOC"]
  RSpec.configure do |config|
    config.after(:each, autodoc: true) do
      txn = Autodoc::Transaction.build(self)
      Autodoc.collector.collect(example, txn)
    end

    config.after(:suite) do
      Autodoc.collector.documents.each do |filepath, documents|
        filepath = filepath.gsub("./spec/requests/", "").gsub("_spec.rb", ".md")
        pathname = Rails.root.join("doc")
        pathname += ENV["AUTODOC"] if ENV["AUTODOC"] != "1"
        pathname += filepath
        pathname.parent.mkpath
        pathname.open("w") {|file| file << documents.join("\n").rstrip + "\n" }
      end
    end
  end
end
