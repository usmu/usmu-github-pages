%w{
  shellwords
  uri
  usmu/github/pages/version
  usmu/github/pages/configuration
  usmu/github/pages/commands
}.each {|f| require f }

class Usmu::Github::Pages
  def initialize
    @log = Logging.logger[self]
    @log.debug("Initializing usmu-github-pages v#{VERSION}")
  end

  # @see Usmu::Plugin::CoreHooks#commands
  def commands(ui, c)
    @log.debug('Adding commands from usmu-github-pages.')
    @ui = ui

    c.command(:'gh-pages init') do |command|
      command.syntax = 'usmu gh-pages init'
      command.description = 'Ensures that your repository is compatible and setup correctly for Github Pages.'
      command.action(&method(:command_init))
    end

    c.command(:'gh-pages deploy') do |command|
      command.syntax = 'usmu gh-pages deploy'
      command.description = 'Generates a site and commits it to Github.'
      command.action(&method(:command_deploy))
    end
  end

  def config
    @config ||= Configuration.new(@ui.configuration['plugin', 'github-pages', default: {}])
  end

  def command_init(args, options)
    Usmu::Github::Pages::Commands::Init.new(args, options).run(config)
  end

  def command_deploy(args, options)
    Usmu::Github::Pages::Commands::Deploy.new(args, options).run(config)
  end
end
