
class Usmu::Github::Pages::Commands::Deploy
  def initialize(*)
    @log = Logging.logger[self]
  end

  def run(ui, config)
    remote = config['remote', default: 'origin']
    branch = config['branch', default: config.default_branch(remote)]
    destination = ui.configuration.destination_path

    # Ensure we're deploying a complete commit.
    sha = `git rev-parse HEAD`.chomp[0, 7]
    unless working_dir_clean?
      @log.fatal("Found unsaved changes in your git repository. Please commit these changes and try again.")
      exit 1
    end

    # Ensure clean worktree.
    @log.info("Cleaning output directory.")
    clean_destination(destination, remote, branch)

    # Regenerate site.
    Usmu.plugins[Usmu::Plugin::Core].command_generate({}, options)

    # Commit results.
    create_commit!(destination, "Update created by usmu-github-pages from revision #{sha}.")

    # Push branch to remote.
    @log.info("Deploying to Github...")
    `git push #{Shellwords.escape remote} #{Shellwords.escape branch} 2>&1`

    cname_file = File.expand_path('./CNAME', destination)
    if File.exist? cname_file
      @log.success("Your site should be available shortly at http://#{File.read(cname_file).chomp}/")
    else
      @log.success("Deploy completed successfully.")
    end
  end

  protected

  def working_dir_clean?
    `git diff HEAD --name-only`.lines.count == 0
  end

  def clean_destination(destination, remote, branch)
    Dir.chdir destination do
      remote = Shellwords.escape remote
      branch = Shellwords.escape branch
      `(git fetch #{remote} && git reset --hard #{remote}/#{branch}) 2>&1`
    end
  end

  def create_commit!(destination, message)
    Dir.chdir destination do
      if working_dir_clean?
        @log.info "Detected no changes - deploy aborted."
        exit 0
      end
      `(git add . && git commit -a -m #{Shellwords.escape message}) 2>&1`
      if $?.exitstatus != 0
        @log.fatal "Unable to create a new commit. Please check the destination folder for more information."
        exit 1
      end
    end
  end
end
