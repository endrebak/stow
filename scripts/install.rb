#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"
require "time"

HOME = Pathname.new(Dir.home)
REPO = Pathname.new(__dir__).parent
SKIP_DIRS = ["scripts", ".git", "__pycache__"]

INSTALL_DROPBOX = true  # flip to false if you don't want that part

def timestamp
  Time.now.strftime("%Y%m%d-%H%M%S")
end

def backup(path)
  return unless path.exist? || path.symlink?

  backup_path = Pathname.new("#{path}.bak-#{timestamp}")
  puts "Backing up #{path} -> #{backup_path}"
  FileUtils.mv(path, backup_path)
end

def sh(cmd)
  puts "+ #{cmd}"
  system(cmd) || abort("Command failed: #{cmd}")
end

def ensure_stow
  return if system("command -v stow > /dev/null")

  puts "Installing stow with pacman (Arch/Omarchy)…"
  sh("sudo pacman -S --needed --noconfirm stow")
end

def maybe_install_dropbox
  return unless INSTALL_DROPBOX
  return if system("command -v dropbox > /dev/null")

  puts "Installing Dropbox with pacman (Arch/Omarchy)…"
  sh("sudo pacman -S --needed --noconfirm dropbox")
end

def backup_existing_configs
  backup(HOME / ".bashrc")
  backup(HOME / ".bash_profile")

  hypr_dir = HOME / ".config" / "hypr"
  FileUtils.mkdir_p(hypr_dir)

  Dir[hypr_dir.join("*.conf")].each do |conf|
    backup(Pathname.new(conf))
  end
end

def stow_packages
  Dir.children(REPO).sort.each do |entry|
    next if SKIP_DIRS.include?(entry)
    next if entry.start_with?(".") && entry != ".config"

    pkg = REPO / entry
    next unless pkg.directory?

    puts "Stowing #{entry}/ → #{HOME}"
    sh("stow -v -t #{HOME} #{entry}")
  end
end

def main
  puts "Repo root: #{REPO}"
  ensure_stow
  backup_existing_configs
  maybe_install_dropbox
  stow_packages
end

main

