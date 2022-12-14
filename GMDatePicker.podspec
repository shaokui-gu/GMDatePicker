Pod::Spec.new do |s|
  s.name         = "GMDatePicker"
  s.version      = "0.1.6"
  s.summary      = "A Custom DatePicker supports chinese lunar calendar"
  s.homepage     = "https://github.com/shaokui-gu/GMDatePicker"
  s.license      = 'MIT'
  s.author       = { 'gushaokui' => 'gushaoakui@126.com' }
  s.source       = { :git => "https://github.com/shaokui-gu/GMDatePicker.git" }
  s.source_files = 'Sources/*.swift'
  s.resource_bundles = { 'GMDatePicker' => [ 'Sources/GMDatePicker.bundle/*' ] }
  s.swift_versions = ['5.2', '5.3', '5.4']
  s.requires_arc = true
end
