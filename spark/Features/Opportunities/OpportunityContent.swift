//
//  OpportunityContent.swift
//  Spark
//
//  Purpose:
//  Static Discover Opportunities seed data.
//
//  Responsibilities:
//  • Provides bundled opportunity listings for local browsing.
//

import Foundation

/// Static seed data for the Discover Opportunities feed.
enum OpportunityContent {
    static let categories: [OpportunityCategory] = [
        .volunteer,
        .camps,
        .competitions,
        .leadership,
        .tech,
        .arts,
    ]

    static let seed: [Opportunity] = [
        Opportunity(
            id: "o1",
            title: "Kode With Klossy Summer Camp",
            org: "Kode With Klossy",
            category: .tech,
            description:
                "Free 2-week coding camp for girls & gender-expansive teens. Learn to build real apps with a supportive squad of scholars. Every KWK program is 100% free — no cost to join. 🎉 Coming up: a \"Code-a-bration\" event to celebrate your projects and community!",
            deadline: "Applications open Feb",
            location: "Multiple cities + Virtual",
            cost: .free,
            link: "https://www.kodewithklossy.com",
            imageColorHex: 0x6B26D6
        ),
        Opportunity(
            id: "o-ynd",
            title: "Youth Neurodiversity Ambassador",
            org: "Youth for Neurodiversity",
            category: .volunteer,
            description:
                "Become a youth ambassador for neurodiversity! Share your story, help others feel seen, and spark kinder, more inclusive spaces at school and online. Your unique brain is exactly what this movement needs. 💜",
            deadline: "Rolling",
            location: "Your community + Online",
            cost: .free,
            link: "https://youthfornd.org",
            imageColorHex: 0xD61E6C
        ),
        Opportunity(
            id: "o2",
            title: "Girls Who Code Clubs",
            org: "Girls Who Code",
            category: .tech,
            description:
                "Join or start a free club to build sisterhood and coding skills after school. Beginner friendly, all levels welcome.",
            deadline: "Rolling",
            location: "Nationwide + Online",
            cost: .free,
            link: "https://girlswhocode.com",
            imageColorHex: 0x0F9E88
        ),
        Opportunity(
            id: "o3",
            title: "National Youth Leadership Summit",
            org: "YLI",
            category: .leadership,
            description:
                "A weekend to grow your voice, meet inspiring mentors, and build a passion project that gives back to your community.",
            deadline: "Apply by May 1",
            location: "Washington, D.C.",
            cost: .scholarship,
            link: "https://www.nylc.org",
            imageColorHex: 0xE0951C
        ),
        Opportunity(
            id: "o4",
            title: "Local Animal Shelter Helpers",
            org: "Paws & Hearts",
            category: .volunteer,
            description:
                "Cuddle rescue animals, help at adoption events, and earn service hours. Flexible shifts — perfect for busy brains.",
            deadline: "Rolling",
            location: "Your city",
            cost: .free,
            link: "https://www.volunteermatch.org/search/?l=&k=animal+shelter",
            imageColorHex: 0xE84D52
        ),
        Opportunity(
            id: "o5",
            title: "Teen Art & Mural Collective",
            org: "City Arts Council",
            category: .arts,
            description:
                "Design and paint a community mural with other young artists. No experience needed — just creativity and good vibes.",
            deadline: "Apply by Apr 15",
            location: "Community centers",
            cost: .free,
            link: "https://www.americansforthearts.org",
            imageColorHex: 0xD61E6C
        ),
        Opportunity(
            id: "o6",
            title: "Congressional App Challenge",
            org: "U.S. Congress",
            category: .competitions,
            description:
                "Build an app, win recognition from your representative. Solo or team — a great first competition for new coders.",
            deadline: "Submit by Nov",
            location: "Virtual",
            cost: .free,
            link: "https://www.congressionalappchallenge.us",
            imageColorHex: 0x276FDB
        ),
        Opportunity(
            id: "o7",
            title: "STEM Explorers Overnight Camp",
            org: "Camp Discovery",
            category: .camps,
            description:
                "A week of robotics, rockets, and real friendships. Sensory-friendly options and quiet spaces available.",
            deadline: "Early bird by Mar",
            location: "Lake Ridge, CA",
            cost: .paid,
            link: "https://www.mysummercamps.com/camps/Academic_Camps/Science_Camps/",
            imageColorHex: 0x6B26D6
        ),
        Opportunity(
            id: "o8",
            title: "Young Writers Fellowship",
            org: "InkWell",
            category: .arts,
            description:
                "Get paired with a published author mentor and publish your own short story in a teen anthology.",
            deadline: "Apply by Jun 1",
            location: "Virtual",
            cost: .scholarship,
            link: "https://www.youngwritersproject.org",
            imageColorHex: 0x0F9E88
        ),
    ]
}
