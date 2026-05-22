import ReplayKit
import AVFoundation
 
class SampleHandler: RPBroadcastSampleHandler {
    private static let suiteName = "group.com.streamgate.broadcast"
 
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var tmpURL: URL?           // where AVAssetWriter writes (extension temp dir)
    private var finalURL: URL?         // where main app reads (App Group container)
    private var frameCount = 0
    private var appendedCount = 0
    private var sessionStarted = false
 
    private static func container() -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
    }
 
    private static func writeStage(_ stage: String, _ detail: String = "") {
        guard let dir = container() else { return }
        let line = "[\(Date())] \(stage) \(detail)\n"
        let url = dir.appendingPathComponent("LIFECYCLE.log")
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8) ?? Data())
            try? handle.close()
        } else {
            try? line.write(to: url, atomically: true, encoding: .utf8)
        }
    }
 
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        
        // Signal to main app that broadcast is active
           UserDefaults(suiteName: Self.suiteName)?.set(true, forKey: "isBroadcasting")
        
        if let dir = Self.container() {
            try? FileManager.default.removeItem(at: dir.appendingPathComponent("LIFECYCLE.log"))
        }
        
        // Clear any leftover files from previous recordings FIRST
        Self.clearOldRecordings()

        // Also clear the stale UserDefaults signal so the main app
        // doesn't navigate to a file that no longer exists
        UserDefaults(suiteName: Self.suiteName)?.removeObject(forKey: "recordedVideoURL")

        Self.writeStage("1_STARTED")
 
        let name = "\(UUID().uuidString).mp4"
        // Write to extension's temp dir — AVAssetWriter is happy here.
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        tmpURL = tmp
        // Where we'll move it after finishWriting succeeds.
        finalURL = Self.container()?.appendingPathComponent(name)
 
        Self.writeStage("2_TMP_URL", tmp.path)
 
        // Belt-and-braces: AVAssetWriter refuses to write if the file already exists.
        try? FileManager.default.removeItem(at: tmp)
 
        do {
            assetWriter = try AVAssetWriter(outputURL: tmp, fileType: .mp4)
            Self.writeStage("3_WRITER_INIT_OK")
        } catch {
            Self.writeStage("ERR_WRITER_INIT", error.localizedDescription)
            finishBroadcastWithError(error)
        }
    }
    
    private static func clearOldRecordings() {
            let fileManager = FileManager.default
            
            // 1. Clean the Shared App Group Container
            if let groupDir = container() {
                do {
                    let groupFiles = try fileManager.contentsOfDirectory(at: groupDir, includingPropertiesForKeys: nil)
                    for file in groupFiles where file.pathExtension.lowercased() == "mp4" {
                        try fileManager.removeItem(at: file)
                        Self.writeStage("CLEANUP", "Deleted old group file: \(file.lastPathComponent)")
                    }
                } catch {
                    Self.writeStage("CLEANUP_ERR", "Failed to clean group dir: \(error.localizedDescription)")
                }
            }
            
            // 2. Clean the Extension's Temporary Directory
            let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            do {
                let tempFiles = try fileManager.contentsOfDirectory(at: tmpDir, includingPropertiesForKeys: nil)
                for file in tempFiles where file.pathExtension.lowercased() == "mp4" {
                    try fileManager.removeItem(at: file)
                    Self.writeStage("CLEANUP", "Deleted old temp file: \(file.lastPathComponent)")
                }
            } catch {
                Self.writeStage("CLEANUP_ERR", "Failed to clean temp dir: \(error.localizedDescription)")
            }
        }
    
 
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with type: RPSampleBufferType) {
        guard type == .video, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        frameCount += 1
        if frameCount == 1 { Self.writeStage("4_FIRST_FRAME") }
 
        if videoInput == nil {
            guard let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
            let dim = CMVideoFormatDescriptionGetDimensions(fmt)
            // Round to nearest multiple of 16 for H.264 safety.
            let w = Int(dim.width) - (Int(dim.width) % 16)
            let h = Int(dim.height) - (Int(dim.height) % 16)
 
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: w,
                AVVideoHeightKey: h,
                AVVideoCompressionPropertiesKey: [
                    AVVideoAverageBitRateKey: 2_000_000,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel
                ]
            ]
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.expectsMediaDataInRealTime = true
            if let writer = assetWriter, writer.canAdd(input) {
                writer.add(input)
                videoInput = input
                Self.writeStage("5_INPUT_ADDED", "\(w)x\(h) (raw \(dim.width)x\(dim.height))")
            } else {
                Self.writeStage("ERR_CANT_ADD_INPUT")
                return
            }
        }
 
        guard let writer = assetWriter, let input = videoInput else { return }
 
        if writer.status == .unknown {
            let ok = writer.startWriting()
            Self.writeStage("6_START_WRITING", "returned=\(ok) status=\(writer.status.rawValue) err=\(String(describing: writer.error))")
            if !ok { return }
            writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            sessionStarted = true
            Self.writeStage("7_SESSION_STARTED", "status=\(writer.status.rawValue)")
        }
 
        if writer.status == .writing, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
            appendedCount += 1
            if appendedCount == 1 { Self.writeStage("8_FIRST_APPEND_OK") }
        }
    }
 
    override func broadcastFinished() {
        Self.writeStage("9_FINISHED_CALLED", "frames=\(frameCount) appended=\(appendedCount)")
        
        // Signal to main app that broadcast stopped
           UserDefaults(suiteName: Self.suiteName)?.set(false, forKey: "isBroadcasting")

 
        guard let writer = assetWriter, writer.status == .writing else {
            Self.writeStage("ERR_NOT_WRITING_AT_FINISH", "status=\(assetWriter?.status.rawValue ?? -1) err=\(String(describing: assetWriter?.error))")
            return
        }
 
        videoInput?.markAsFinished()
 
        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting { [weak self] in
            defer { semaphore.signal() }
            guard let self = self, let tmp = self.tmpURL, let final = self.finalURL else { return }
            Self.writeStage("10_FINISH_WRITING_DONE", "status=\(writer.status.rawValue) err=\(String(describing: writer.error))")
 
            // Move from extension temp → App Group so the main app can see it.
            try? FileManager.default.removeItem(at: final)
            do {
                try FileManager.default.moveItem(at: tmp, to: final)
                Self.writeStage("11_MOVED_TO_GROUP", final.path)
                UserDefaults(suiteName: Self.suiteName)?.set(final.path, forKey: "recordedVideoURL")
                Self.writeStage("12_USERDEFAULTS_SET")
            } catch {
                Self.writeStage("ERR_MOVE_FAILED", error.localizedDescription)
            }
        }
        _ = semaphore.wait(timeout: .now() + 5)
        Self.writeStage("13_AFTER_WAIT")
    }
}
