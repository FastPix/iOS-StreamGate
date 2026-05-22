struct PlaybackId: Codable {
    let id: String
}

struct MediaResponse: Codable {

    let data: MediaData
}

struct MediaData: Codable {

    let status: String
    let playbackIds: [PlaybackItem]
}

struct PlaybackItem: Codable {

    let id: String
}
