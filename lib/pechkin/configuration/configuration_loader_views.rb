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

      raise ConfigurationError, "'#{views_dir}' is not a directory" unless File.directory?(views_dir)

      Dir["#{views_dir}/**/*.erb"].each do |f|
        relative_path = f["#{views_dir}/".length..]
        views[relative_path] = MessageTemplate.new(IO.read(f))
      end
    end
  end
end
