//
//  SupportiveResponseService.swift
//  Spark
//
//  Purpose:
//  Supportive copy generator for feelings interactions.
//
//  Responsibilities:
//  • Selects kind responses based on mood context.
//

import Foundation

enum SupportiveTone {
    case up
    case down
    case neutral
}

struct SupportiveResponse {
    let tone: SupportiveTone
    let message: String
}

enum SupportiveResponseService {
    private static let downMoods: Set<String> = ["Sad", "Anxious", "Frustrated", "Overwhelmed", "Meh"]
    private static let upMoods: Set<String> = ["Happy", "Calm", "Excited"]

    private static let support: [String: [String]] = [
        "Sad": [
            "It's okay to feel sad — it means something mattered to you. Be soft with yourself today. 💗",
            "Sad days are real and they're allowed. You don't have to rush yourself out of it. I'm proud of you for noticing how you feel. 🌧️→🌈",
            "This heavy feeling won't last forever, even if it feels big right now. You've made it through every hard day so far. 🌟",
        ],
        "Anxious": [
            "Anxiety can feel loud, but it doesn't get to decide who you are. Try one slow breath — you're safe in this moment. 🫧",
            "Your body's just trying to protect you. Nothing's wrong with you for feeling anxious. Let's take it one tiny step at a time. 🍃",
            "That racing feeling is real — and it will pass. You don't have to figure everything out right now. Just this next breath. 💙",
        ],
        "Frustrated": [
            "Frustration usually means you care a lot. That's not a bad thing. Give yourself a second to breathe it out. 🔥→🌿",
            "Ugh, that's genuinely annoying — you're allowed to feel it. You're not doing anything wrong by being frustrated. 💪",
            "It makes total sense to feel stuck right now. Step back for a sec — you don't have to push through it all at once. 🌸",
        ],
        "Overwhelmed": [
            "When everything feels like too much, you're allowed to put some of it down. You don't have to hold it all at once. 🤍",
            "Overwhelmed just means you've got a lot on your plate — not that you're failing. Pick ONE tiny thing. The rest can wait. 🌊",
            "Take a breath with me. You are one person, and one person is enough. It's okay to ask for help too. 💗",
        ],
        "Meh": [
            "'Meh' days are valid too — not every day has to sparkle. You still showed up, and that counts. 🌥️",
            "Feeling flat is human. You don't owe anyone a mood. Maybe something tiny and cozy would feel nice right now? 🍵",
            "A quiet, in-between day is okay. Be gentle with yourself — you don't have to force it. 🌙",
        ],
    ]

    private static let celebrate: [String: [String]] = [
        "Happy": [
            "Yesss, love this for you! Soak it all in — you deserve every bit of this good feeling. 🌟",
            "This is your reminder that happy moments are yours to keep. Enjoy it fully! 💛",
            "So happy you're feeling this! Little joys are worth celebrating. ✨",
        ],
        "Calm": [
            "That peaceful feeling looks good on you. Hold onto it. 🍃",
            "Calm and steady — you found your center today. That's a real skill. 🌿",
            "Love this quiet, settled energy for you. Breathe it in. 🫶",
        ],
        "Excited": [
            "Your excitement is contagious! Ride that spark as far as it takes you. ⚡️",
            "Yesss, let that energy fly! Good things are coming. 🎉",
            "This is the kind of buzz that makes cool stuff happen. Go you! 🌈",
        ],
    ]

    private static let defaultUp = "Thanks for checking in — you did a kind thing for yourself. 🌸"
    private static let defaultDown = "Whatever you're feeling right now is allowed. Be gentle with yourself. 💗"

    static func response(for mood: String) -> SupportiveResponse {
        if downMoods.contains(mood) {
            let message = support[mood]?.randomElement() ?? defaultDown
            return SupportiveResponse(tone: .down, message: message)
        }
        if upMoods.contains(mood) {
            let message = celebrate[mood]?.randomElement() ?? defaultUp
            return SupportiveResponse(tone: .up, message: message)
        }
        return SupportiveResponse(tone: .neutral, message: defaultUp)
    }
}
