//
//  MusicLibrary.swift
//  Spark
//
//  Purpose:
//  Streaming music track catalog and URLs.
//
//  Responsibilities:
//  • Defines focus and music tracks available to the audio service.
//

import Foundation

enum TrackCategory: String, CaseIterable, Codable, Hashable {
    case meditation = "Meditation"
    case ambient = "Ambient"
    case piano = "Piano"
    case nature = "Nature"
    case sleep = "Sleep"
    case focus = "Focus"
    case pop = "Pop"
    case upbeat = "Upbeat"
    case jazz = "Jazz"
    case rock = "Rock"

    var displayName: String { rawValue }
}

struct MusicTrack: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let mood: String
    let category: TrackCategory
    let artworkURL: String
    let streamURL: String
}

enum MusicLibrary {
    static let credit = "Music by Kevin MacLeod · incompetech.com · CC-BY 4.0"

    static let categories: [TrackCategory] = [
        .meditation,
        .ambient,
        .piano,
        .nature,
        .sleep,
        .focus,
        .pop,
        .upbeat,
        .jazz,
        .rock,
    ]

    static let tracks: [MusicTrack] = [
        MusicTrack(id: "carefree", title: "Carefree", mood: "Sunny, feel-good pop", category: .pop, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3"),
        MusicTrack(id: "wallpaper", title: "Wallpaper", mood: "Bright, breezy pop", category: .pop, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Wallpaper.mp3"),
        MusicTrack(id: "cheery-monday", title: "Cheery Monday", mood: "Peppy, upbeat pop", category: .pop, artworkURL: "https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Cheery%20Monday.mp3"),
        MusicTrack(id: "happy-alley", title: "Happy Alley", mood: "Playful, sunny pop", category: .pop, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Happy%20Alley.mp3"),
        MusicTrack(id: "life-of-riley", title: "Life of Riley", mood: "Carefree indie-pop", category: .pop, artworkURL: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Life%20of%20Riley.mp3"),
        MusicTrack(id: "beachfront-celebration", title: "Beachfront Celebration", mood: "Party-ready and bright", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1505142468610-359e7d316be0?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Beachfront%20Celebration.mp3"),
        MusicTrack(id: "pixelland", title: "Pixelland", mood: "Bouncy, playful energy", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Pixelland.mp3"),
        MusicTrack(id: "the-show-must-be-go", title: "The Show Must Be Go", mood: "Big, fun and lively", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/The%20Show%20Must%20Be%20Go.mp3"),
        MusicTrack(id: "itty-bitty-8-bit", title: "Itty Bitty 8 Bit", mood: "Retro arcade energy", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Itty%20Bitty%208%20Bit.mp3"),
        MusicTrack(id: "electrodoodle", title: "Electrodoodle", mood: "Feel-good electro-pop", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Electrodoodle.mp3"),
        MusicTrack(id: "blippy-trance", title: "Blippy Trance", mood: "Upbeat electronic pulse", category: .upbeat, artworkURL: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Blippy%20Trance.mp3"),
        MusicTrack(id: "bossa-antigua", title: "Bossa Antigua", mood: "Warm, sunny bossa nova", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Bossa%20Antigua.mp3"),
        MusicTrack(id: "sidewalk-shade", title: "Sidewalk Shade", mood: "Smooth, cool jazz stroll", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sidewalk%20Shade.mp3"),
        MusicTrack(id: "batty-mcfaddin", title: "Batty McFaddin", mood: "Easy swing groove", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Batty%20McFaddin%20-%20Slower.mp3"),
        MusicTrack(id: "vibe-ace", title: "Vibe Ace", mood: "Breezy lounge jazz", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Vibe%20Ace.mp3"),
        MusicTrack(id: "brightly-fancy", title: "Brightly Fancy", mood: "Snappy, upbeat jazz", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Brightly%20Fancy.mp3"),
        MusicTrack(id: "hep-cats", title: "Hep Cats", mood: "Retro swinging jazz", category: .jazz, artworkURL: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Hep%20Cats.mp3"),
        MusicTrack(id: "fearless-first", title: "Fearless First", mood: "Driving, bold rock", category: .rock, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Fearless%20First.mp3"),
        MusicTrack(id: "stringed-disco", title: "Stringed Disco", mood: "Groovy rock-disco", category: .rock, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Stringed%20Disco.mp3"),
        MusicTrack(id: "hero-down", title: "Hero Down", mood: "Anthemic, gutsy rock", category: .rock, artworkURL: "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Hero%20Down.mp3"),
        MusicTrack(id: "frozen-star", title: "Frozen Star", mood: "Epic, cinematic rock", category: .rock, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Frozen%20Star.mp3"),
        MusicTrack(id: "voice-over-under", title: "Voice Over Under", mood: "Punchy alt-rock", category: .rock, artworkURL: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Voice%20Over%20Under.mp3"),
        MusicTrack(id: "aces-high", title: "Aces High", mood: "High-energy rock", category: .rock, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Aces%20High.mp3"),
        MusicTrack(id: "meditation-impromptu-01", title: "Meditation Impromptu 01", mood: "Slow, spacious calm to breathe into", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Meditation%20Impromptu%2001.mp3"),
        MusicTrack(id: "meditation-impromptu-02", title: "Meditation Impromptu 02", mood: "Weightless, drifting stillness", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Meditation%20Impromptu%2002.mp3"),
        MusicTrack(id: "meditation-impromptu-03", title: "Meditation Impromptu 03", mood: "Gentle waves of quiet", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1487621167305-5d248087c724?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Meditation%20Impromptu%2003.mp3"),
        MusicTrack(id: "deep-relaxation", title: "Deep Relaxation", mood: "Sink in and let go", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1512389142860-9c449e58a543?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Deep%20Relaxation.mp3"),
        MusicTrack(id: "peace-of-mind", title: "Peace of Mind", mood: "Soft, settling and safe", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Peace%20of%20Mind.mp3"),
        MusicTrack(id: "tranquility", title: "Tranquility", mood: "Still water, quiet heart", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Tranquility.mp3"),
        MusicTrack(id: "healing", title: "Healing", mood: "Warm, restoring and tender", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Healing.mp3"),
        MusicTrack(id: "kalimba-relaxation-music", title: "Kalimba Relaxation Music", mood: "Soft kalimba to unwind to", category: .meditation, artworkURL: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Kalimba%20Relaxation%20Music.mp3"),
        MusicTrack(id: "relaxing-piano-music", title: "Relaxing Piano Music", mood: "Tender piano to ease your mind", category: .piano, artworkURL: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Relaxing%20Piano%20Music.mp3"),
        MusicTrack(id: "gymnopedie-no-1", title: "Gymnopédie No. 1", mood: "Satie’s timeless, wistful piano", category: .piano, artworkURL: "https://images.unsplash.com/photo-1552422535-c45813c61732?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Gymnopedie%20No%201.mp3"),
        MusicTrack(id: "gymnopedie-no-2", title: "Gymnopédie No. 2", mood: "Slow, graceful and reflective", category: .piano, artworkURL: "https://images.unsplash.com/photo-1552422535-c45813c61732?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Gymnopedie%20No%202.mp3"),
        MusicTrack(id: "gymnopedie-no-3", title: "Gymnopédie No. 3", mood: "Gentle, contemplative keys", category: .piano, artworkURL: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Gymnopedie%20No%203.mp3"),
        MusicTrack(id: "frost-waltz", title: "Frost Waltz", mood: "A delicate, sparkling waltz", category: .piano, artworkURL: "https://images.unsplash.com/photo-1487621167305-5d248087c724?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Frost%20Waltz.mp3"),
        MusicTrack(id: "feather-waltz", title: "Feather Waltz", mood: "Light as air, softly turning", category: .piano, artworkURL: "https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Feather%20Waltz.mp3"),
        MusicTrack(id: "moonlight-hall", title: "Moonlight Hall", mood: "Moonlit, echoing piano", category: .piano, artworkURL: "https://images.unsplash.com/photo-1532978379173-523e16f371f9?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Moonlight%20Hall.mp3"),
        MusicTrack(id: "touching-moments-two-higher", title: "Touching Moments Two — Higher", mood: "Heartfelt and gently rising", category: .piano, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Touching%20Moments%20Two%20-%20Higher.mp3"),
        MusicTrack(id: "bathed-in-the-light", title: "Bathed in the Light", mood: "Warm, glowing ambient wash", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Bathed%20in%20the%20Light.mp3"),
        MusicTrack(id: "chill-wave", title: "Chill Wave", mood: "Smooth, floating and mellow", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Chill%20Wave.mp3"),
        MusicTrack(id: "dreamy-flashback", title: "Dreamy Flashback", mood: "Hazy, nostalgic and soft", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1487621167305-5d248087c724?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Dreamy%20Flashback.mp3"),
        MusicTrack(id: "floating-cities", title: "Floating Cities", mood: "Weightless, drifting soundscape", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Floating%20Cities.mp3"),
        MusicTrack(id: "sovereign", title: "Sovereign", mood: "Calm, expansive and steady", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1483086431886-3590a88317fe?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sovereign.mp3"),
        MusicTrack(id: "anamalie", title: "Anamalie", mood: "Gentle, shimmering atmosphere", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Anamalie.mp3"),
        MusicTrack(id: "angel-share", title: "Angel Share", mood: "Airy and quietly hopeful", category: .ambient, artworkURL: "https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Angel%20Share.mp3"),
        MusicTrack(id: "silent-night", title: "Silent Night", mood: "Hushed and tender for bedtime", category: .sleep, artworkURL: "https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Silent%20Night.mp3"),
        MusicTrack(id: "long-note-two", title: "Long Note Two", mood: "Long, slow drones to drift off", category: .sleep, artworkURL: "https://images.unsplash.com/photo-1532978379173-523e16f371f9?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Long%20Note%20Two.mp3"),
        MusicTrack(id: "ossuary-1-a-beginning", title: "A Beginning", mood: "Deep, slow and dreamlike", category: .sleep, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Ossuary%201%20-%20A%20Beginning.mp3"),
        MusicTrack(id: "dewdrop-fantasy", title: "Dewdrop Fantasy", mood: "Soft twinkles for winding down", category: .sleep, artworkURL: "https://images.unsplash.com/photo-1487621167305-5d248087c724?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Dewdrop%20Fantasy.mp3"),
        MusicTrack(id: "fireflies-and-stardust", title: "Fireflies and Stardust", mood: "Twinkling, sleepy night magic", category: .sleep, artworkURL: "https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Fireflies%20and%20Stardust.mp3"),
        MusicTrack(id: "soaring", title: "Soaring", mood: "Uplifting yet calm for focus", category: .focus, artworkURL: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Soaring.mp3"),
        MusicTrack(id: "air-prelude", title: "Air Prelude", mood: "Light and clear-headed", category: .focus, artworkURL: "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Air%20Prelude.mp3"),
        MusicTrack(id: "wholesome", title: "Wholesome", mood: "Cozy, steady study warmth", category: .focus, artworkURL: "https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Wholesome.mp3"),
        MusicTrack(id: "sardana", title: "Sardana", mood: "Gentle, flowing concentration", category: .focus, artworkURL: "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sardana.mp3"),
        MusicTrack(id: "water-lily", title: "Water Lily", mood: "Delicate and pond-still", category: .nature, artworkURL: "https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Water%20Lily.mp3"),
        MusicTrack(id: "willow-and-the-light", title: "Willow and the Light", mood: "Dappled sunlight through trees", category: .nature, artworkURL: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Willow%20and%20the%20Light.mp3"),
        MusicTrack(id: "cattails", title: "Cattails", mood: "Reeds swaying by the water", category: .nature, artworkURL: "https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Cattails.mp3"),
        MusicTrack(id: "the-cannery", title: "The Cannery", mood: "Soft, breezy and open", category: .nature, artworkURL: "https://images.unsplash.com/photo-1505142468610-359e7d316be0?auto=format&fit=crop&w=400&q=80", streamURL: "https://incompetech.com/music/royalty-free/mp3-royaltyfree/The%20Cannery.mp3"),
        MusicTrack(id: "ocean-waves", title: "Ocean Waves", mood: "Gentle waves on the shore 🌊", category: .nature, artworkURL: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80", streamURL: "https://assets.mixkit.co/active_storage/sfx/1196/1196.wav"),
        MusicTrack(id: "gentle-rain", title: "Gentle Rain", mood: "Soft rainfall to melt into 🌧️", category: .nature, artworkURL: "https://images.unsplash.com/photo-1428592953211-077101b2021b?auto=format&fit=crop&w=400&q=80", streamURL: "https://assets.mixkit.co/active_storage/sfx/2411/2411.wav"),
    ]

    static func track(id: String?) -> MusicTrack? {
        guard let id else { return nil }
        return tracks.first { $0.id == id }
    }

    static func tracks(in category: TrackCategory) -> [MusicTrack] {
        tracks.filter { $0.category == category }
    }

    static func stepTrack(from currentID: String?, direction: Int) -> String? {
        guard !tracks.isEmpty else { return nil }
        let idx = tracks.firstIndex { $0.id == currentID } ?? 0
        let next = (idx + direction + tracks.count) % tracks.count
        return tracks[next].id
    }
}
