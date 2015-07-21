module Testes
  class RvmContext
    attr_reader :target_directory, :tests

    def initialize(context)
      (raise "not a valid context!") unless Dir.entries(context).include?('.ruby-version')
      @context = context
    end

    def run(context)

      puts "RUNNING ALL TESTS IN #{target_directory}"
      tests_with_context.each_pair do |filename, context|
        tests << Unit.new(filename, rvm_context: context)
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

    def tests_with_context
      @tests_with_context ||= begin
        {}.tap do |hsh|
          test_files.each do |test|
            hsh[test] = rvm_contexts.detect { |context| test.include?(context) }
          end
        end
      end
    end

    def test_files
      @test_files ||= begin
        res = Dir.glob("**/*_test.rb").map{|test| File.realdirpath(test) unless Pathname(test).each_filename.to_a.include?('target')}.compact
        puts "TEST FILES: #{res.inspect}"
        res
      end
    end
  end
end