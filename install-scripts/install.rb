#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"
require "time"
require "tmpdir"

HOME = Pathname.new(Dir.home)
REPO = Pathname.new(__dir__).parent
SKIP_DIRS = ["scripts", ".git", "__pycache__"]
SYSTEM_PACKAGES = ["keyd"]

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

def install_dropbox
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

def stow_system_packages
  SYSTEM_PACKAGES.each do |entry|
    pkg = REPO / entry
    next unless pkg.directory?

    puts "Stowing system package #{entry}/ → /"
    sh("sudo stow -v -t / #{entry}")
  end
end

def install_keyd
  # Check if keyd is already installed
  return if system("pacman -Qi keyd > /dev/null 2>&1")

  puts "Installing keyd with pacman (Arch/Omarchy)…"
  sh("sudo pacman -S --needed --noconfirm keyd")
end

def install_keyd_sudoers
  sudoers_body = "%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl start keyd, /usr/bin/systemctl stop keyd\n"

  Dir.mktmpdir("keyd-toggle") do |dir|
    tmp = Pathname.new(dir) / "keyd-toggle"
    tmp.write(sudoers_body)
    # local perms; sudo install will enforce mode again
    File.chmod(0o440, tmp.to_s)

    puts "Installing /etc/sudoers.d/keyd-toggle (will prompt for sudo if needed)…"
    # This is effectively idempotent: re-running just overwrites with the same content.
    sh("sudo install -m 440 #{tmp} /etc/sudoers.d/keyd-toggle")
  end
end

def ensure_keyd_disabled
  puts "Ensuring keyd is disabled and stopped (off by default)…"
  # Idempotent: calling this repeatedly is fine.
  sh("sudo systemctl disable --now keyd")
end

def main
  puts "Repo root: #{REPO}"
  ensure_stow
  backup_existing_configs
  install_dropbox
  install_keyd
  stow_packages
  stow_system_packages
  install_keyd_sudoers
  ensure_keyd_disabled
end

main
