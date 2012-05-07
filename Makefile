default:
	xcodebuild

install:
	xcodebuild install DSTROOT=/

clean:
	xcodebuild clean
