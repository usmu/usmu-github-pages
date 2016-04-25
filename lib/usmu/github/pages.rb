%w{
  shellwords
  uri
  usmu/github/pages/configuration
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
        config = Configuration.new(@ui.configuration['plugin', 'github-pages', default: {}])

        # Ensure git (>= 2.5).
        git_version = `git version 2>&1`.split(' ').last
        if Gem::Version.new(git_version) < Gem::Version.new('2.5.0')
          @log.fatal('The Github Pages plugin requires at least git version 2.5.0')
          exit 1
        end

        # Work out what the correct gh-pages branch is.
        remote = config['remote', default: 'origin']
        branch = config['branch', default: config.default_branch(remote)]
        @log.info("Configuring to deploy to #{remote}/#{branch}.")

        # Ensure destination is gitignored.
        destination = @ui.configuration['destination', default: 'site']
        gitignore_path = File.expand_path './.gitignore', @ui.configuration.config_dir
        gitignore = File.read(gitignore_path).lines.map(&:chomp)
        if gitignore.grep(%r{^/?#{File.basename destination}$}).empty?
          @log.info("Adding #{destination} to gitignore at #{gitignore_path}")
          gitignore.push("#{File.basename destination}")
          File.write gitignore_path, gitignore.join("\n") + "\n"
        end

        # Ensure the destination directory is configured correctly.
        destination = @ui.configuration.destination_path
        if File.exist? destination
          unless File.file? File.expand_path('./.git', destination)
            if File.exist? File.expand_path('./.git', destination)
              @log.fatal('Destination directory looks like a git clone not a worktree: ' + destination)
            else
              @log.fatal('Destination directory exists but doesn\'t look like it is controlled by git: ' + destination)
            end
            exit 1
          end
        else
          @log.info("Configuring git worktree at: #{destination}")
          `git worktree prune 2>&1`
          `git worktree add #{Shellwords.escape destination} HEAD 2>&1`
        end

        # Check if branch exists locally and remotely.
        branches = `git branch -a`.lines.map{|l| l[2..-1]}.map(&:chomp)
        local = !branches.select{|b| b == branch }.empty?
        remote = !branches.select{|b| b == "remotes/#{remote}/#{branch}" }.empty?
        if !local && !remote
          Dir.chdir destination do
            `git checkout -f --orphan #{Shellwords.escape branch} 2>&1`
            `git rm -r . 2>&1`
          end
        else
          Dir.chdir destination do
            `git checkout -f #{Shellwords.escape branch} 2>&1`
          end
        end
      end

      def command_deploy(args, options)
        @configuration = @ui.configuration
        config = Configuration.new(@ui.configuration['plugin', 'github-pages', default: {}])
        remote = config['remote', default: 'origin']
        branch = config['branch', default: config.default_branch(remote)]
        destination = @ui.configuration.destination_path

        # Ensure clean worktree.
        @log.info("Cleaning output directory.")
        Dir.chdir destination do
          `git fetch #{Shellwords.escape remote} 2>&1`
          `git reset --hard #{Shellwords.escape remote}/#{Shellwords.escape branch} 2>&1`
        end

        # Regenerate site.
        Usmu.plugins[Usmu::Plugin::Core].command_generate({}, options)

        # Commit results.
        `git add . 2>&1`
        if `git diff HEAD --name-only`.lines.count > 0
          @log.info "Detected no changes - deploy aborted."
          exit 0
        end
        `git commit -a -m "Update created by usmu-github-pages." 2>&1`
        if $?.exitstatus != 0
          @log.fatal "Unable to create a new commit. Please check the destination folder for more information."
          exit 1
        end

        # Push branch to remote.
        # `git push #{Shellwords.escape remote} #{Shellwords.escape branch} 2>&1`
      end
    end
  end
end
