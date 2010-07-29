module Capybara
  class Node
    module Matchers
      def has_xpath?(path, options={})
        wait_conditionally_until do
          results = all(:xpath, path, options)

          if options[:count]
            results.size == options[:count]
          else
            results.size > 0
          end
        end
      rescue Capybara::TimeoutError
        return false
      end

      def has_no_xpath?(path, options={})
        wait_conditionally_until do
          results = all(:xpath, path, options)

          if options[:count]
            results.size != options[:count]
          else
            results.empty?
          end
        end
      rescue Capybara::TimeoutError
        return false
      end

      def has_css?(path, options={})
        has_xpath?(XPath.from_css(path), options)
      end

      def has_no_css?(path, options={})
        has_no_xpath?(XPath.from_css(path), options)
      end

      class Matcher
        def expression(&block)
          @expression = block if block
          @expression
        end

        def failure_message(&block)
          @failure_message = block if block
          @failure_message
        end

        def negative_failure_message(&block)
          @negative_failure_message = block if block
          @negative_failure_message
        end
      end

      def self.matcher(name, &block)
        get_matcher = lambda do |*args|
          matcher = Matcher.new
          matcher.instance_exec(*args, &block) if block
          matcher.expression { XPath.send(name, *args) } unless matcher.expression
          matcher
        end
        define_method(:"has_#{name}?") do |*args|
          has_xpath?(get_matcher[*args].expression.call)
        end
        define_method(:"has_no_#{name}?") do |*args|
          has_no_xpath?(get_matcher[*args].expression.call)
        end
      end

      matcher :content
      matcher :link
      matcher :button
      matcher :field
      matcher :table do |locator, options|
        expression { XPath.table(locator, options || {}) }
      end
      matcher :select do |locator, options|
        expression { XPath.select(locator, options || {}) }
      end
      matcher :unchecked_field do |locator|
        expression { XPath.field(locator, :unchecked => true) }
      end
      matcher :checked_field do |locator|
        expression { XPath.field(locator, :checked => true) }
      end
    end
  end
end
