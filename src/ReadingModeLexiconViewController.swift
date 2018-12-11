
import Foundation
import UIKit

class ReadingModeLexiconTableViewCell : UITableViewCell {
    @IBOutlet weak var entryLabel: UILabel!
}

class ReadingModeLexiconTableViewSectionHeaderCell : UITableViewCell {
    @IBOutlet weak var letterLabel: UILabel!
}

class ReadingModeLexiconViewController : UITableViewController {

    var lexicon: Lexicon!

    override func viewWillAppear(_ animated: Bool) {
        fetchLexicon()
    }

    private func fetchLexicon() {
        let entries = MainDao().getAllLexiconEntries()
        lexicon = Lexicon(entries: entries)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "readingModeLexiconTableCell") as! ReadingModeLexiconTableViewCell

        let entry = getEntry(at: indexPath)
        cell.entryLabel.text = entry?.title

        // cell.layoutIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "readingModeLexiconTableViewSectionHeaderCell") as! ReadingModeLexiconTableViewSectionHeaderCell

        if isWithinLettersBounds(section) {
            let letter = lexicon.letters[section]
            cell.letterLabel.text = String(letter)
        }
        return cell
    }


    private func getEntry(at indexPath: IndexPath) -> LexiconEntry? {
        let entriesSection = getSection(at: indexPath)
        return getEntry(at: indexPath, from: entriesSection)
    }

    private func getSection(at indexPath: IndexPath) -> [LexiconEntry] {
        return getSection(at: indexPath.section)
    }

    private func getSection(at idx: Int) -> [LexiconEntry] {
        guard isWithinLettersBounds(idx) else {
            return Array()
        }
        return lexicon.entries(at: lexicon.letters[idx])
    }

    private func getEntry(at indexPath: IndexPath, from entries: [LexiconEntry]) -> LexiconEntry? {
        if (indexPath.row >= 0 && indexPath.row < entries.count) {
            return entries[indexPath.row]
        } else {
            return nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return lexicon.numberOfLetters
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isWithinLettersBounds(section) else {
            return 0
        }
        let letter = lexicon.letters[section]
        return lexicon.entries(at: letter).count
    }

    private func isWithinLettersBounds(_ idx: Int) -> Bool {
        return idx >= 0 && idx < lexicon.numberOfLetters
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return lexicon.letters.map({ letter in String(letter)} )
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = getEntry(at: indexPath)
        if (entry != nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.switchToLexiconArticle(for: entry!)
        }
    }

}
