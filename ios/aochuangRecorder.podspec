

Pod::Spec.new do |s|



  s.name         = "aochuangRecorder"
  s.version      = "1.0.0"
  s.summary      = "eeui plugin."
  s.description  = <<-DESC
                    eeui plugin.
                   DESC

  s.homepage     = "https://eeui.app"
  s.license      = "MIT"
  s.author             = { "kuaifan" => "aipaw@live.cn" }
  s.source =  { :path => '.' }
  s.source_files  = "aochuangRecorder", "**/**/*.{h,m,mm,c}"
  s.exclude_files = "Source/Exclude"
  s.resources = 'aochuangRecorder/resources/*.*'
  s.platform     = :ios, "10.0"
  s.requires_arc = true
  s.frameworks = "AudioToolbox"
  
  s.vendored_libraries = 'AMR/libopencore-amrnb.a', 'AMR/libopencore-amrwb.a'

  s.dependency 'WeexSDK'
  s.dependency 'eeui'
  s.dependency 'WeexPluginLoader', '~> 0.0.1.9.1'

end
