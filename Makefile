periphery:
	periphery scan --project CorporateTestflightPlatform.xcworkspace/ --schemes CorporateTestflightClient

build_app:
	xcodebuild -workspace CorporateTestflightPlatform.xcworkspace/ -scheme CorporateTestflightClient -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' -derivedDataPath ./build build

test_app:
	xcodebuild -workspace CorporateTestflightPlatform.xcworkspace/ -scheme CorporateTestflightClient -testPlan CorporateTestflightClientTests -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' -derivedDataPath ./build test

format:
	swift-format format --recursive --parallel --in-place --configuration .swift-format .
