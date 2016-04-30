# usmu-github-pages

[![Circle CI](https://circleci.com/gh/usmu/usmu-github-pages/tree/master.svg?style=svg)](https://circleci.com/gh/usmu/usmu-github-pages/tree/master)
[![Dependency Status](https://gemnasium.com/usmu/usmu-github-pages.svg)](https://gemnasium.com/usmu/usmu-github-pages)
[![Code Climate](https://codeclimate.com/github/usmu/usmu-github-pages/badges/gpa.svg)](https://codeclimate.com/github/usmu/usmu-github-pages)

**Source:** [https://github.com/usmu/usmu-github-pages](https://github.com/usmu/usmu-github-pages)
**Author:** Matthew Scharley  
**Contributors:** [See contributors on GitHub][gh-contrib]  
**Bugs/Support:** [Github Issues][gh-issues]  
**Copyright:** 2016  
**License:** [MIT license][license]  
**Status:** Active

## Synopsis

Allows you to deploy your [Usmu][usmu] website to the Github Pages service or another git-based service.

## Installation

    $ gem install usmu-github-pages

OR

    $ echo 'gem "usmu-github-pages"' >> Gemfile
    $ bundle install

Usmu will automatically detect any plugins available and automatically make them available.

## Configuration

    $ usmu gh-pages init

This plugin also supports a few keys in `usmu.yml`:

    plugins:
      github-pages:
        # The remote to deploy to. Change this if github is not your origin
        # remote.
        remote: origin
        # The branch to deploy to. This should get correctly configured
        # automatically in all cases involving Github but is provided just in
        # case you need to change it or you are using another git-based host.
        branch: gh-pages

## Usage

    $ usmu gh-pages deploy

  [gh-contrib]: https://github.com/usmu/usmu-github-pages/graphs/contributors
  [gh-issues]: https://github.com/usmu/usmu-github-pages/issues
  [license]: https://github.com/usmu/usmu-github-pages/blob/master/LICENSE.md
  [usmu]: https://github.com/usmu/usmu
