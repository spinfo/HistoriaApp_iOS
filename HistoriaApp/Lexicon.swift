
import Foundation

class Lexicon {

    static let defaultLetter = Character("#")

    static let nonAlphaNumerics = CharacterSet.alphanumerics.inverted

    private var lettersToEntries = Dictionary<Character, [LexiconEntry]>()

    var letters: [Character]!

    var numberOfLetters: Int {
        get { return letters.count }
    }

    init(entries: [LexiconEntry]) {
        addEntries(entries)
        sortEntries()

        letters = lettersToEntries.keys.sorted()
    }

    func entries(at letter: Character) -> [LexiconEntry] {
        let entries = lettersToEntries[letter]
        if (entries == nil) {
            return Array()
        } else {
            return entries!
        }
    }

    private func addEntries(_ entries: [LexiconEntry]) {
        for entry in entries {
            addEntry(entry)
        }
    }

    private func addEntry(_ entry: LexiconEntry) {
        let c = determineLexiconLetter(entry.title)
        addEntry(at: c, entry: entry)
    }

    private func addEntry(at letter: Character, entry: LexiconEntry) {
        var entries = lettersToEntries[letter]
        if (entries == nil) {
            entries = []
        }
        entries!.append(entry)
        lettersToEntries[letter] = entries
    }

    private func determineLexiconLetter(_ entryName: String) -> Character {
        let trimmed = entryName.trimmingCharacters(in: Lexicon.nonAlphaNumerics )

        if trimmed.isEmpty {
            return Lexicon.defaultLetter
        }
        return Character(trimmed.prefix(1).uppercased())
    }

    private func sortEntries() {
        for (letter, entries) in lettersToEntries {
            lettersToEntries[letter] = entries.sorted(by: Lexicon.entryTitlesAreInAscendingOrder)
        }
    }

    private static func entryTitlesAreInAscendingOrder(_ e1: LexiconEntry, _ e2: LexiconEntry) -> Bool {
        let result = e1.title.lowercased().compare(e2.title.lowercased())
        return (result == ComparisonResult.orderedAscending)
    }

}


