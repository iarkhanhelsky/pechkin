module Pechkin
  # Configuration loader for view descriptions
  class ConfigurationLoaderViews
    include ConfigurationLoader

    def load_from_directory(working_dir)
      views = {}
      load_views_configuration(working_dir, views)

      views
    end

    private

    def load_views_configuration(working_dir, views)
      views_dir = File.join(working_dir, 'views')

      unless File.directory?(views_dir)
        raise ConfigurationError, "'#{views_dir}' is not a directory"
      end

      Dir["#{views_dir}/**/*.erb"].each do |f|
        relative_path = f["#{views_dir}/".length..-1]
        views[relative_path] = MessageTemplate.new(IO.read(f))
      end
    end
  end
end
