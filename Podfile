platform :ios, '10.2'

project 'HistoriaApp.xcodeproj'

target 'HistoriaApp' do
  use_frameworks!

  # Our framework for maps
  pod 'WhirlyGlobe', '2.4'

  # Yaml parsing
  pod 'Yams', '~> 0.3.5'

  # Unzipping files
  pod 'SSZipArchive', '~> 2.0.3'

  # an sqlite library
  pod 'GRDB.swift', '1.0'

  # a minimal logging library
  pod 'SpeedLog'

  # support for our navigation drawer menu
  pod 'MMDrawerController', '~> 0.5.7'

  # For WhirlyGlobe to peacefully compile together with
  # GRDB, we need to change two import statements
  # to require sqlite3 as a library.
  # NOTE: This can be removed, once GRDB is switched to 2.0
  post_install do |installer|
    %w(
      Pods/WhirlyGlobe/WhirlyGlobeSrc/WhirlyGlobeLib/include/VectorDatabase.h
      Pods/WhirlyGlobe/WhirlyGlobeSrc/WhirlyGlobeLib/include/sqlhelpers.h 
    ).flat_map { |w| Dir.glob(w) }.each do |header|

      contents = File.read(header)
      contents.gsub!('"sqlite3.h"', '<sqlite3.h>')

      File.chmod(0644, header)
      File.write(header, contents)
      File.chmod(0444, header)
    end
  end
end
