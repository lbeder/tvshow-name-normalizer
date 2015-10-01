@ECHO OFF

bundle exec ruby ../tvshow_name_normalizer.rb normalize_directory --path=%cd% --recursive

PAUSE
