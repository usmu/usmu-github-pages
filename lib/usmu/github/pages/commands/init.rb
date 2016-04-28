
class Usmu::Github::Pages::Commands::Init
  def initialize(*)
    @log = Logging.logger[self]
  end

  def run(ui, config)
    # Ensure git (>= 2.5).
    ensure_git!

    # Work out what the correct gh-pages branch is.
    remote = config['remote', default: 'origin']
    branch = config['branch', default: config.default_branch(remote)]
    @log.info("Configuring to deploy to #{remote}/#{branch}")

    # Ensure destination is gitignored.
    destination = ui.configuration['destination', default: 'site']
    gitignore_path = File.expand_path './.gitignore', ui.configuration.config_dir
    gitignore = File.read(gitignore_path).lines.map(&:chomp)
    if gitignore.grep(%r{^/?#{File.basename destination}$}).empty?
      @log.info("Adding #{destination} to gitignore at #{gitignore_path}")
      gitignore.push("#{File.basename destination}")
      File.write gitignore_path, gitignore.join("\n") + "\n"
    end

    # Ensure the destination directory is configured correctly.
    destination = ui.configuration.destination_path
    ensure_destination! destination

    # Check if branch exists locally and remotely.
    branches = `git branch -a`.lines.map{|l| l[2..-1]}.map(&:chomp)
    local = !branches.select{|b| b == branch }.empty?
    remote = !branches.select{|b| b == "remotes/#{remote}/#{branch}" }.empty?
    if !local && !remote
      create_destination_branch destination, branch
    else
      checkout_destination_branch destination, branch
    end
  end

  protected

  def ensure_git!
    git_version = `git version 2>&1`.split(' ').last
    if Gem::Version.new(git_version) < Gem::Version.new('2.5.0')
      @log.fatal('The Github Pages plugin requires at least git version 2.5.0')
      exit 1
    end
  end

  def ensure_destination!(destination)
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
  end

  def create_destination_branch(destination, branch)
    Dir.chdir destination do
      `git checkout -f --orphan #{Shellwords.escape branch} 2>&1`
      `git rm -r . 2>&1`
      `git clean -fd 2>&1`
    end
  end

  def checkout_destination_branch(destination, branch)
    Dir.chdir destination do
      `git checkout -f #{Shellwords.escape branch} 2>&1`
    end
  end
end
