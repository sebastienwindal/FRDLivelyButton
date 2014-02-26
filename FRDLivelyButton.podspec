Pod::Spec.new do |s|
  s.name         = "FRDLivelyButton"
  s.version      = "1.0"
  s.summary      = "Lively button."
  s.description  = "CWStatusBarNotification is a library allows you to present a beautiful text-based notification in the status bar."
  s.homepage     = "http://github.com/sebastienwindal/FRDLivelyButton"
  s.screenshots  = "https://raw.github.com/sebastienwindal/FRDLivelyButton/master/screenshots/screenshot.png"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Sebastien Windal" => "sebastien@windal.net" }
  s.platform     = :ios, '7.0'
  s.source = { :git => "https://github.com/sebastienwindal/FRDLivelyButton.git",
               :tag => s.version.to_s }
  s.source_files  = 'FRDLivelyButton'
  s.requires_arc = true
end