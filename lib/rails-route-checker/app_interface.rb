# frozen_string_literal: true

module RailsRouteChecker
  class AppInterface
    def initialize(**opts)
      @options = { ignored_controllers: [], ignored_paths: [], ignored_path_whitelist: {} }.merge(opts)
    end

    def routes_without_actions
      loaded_app.routes.map do |r|
        controller = r.requirements[:controller]
        action = r.requirements[:action]

        next if options[:ignored_controllers].include?(controller)
        next if controller_has_action?(controller, action)

        {
          controller: controller,
          action: action
        }
      end.compact
    end

    def undefined_path_method_calls
      generate_undef_view_path_calls + generate_undef_controller_path_calls
    end

    private

    attr_reader :options

    def loaded_app
      @loaded_app ||= RailsRouteChecker::LoadedApp.new
    end

    def controller_information
      @controller_information ||= loaded_app.controller_information.reject do |path, _|
        options[:ignored_controllers].include?(path)
      end
    end

    def controller_has_action?(controller, action)
      return false unless controller_information.key?(controller)

      info = controller_information[controller]
      return true if info[:actions].include?(action)
      return true if info[:lookup_context]&.template_exists?("#{controller}/#{action}")

      false
    end

    def generate_undef_view_path_calls
      generate_undef_view_path_calls_erb + generate_undef_view_path_calls_haml
    end

    def generate_undef_view_path_calls_erb
      files = Dir['app/**/*.erb']
      return [] if files.none?

      RailsRouteChecker::Parsers::Loader.load_parser(:erb)

      files.map do |filename|
        controller = controller_from_view_file(filename)
        next unless controller # controller will be nil if it's an ignored controller

        filter = lambda do |path_or_url|
          return false if match_in_whitelist?(filename, path_or_url)
          return false if match_defined_in_view?(controller, path_or_url)

          true
        end

        RailsRouteChecker::Parsers::ErbParser.run(filename, filter: filter)
      end.flatten.compact
    end

    def generate_undef_view_path_calls_haml
      files = Dir['app/**/*.haml']
      return [] if files.none?

      unless RailsRouteChecker::Parsers::Loader.haml_available?
        puts 'WARNING: There are Haml files in your codebase, ' \
           "but the Haml parser for rails-route-checker couldn't load!"
        return []
      end

      RailsRouteChecker::Parsers::Loader.load_parser(:haml)

      files.map do |filename|
        controller = controller_from_view_file(filename)
        next unless controller # controller will be nil if it's an ignored controller

        filter = lambda do |path_or_url|
          return false if match_in_whitelist?(filename, path_or_url)
          return false if match_defined_in_view?(controller, path_or_url)

          true
        end

        RailsRouteChecker::Parsers::HamlParser.run(filename, filter: filter)
      end.flatten.compact
    end

    def generate_undef_controller_path_calls
      files = Dir['app/controllers/**/*.rb']
      return [] if files.none?

      RailsRouteChecker::Parsers::Loader.load_parser(:ruby)

      files.map do |filename|
        controller = controller_from_ruby_file(filename)
        next unless controller # controller will be nil if it's an ignored controller

        filter = lambda do |path_or_url|
          return false if match_in_whitelist?(filename, path_or_url)
          return false if match_defined_in_ruby?(controller, path_or_url)

          return true
        end

        RailsRouteChecker::Parsers::RubyParser.run(filename, filter: filter)
      end.flatten.compact
    end

    def match_in_whitelist?(filename, path_or_url)
      possible_route_name = path_or_url.sub(/_(?:url|path)$/, '')
      return true if options[:ignored_paths].include?(possible_route_name)

      (options[:ignored_path_whitelist][filename] || []).include?(path_or_url)
    end

    def match_defined_in_view?(controller, path_or_url)
      possible_route_name = path_or_url.sub(/_(?:url|path)$/, '')
      return true if loaded_app.all_route_names.include?(possible_route_name)

      controller && controller[:helpers].include?(path_or_url)
    end

    def match_defined_in_ruby?(controller, path_or_url)
      possible_route_name = path_or_url.sub(/_(?:url|path)$/, '')
      return true if loaded_app.all_route_names.include?(possible_route_name)

      controller && controller[:instance_methods].include?(path_or_url)
    end

    def controller_from_view_file(filename)
      split_path = filename.split('/')
      possible_controller_path = split_path[(split_path.index('app') + 2)..-2]

      while possible_controller_path.any?
        controller_name = possible_controller_path.join('/')
        return controller_information[controller_name] if controller_exists?(controller_name)

        possible_controller_path = possible_controller_path[0..-2]
      end
      controller_information['application']
    end

    def controller_from_ruby_file(filename)
      controller_name = (filename.match(%r{app/controllers/(.*)_controller.rb}) || [])[1]
      return controller_information[controller_name] if controller_exists?(controller_name)

      controller_information['application']
    end

    def controller_exists?(controller_name)
      return false unless controller_name

      File.exist?("app/controllers/#{controller_name}_controller.rb")
    end
  end
end
