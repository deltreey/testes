module Testes
  class Runner
    attr_reader :target_directory, :tests

    def initialize(target_directory = Dir.pwd)
      @target_directory = target_directory
      @tests = []
      @failing = []
      @passing = []
    end

    def run
      puts "RUNNING ALL TESTS IN #{target_directory}"
      tests_with_context.each_pair do |filename, context|
        tests << Unit.new(filename, :rvm_context => context)
      end

      tests.each do |test|
        begin
          test.run
        ensure
          if test.passing?
            @passing << test
          else
            @failing << test
          end
        end
      end
    end

    def contexts_with_tests
      @contexts_with_tests ||= {}.tap do |hsh|
        rvm_contexts.each do |context|
          hsh[context] = test_files.select { |filename| filename.include?(context) }
        end
      end
    end

    def tests_with_context
      @tests_with_context ||= {}.tap do |hsh|
        test_files.each do |test|
          hsh[test] = rvm_contexts.detect { |context| test.include?(context) }
        end
      end
    end

    def test_files
      @test_files ||= begin
        res = Dir.glob("**/*_test.rb").map{|test| File.realdirpath(test) unless Pathname(test).each_filename.to_a.include?('target')}.compact
        # puts "TEST FILES: #{res.inspect}"
        res
      end
    end

    def rvm_contexts
      @rvm_contexts ||= begin
        res = Dir.glob("**/\.ruby-version").map{|p| File.realdirpath(p).sub('.ruby-version', '')}.sort{|a,b| b.length <=> a.length }
        # puts "CONTEXTS: #{res.inspect}"
        res
      end
    end
  end
end