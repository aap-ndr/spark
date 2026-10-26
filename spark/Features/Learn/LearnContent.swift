//
//  LearnContent.swift
//  Spark
//
//  Purpose:
//  Static Neurodiversity Corner articles and resources.
//
//  Responsibilities:
//  • Provides educational copy and external resource links.
//

import Foundation

/// Static Neurodiversity Corner articles and resource links.
enum LearnContent {
    struct Resource: Identifiable, Equatable {
        let id: String
        let emoji: String
        let name: String
        let desc: String
        let url: String

        init(emoji: String, name: String, desc: String, url: String) {
            self.id = url
            self.emoji = emoji
            self.name = name
            self.desc = desc
            self.url = url
        }
    }

    static let headerSubtitle =
        "A kind, no-judgment guide to how your beautiful brain works. ADHD often comes along with other differences like dyslexia, autism or anxiety — here we focus on ADHD, especially in girls. 💗"

    static let whatIsADHDIntro =
        "ADHD (Attention-Deficit/Hyperactivity Disorder) is one kind of neurodiversity — simply a different way the brain is wired. It affects things like focus, attention, energy, and managing big feelings."

    static let whatIsADHDBodyPrefix =
        "You are smart, capable, and full of effort — ADHD is simply about how your brain is wired. It runs on its own kind of fuel, and once you understand it, you can work "

    static let whatIsADHDBodyBold = "with"

    static let whatIsADHDBodySuffix = " it. 🌱"

    static let strengthIntro =
        "ADHD is a difference, not just a difficulty. So many amazing things come with it:"

    static let strengthItems = [
        "🎨 Creativity & out-of-the-box ideas",
        "🔥 Hyperfocus on things you love",
        "💞 Deep empathy and big-heartedness",
        "🌍 Big-picture thinking",
        "💪 Resilience — you handle a lot",
        "😄 Humor, spontaneity & fun",
    ]

    static let strengthFooter =
        "Your brain isn't a problem to fix — it's a superpower to understand. ✨"

    static let girlsIntro =
        "ADHD in girls often looks quieter than the \"bouncing off the walls\" idea, so it's frequently missed or noticed later. You might:"

    static let girlsBullets = [
        "Feel more daydreamy or \"in your head\" than hyper",
        "Work really hard to hide your struggles (this is called masking)",
        "Feel anxious, overwhelmed, or easily overstimulated",
        "Be a people-pleaser or perfectionist",
        "Get called \"spacey\" or \"too sensitive\" when you're really just wired differently",
    ]

    static let girlsFooter =
        "If any of this sounds like you — your brain works beautifully in its own way, and you're in wonderful company. 💗"

    static let coOccurringIntro =
        "ADHD loves company. It often shows up alongside other kinds of neurodiversity, and having more than one is completely normal. You might also notice things like:"

    static let coOccurringBullets = [
        "Dyslexia or dyscalculia (reading, writing or number differences)",
        "Being autistic, or having autistic traits",
        "Anxiety, or big, deep-feeling emotions",
        "Sensory sensitivity — sounds, lights or textures feeling like a lot",
        "Being highly sensitive or a deep thinker",
    ]

    static let coOccurringFooter =
        "None of this makes you \"too much.\" Every brain is a unique mix, and yours is beautifully your own. Whatever combination you have, you are whole exactly as you are. 💗"

    static let resourcesSectionSubtitle =
        "Trusted places to learn more (these open in your browser)."

    static let resources: [Resource] = [
        Resource(
            emoji: "📺",
            name: "How to ADHD",
            desc: "A warm, popular YouTube channel that explains ADHD in a friendly way.",
            url: "https://www.youtube.com/@HowtoADHD"
        ),
        Resource(
            emoji: "📚",
            name: "Understood.org",
            desc: "Clear guides on ADHD and learning differences.",
            url: "https://www.understood.org"
        ),
        Resource(
            emoji: "💜",
            name: "Youth for Neurodiversity — Stories",
            desc: "Real stories from neurodivergent youth (and where you can be an ambassador!).",
            url: "https://youthfornd.org"
        ),
        Resource(
            emoji: "🌸",
            name: "ADDitude Magazine",
            desc: "Trusted articles and tips for living well with ADHD.",
            url: "https://www.additudemag.com"
        ),
        Resource(
            emoji: "🤝",
            name: "CHADD",
            desc: "A leading nonprofit with support and resources for ADHD.",
            url: "https://chadd.org"
        ),
    ]

    static let disclaimer =
        "💡 Spark is here for support and learning — not medical advice. If you have questions about a diagnosis or treatment, talk to a trusted adult or a doctor. You deserve real support. 💗"
}
