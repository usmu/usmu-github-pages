%w{
  rugged
  usmu/github/pages/version
}.each {|f| require f }

module Usmu
  module Github
    class Pages
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
          command.action &method(:command_init)
        end

        c.command(:'gh-pages deploy') do |command|
          command.syntax = 'usmu gh-pages deploy'
          command.description = 'Generates a site and commits it to Github.'
          command.action &method(:command_deploy)
        end
      end

      def command_init(args, options)
        @configuration = @ui.configuration
        @log.fatal('Not implemented')
        # Ensure git >= 2.5
        # Work out what the correct gh-pages branch is.
        # Ensure we're not on the target branch already!
        # Ensure the destination directory is configured correctly.
        # - doesn't exist - setup the worktree
        # - does exist - ensure .git exists and is a file. Fail loudly if not.
        # Ensure destination is gitignored.
        # Check if branch exists locally and remotely.
        # - remote-only - setup local branch to mirror it
        # - local exists - use local
        # - neither exists - create branch as new orphan and add an empty commit
      end

      def command_deploy(args, options)
        @configuration = @ui.configuration
        @log.fatal('Not implemented')
        # Ensure clean worktree.
        Usmu.plugins[Usmu::Plugin::Core].command_generate({}, options)
        # Commit results.
        # Push branch to remote.
      end
    end
  end
end
